// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import SQLite3

/// Keeps messages in a SQLite file. The file is opened, and its schema built
/// or migrated, on the first call. A nil `fileURL` keeps them in memory.
actor ChatMessageDatabaseService: ChatMessageService {
    static let version: Int32 = 2

    private let fileURL: URL?
    // Only touched from the actor and from deinit, when nothing else can.
    private nonisolated(unsafe) var connection: OpaquePointer?

    init(fileURL: URL?) {
        self.fileURL = fileURL
    }

    deinit {
        sqlite3_close_v2(connection)
    }

    func insert(_ message: ChatMessage, sessionId: String) async throws -> ChatMessage {
        let database: OpaquePointer = try open()
        // Backend ids repeat across sessions, so the pair is what is unique.
        // Nulls are distinct, so a message with no backend id is always stored.
        try run(database, """
            INSERT INTO chat_message
            (session_id, wi_id, role, content, type, status, timestamp, header, footer, voice)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT (session_id, wi_id) DO NOTHING
            """, [
                sessionId,
                message.wiId,
                message.role.rawValue,
                message.content,
                message.type.rawValue,
                message.status.rawValue,
                Self.milliseconds(message.timestamp),
                message.header,
                message.footer,
                try message.voice.map { note in
                    String(decoding: try JSONEncoder().encode(note), as: UTF8.self)
                },
            ])
        if sqlite3_changes(database) == 0, let wiId = message.wiId {
            let stored: [ChatMessage] = try query(
                database,
                "SELECT * FROM chat_message WHERE session_id = ? AND wi_id = ? LIMIT 1",
                [sessionId, wiId]
            )
            if let existing = stored.first {
                return existing
            }
        }
        var inserted: ChatMessage = message
        inserted.id = sqlite3_last_insert_rowid(database)
        return inserted
    }

    func messages(sessionId: String, limit: Int) async throws -> [ChatMessage] {
        try query(
            try open(),
            "SELECT * FROM chat_message WHERE session_id = ? ORDER BY timestamp DESC, id DESC LIMIT ?",
            [sessionId, Int64(limit)]
        )
    }

    func deleteSessions(_ sessionIds: [String]) async throws {
        let database: OpaquePointer = try open()
        // SQLite takes at most 999 bound values in one statement on older versions.
        for start in stride(from: 0, to: sessionIds.count, by: Self.deleteBatch) {
            let batch: [String] = Array(sessionIds[start..<min(start + Self.deleteBatch, sessionIds.count)])
            let placeholders: String = Array(repeating: "?", count: batch.count).joined(separator: ",")
            try run(database, "DELETE FROM chat_message WHERE session_id IN (\(placeholders))", batch)
        }
    }

    private static let deleteBatch: Int = 900

    private func open() throws -> OpaquePointer {
        if let connection {
            return connection
        }
        var path: String = ":memory:"
        if let fileURL {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            path = fileURL.path
        }
        var database: OpaquePointer?
        let flags: Int32 = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX
        let code: Int32 = sqlite3_open_v2(path, &database, flags, nil)
        guard code == SQLITE_OK, let database else {
            let error: ChatMessageServiceError = Self.failure(database, code: code)
            sqlite3_close_v2(database)
            throw error
        }
        do {
            // Several chats can hold their own connection to the same file.
            sqlite3_busy_timeout(database, 5_000)
            try migrate(database)
        } catch {
            sqlite3_close_v2(database)
            throw error
        }
        connection = database
        return database
    }

    private func migrate(_ database: OpaquePointer) throws {
        let found: Int32 = try query(database, "PRAGMA user_version", []) { statement in
            sqlite3_column_int(statement, 0)
        }.first ?? 0
        guard found < Self.version else {
            return
        }
        try run(database, "BEGIN IMMEDIATE", [])
        do {
            if found < 1 {
                try run(database, """
                    CREATE TABLE chat_message (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        session_id TEXT NOT NULL,
                        wi_id TEXT,
                        role TEXT NOT NULL,
                        content TEXT NOT NULL DEFAULT '',
                        type TEXT NOT NULL,
                        status TEXT NOT NULL,
                        timestamp INTEGER NOT NULL,
                        header TEXT,
                        footer TEXT
                    )
                    """, [])
                try run(database, """
                    CREATE UNIQUE INDEX index_chat_message_session_wi_id
                    ON chat_message (session_id, wi_id)
                    """, [])
                try run(database, """
                    CREATE INDEX index_chat_message_session_timestamp
                    ON chat_message (session_id, timestamp)
                    """, [])
            }
            if found < 2 {
                try run(database, "ALTER TABLE chat_message ADD COLUMN voice TEXT", [])
            }
            try run(database, "PRAGMA user_version = \(Self.version)", [])
            try run(database, "COMMIT", [])
        } catch {
            sqlite3_exec(database, "ROLLBACK", nil, nil, nil)
            throw error
        }
    }

    private func run(_ database: OpaquePointer, _ sql: String, _ values: [(any Sendable)?]) throws {
        let statement: OpaquePointer = try prepare(database, sql, values)
        defer {
            sqlite3_finalize(statement)
        }
        let code: Int32 = sqlite3_step(statement)
        guard code == SQLITE_DONE || code == SQLITE_ROW else {
            throw Self.failure(database, code: code)
        }
    }

    private func query(
        _ database: OpaquePointer,
        _ sql: String,
        _ values: [(any Sendable)?]
    ) throws -> [ChatMessage] {
        try query(database, sql, values, row: Self.message)
    }

    private func query<Row>(
        _ database: OpaquePointer,
        _ sql: String,
        _ values: [(any Sendable)?],
        row: (OpaquePointer) throws -> Row
    ) throws -> [Row] {
        let statement: OpaquePointer = try prepare(database, sql, values)
        defer {
            sqlite3_finalize(statement)
        }
        var rows: [Row] = []
        while true {
            let code: Int32 = sqlite3_step(statement)
            if code == SQLITE_DONE {
                return rows
            }
            guard code == SQLITE_ROW else {
                throw Self.failure(database, code: code)
            }
            rows.append(try row(statement))
        }
    }

    private func prepare(_ database: OpaquePointer, _ sql: String, _ values: [(any Sendable)?]) throws -> OpaquePointer {
        var prepared: OpaquePointer?
        let code: Int32 = sqlite3_prepare_v2(database, sql, -1, &prepared, nil)
        guard code == SQLITE_OK, let statement = prepared else {
            throw Self.failure(database, code: code)
        }
        for (offset, value) in values.enumerated() {
            let index: Int32 = Int32(offset + 1)
            switch value {
            case let text as String:
                sqlite3_bind_text(statement, index, text, -1, Self.transient)
            case let number as Int64:
                sqlite3_bind_int64(statement, index, number)
            default:
                sqlite3_bind_null(statement, index)
            }
        }
        return statement
    }

    private static func message(_ statement: OpaquePointer) throws -> ChatMessage {
        var columns: [String: Int32] = [:]
        for index in 0..<sqlite3_column_count(statement) {
            columns[String(cString: sqlite3_column_name(statement, index))] = index
        }
        func text(_ name: String) -> String? {
            guard let index = columns[name], let value = sqlite3_column_text(statement, index) else {
                return nil
            }
            return String(cString: value)
        }
        func integer(_ name: String) -> Int64 {
            columns[name].map { sqlite3_column_int64(statement, $0) } ?? 0
        }
        guard
            let role = text("role").flatMap(ChatMessage.Role.init(rawValue:)),
            let status = text("status").flatMap(ChatMessage.Status.init(rawValue:))
        else {
            throw ChatMessageServiceError.unreadableRow
        }
        return ChatMessage(
            role: role,
            type: MessageType.of(text("type") ?? ""),
            timestamp: Date(timeIntervalSince1970: Double(integer("timestamp")) / 1_000),
            id: integer("id"),
            wiId: text("wi_id"),
            content: text("content") ?? "",
            status: status,
            header: text("header"),
            footer: text("footer"),
            // A note this version cannot read leaves the message without one rather than unreadable.
            voice: text("voice").flatMap { stored in
                try? JSONDecoder().decode(VoiceNote.self, from: Data(stored.utf8))
            }
        )
    }

    private static func milliseconds(_ date: Date) -> Int64 {
        Int64((date.timeIntervalSince1970 * 1_000).rounded())
    }

    private static func failure(_ database: OpaquePointer?, code: Int32) -> ChatMessageServiceError {
        let message: String = database.map { String(cString: sqlite3_errmsg($0)) } ?? String(cString: sqlite3_errstr(code))
        return .storageFailed(code: code, message: message)
    }

    // Tells SQLite to copy bound text, since Swift frees it once the call returns.
    private static var transient: sqlite3_destructor_type { unsafeBitCast(-1, to: sqlite3_destructor_type.self) }
}

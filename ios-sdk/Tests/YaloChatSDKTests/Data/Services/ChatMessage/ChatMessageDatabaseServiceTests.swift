// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import SQLite3
import Testing
@testable import YaloChatSDK

struct ChatMessageDatabaseServiceTests {
    private let service: ChatMessageDatabaseService = ChatMessageDatabaseService(fileURL: nil)

    private func message(
        _ content: String,
        at milliseconds: Int64 = 1_000,
        role: ChatMessage.Role = .user,
        wiId: String? = nil
    ) -> ChatMessage {
        ChatMessage(
            role: role,
            type: .text,
            timestamp: Date(timeIntervalSince1970: Double(milliseconds) / 1_000),
            wiId: wiId,
            content: content
        )
    }

    private static func temporaryFile() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("yalo-chat-messages-tests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("messages.sqlite")
    }

    @Test func insertReturnsTheMessageWithItsRowId() async throws {
        let original: ChatMessage = message("Hello")

        let stored: ChatMessage = try await service.insert(original, sessionId: "session-1")

        var expected: ChatMessage = original
        expected.id = stored.id
        #expect(stored.id != nil)
        #expect(stored == expected)
    }

    @Test func readsBackEveryStoredField() async throws {
        let original: ChatMessage = ChatMessage(
            role: .agent,
            type: .productCarousel,
            timestamp: Date(timeIntervalSince1970: 1_700_000_000.123),
            wiId: "wi-1",
            content: "Pick one",
            status: .delivered,
            header: "Today",
            footer: "Tap to choose"
        )

        let stored: ChatMessage = try await service.insert(original, sessionId: "session-1")

        #expect(try await service.messages(sessionId: "session-1", limit: 10) == [stored])
    }

    @Test func readsBackAVoiceNote() async throws {
        let original: ChatMessage = ChatMessage(
            role: .user,
            type: .voice,
            timestamp: Date(timeIntervalSince1970: 1_700_000_000),
            voice: VoiceNote(
                duration: 4.5,
                amplitudes: [0, 0.5, 1],
                mediaURL: "media-1",
                mimeType: "audio/mp4",
                fileName: "voice-1.m4a",
                byteCount: 2_048,
                localFileName: "voice-1.m4a"
            )
        )

        let stored: ChatMessage = try await service.insert(original, sessionId: "session-1")

        #expect(try await service.messages(sessionId: "session-1", limit: 10) == [stored])
        #expect(stored.voice == original.voice)
    }

    @Test func aVoiceNoteThisVersionCannotReadIsLeftOut() async throws {
        let file: URL = Self.temporaryFile()
        _ = try await ChatMessageDatabaseService(fileURL: file).insert(message("Hello"), sessionId: "session-1")
        var database: OpaquePointer?
        sqlite3_open(file.path, &database)
        sqlite3_exec(database, "UPDATE chat_message SET voice = 'not json'", nil, nil, nil)
        sqlite3_close(database)

        let read: [ChatMessage] = try await ChatMessageDatabaseService(fileURL: file).messages(sessionId: "session-1", limit: 10)

        #expect(read.map(\.content) == ["Hello"])
        #expect(read.first?.voice == nil)
    }

    @Test func aFileFromTheFirstVersionKeepsItsMessagesAndTakesVoiceNotes() async throws {
        let file: URL = Self.temporaryFile()
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        var database: OpaquePointer?
        sqlite3_open(file.path, &database)
        sqlite3_exec(database, """
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
            );
            CREATE UNIQUE INDEX index_chat_message_session_wi_id ON chat_message (session_id, wi_id);
            INSERT INTO chat_message (session_id, role, content, type, status, timestamp)
            VALUES ('session-1', 'USER', 'Before', 'text', 'SENT', 1000);
            PRAGMA user_version = 1;
            """, nil, nil, nil)
        sqlite3_close(database)
        let service: ChatMessageDatabaseService = ChatMessageDatabaseService(fileURL: file)

        _ = try await service.insert(
            ChatMessage(role: .user, type: .voice, timestamp: Date(timeIntervalSince1970: 2), voice: VoiceNote(duration: 1)),
            sessionId: "session-1"
        )

        let read: [ChatMessage] = try await service.messages(sessionId: "session-1", limit: 10)
        #expect(read.map(\.voice) == [VoiceNote(duration: 1), nil])
        #expect(read.last?.content == "Before")
    }

    @Test func messagesAreMostRecentFirstAndLimited() async throws {
        _ = try await service.insert(message("first", at: 1_000), sessionId: "session-1")
        _ = try await service.insert(message("third", at: 3_000), sessionId: "session-1")
        _ = try await service.insert(message("second", at: 2_000), sessionId: "session-1")

        let read: [ChatMessage] = try await service.messages(sessionId: "session-1", limit: 2)

        #expect(read.map(\.content) == ["third", "second"])
    }

    @Test func messagesWrittenAtTheSameTimeKeepTheirOrder() async throws {
        _ = try await service.insert(message("first"), sessionId: "session-1")
        _ = try await service.insert(message("second"), sessionId: "session-1")

        let read: [ChatMessage] = try await service.messages(sessionId: "session-1", limit: 10)

        #expect(read.map(\.content) == ["second", "first"])
    }

    @Test func messagesOnlyIncludeTheAskedSession() async throws {
        _ = try await service.insert(message("mine"), sessionId: "session-1")
        _ = try await service.insert(message("theirs"), sessionId: "session-2")

        let read: [ChatMessage] = try await service.messages(sessionId: "session-1", limit: 10)

        #expect(read.map(\.content) == ["mine"])
    }

    @Test func aReplayedMessageIsStoredOnce() async throws {
        let first: ChatMessage = try await service.insert(message("Hi", wiId: "wi-1"), sessionId: "session-1")

        let replayed: ChatMessage = try await service.insert(message("Hi again", wiId: "wi-1"), sessionId: "session-1")

        #expect(replayed == first)
        #expect(try await service.messages(sessionId: "session-1", limit: 10) == [first])
    }

    @Test func theSameBackendIdIsStoredOncePerSession() async throws {
        _ = try await service.insert(message("Hi", wiId: "wi-1"), sessionId: "session-1")
        _ = try await service.insert(message("Hi", wiId: "wi-1"), sessionId: "session-2")

        #expect(try await service.messages(sessionId: "session-2", limit: 10).count == 1)
    }

    @Test func messagesWithoutBackendIdAreAlwaysStored() async throws {
        _ = try await service.insert(message("Hi"), sessionId: "session-1")
        _ = try await service.insert(message("Hi"), sessionId: "session-1")

        #expect(try await service.messages(sessionId: "session-1", limit: 10).count == 2)
    }

    @Test func deleteSessionsForgetsOnlyThoseSessions() async throws {
        _ = try await service.insert(message("one"), sessionId: "session-1")
        _ = try await service.insert(message("two"), sessionId: "session-2")
        _ = try await service.insert(message("three"), sessionId: "session-3")

        try await service.deleteSessions(["session-1", "session-3", "never-stored"])

        #expect(try await service.messages(sessionId: "session-1", limit: 10).isEmpty)
        #expect(try await service.messages(sessionId: "session-2", limit: 10).map(\.content) == ["two"])
        #expect(try await service.messages(sessionId: "session-3", limit: 10).isEmpty)
    }

    @Test func deleteSessionsTakesMoreIdsThanOneStatementCanBind() async throws {
        _ = try await service.insert(message("last"), sessionId: "session-1999")
        let sessionIds: [String] = (0..<2_000).map { "session-\($0)" }

        try await service.deleteSessions(sessionIds)

        #expect(try await service.messages(sessionId: "session-1999", limit: 10).isEmpty)
    }

    @Test func deleteSessionsWithNoIdsDoesNothing() async throws {
        _ = try await service.insert(message("kept"), sessionId: "session-1")

        try await service.deleteSessions([])

        #expect(try await service.messages(sessionId: "session-1", limit: 10).count == 1)
    }

    @Test func messagesOutliveTheServiceThatStoredThem() async throws {
        let file: URL = Self.temporaryFile()
        let stored: ChatMessage = try await ChatMessageDatabaseService(fileURL: file)
            .insert(message("Hello"), sessionId: "session-1")

        let read: [ChatMessage] = try await ChatMessageDatabaseService(fileURL: file)
            .messages(sessionId: "session-1", limit: 10)

        #expect(read == [stored])
    }

    @Test func twoServicesShareOneFile() async throws {
        let file: URL = Self.temporaryFile()
        let first: ChatMessageDatabaseService = ChatMessageDatabaseService(fileURL: file)
        let second: ChatMessageDatabaseService = ChatMessageDatabaseService(fileURL: file)

        _ = try await first.insert(message("from first"), sessionId: "session-1")
        _ = try await second.insert(message("from second", at: 2_000), sessionId: "session-1")

        let read: [ChatMessage] = try await first.messages(sessionId: "session-1", limit: 10)
        #expect(read.map(\.content) == ["from second", "from first"])
    }

    @Test func aFileThatCannotBeOpenedFailsTheCall() async throws {
        let blocker: URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data("not a folder".utf8).write(to: blocker)
        let service: ChatMessageDatabaseService = ChatMessageDatabaseService(
            fileURL: blocker.appendingPathComponent("messages.sqlite")
        )

        await #expect(throws: (any Error).self) {
            try await service.messages(sessionId: "session-1", limit: 10)
        }
    }

    @Test func aFileThatIsNotADatabaseFailsWithAStorageError() async throws {
        let file: URL = Self.temporaryFile()
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(repeating: 7, count: 4_096).write(to: file)

        await #expect {
            try await ChatMessageDatabaseService(fileURL: file).messages(sessionId: "session-1", limit: 10)
        } throws: { error in
            guard case ChatMessageServiceError.storageFailed(let code, _) = error else {
                return false
            }
            return code == SQLITE_NOTADB
        }
    }

    @Test func aFolderInPlaceOfTheFileFailsWithAStorageError() async throws {
        let folder: URL = Self.temporaryFile()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        await #expect {
            try await ChatMessageDatabaseService(fileURL: folder).messages(sessionId: "session-1", limit: 10)
        } throws: { error in
            error is ChatMessageServiceError
        }
    }

    @Test func aFailedMigrationLeavesTheFileUntouched() async throws {
        let file: URL = Self.temporaryFile()
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        var database: OpaquePointer?
        sqlite3_open(file.path, &database)
        sqlite3_exec(database, "CREATE TABLE chat_message (other TEXT)", nil, nil, nil)
        sqlite3_close(database)

        await #expect(throws: ChatMessageServiceError.self) {
            try await ChatMessageDatabaseService(fileURL: file).messages(sessionId: "session-1", limit: 10)
        }

        sqlite3_open(file.path, &database)
        var version: OpaquePointer?
        sqlite3_prepare_v2(database, "PRAGMA user_version", -1, &version, nil)
        sqlite3_step(version)
        #expect(sqlite3_column_int(version, 0) == 0)
        sqlite3_finalize(version)
        sqlite3_close(database)
    }

    @Test func aReadOnlyFileFailsTheInsert() async throws {
        let file: URL = Self.temporaryFile()
        _ = try await ChatMessageDatabaseService(fileURL: file).messages(sessionId: "session-1", limit: 10)
        try FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: file.path)

        await #expect(throws: ChatMessageServiceError.self) {
            try await ChatMessageDatabaseService(fileURL: file).insert(message("Hello"), sessionId: "session-1")
        }
    }

    @Test func aRowWithAnUnknownRoleIsUnreadable() async throws {
        let file: URL = Self.temporaryFile()
        _ = try await ChatMessageDatabaseService(fileURL: file).insert(message("Hello"), sessionId: "session-1")
        var database: OpaquePointer?
        sqlite3_open(file.path, &database)
        sqlite3_exec(database, "UPDATE chat_message SET role = 'BOT'", nil, nil, nil)
        sqlite3_close(database)

        await #expect(throws: ChatMessageServiceError.unreadableRow) {
            try await ChatMessageDatabaseService(fileURL: file).messages(sessionId: "session-1", limit: 10)
        }
    }
}

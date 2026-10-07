// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

enum ChatMessageServiceError: Error, Equatable {
    case storageFailed(code: Int32, message: String)
    /// A stored row holds a value this SDK does not know how to read.
    case unreadableRow
}

/// Stores messages, however many chats an app shows. Each message belongs to
/// the session it was stored under.
protocol ChatMessageService: Sendable {
    /// Stores `message` and returns it with its row id. A message whose `wiId`
    /// is already stored in the session returns what is stored instead, so a
    /// replayed message does not show up twice.
    func insert(_ message: ChatMessage, sessionId: String) async throws -> ChatMessage

    /// Most recent first.
    func messages(sessionId: String, limit: Int) async throws -> [ChatMessage]

    /// Forgets every message of `sessionIds`. Sessions with nothing stored are no error.
    func deleteSessions(_ sessionIds: [String]) async throws
}

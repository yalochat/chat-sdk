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

    /// Last stored first. Arrival rather than timestamp, like the web SDK,
    /// since the server rounds its times down to the second and a reply could
    /// otherwise land before the message it answers.
    func messages(sessionId: String, limit: Int) async throws -> [ChatMessage]

    /// Stores how the person rated the message of row `id`. Nil clears it.
    func setFeedback(_ feedback: ChatMessage.Feedback?, id: Int64) async throws

    /// Replaces the buttons of the message of row `id`.
    func setButtons(_ buttons: [MessageButton], id: Int64) async throws

    /// Forgets every message of `sessionIds`. Sessions with nothing stored are no error.
    func deleteSessions(_ sessionIds: [String]) async throws

    /// Forgets every message of every session.
    func deleteAll() async throws
}

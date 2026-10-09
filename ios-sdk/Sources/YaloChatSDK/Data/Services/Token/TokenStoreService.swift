// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

enum TokenStoreServiceError: Error, Equatable {
    case keychainFailed(status: OSStatus)
    /// A stored token this SDK does not know how to read.
    case unreadable
}

/// Keeps one token per session on the device, so a conversation outlives the
/// app being closed.
protocol TokenStoreService: Sendable {
    /// The token stored for `sessionId`, or nil when there is none.
    func token(sessionId: String) throws -> AuthToken?

    /// `ephemeral` is kept beside the token, so a sweep can find the sessions
    /// meant to leave nothing behind.
    func save(_ token: AuthToken, sessionId: String, ephemeral: Bool) throws

    /// Sessions with nothing stored are no error.
    func delete(sessionIds: [String]) throws

    /// The sessions whose token was saved as ephemeral.
    func ephemeralSessionIds() throws -> Set<String>
}

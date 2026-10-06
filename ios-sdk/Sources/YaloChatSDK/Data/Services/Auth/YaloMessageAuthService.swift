// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

enum AuthServiceError: Error, Equatable {
    case authenticateFailed(status: Int)
    case refreshFailed(status: Int)
    case unreadableResponse
}

/// The two calls the backend offers for getting into a conversation. Nothing
/// is kept: deciding which call to make belongs to whoever keeps the token.
protocol YaloMessageAuthService: Sendable {
    /// Asks for a token for the configured channel and user.
    func authenticate() async throws -> AuthToken

    /// Trades `refreshToken` for a token, without becoming a new person.
    func refresh(_ refreshToken: String) async throws -> AuthToken
}

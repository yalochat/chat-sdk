// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// What lets the chat speak to the channel as somebody. The moment it runs
/// out is kept rather than its lifetime, so it outlives the app being closed.
struct AuthToken: Equatable, Sendable {
    let accessToken: String
    /// Buys another `accessToken` without becoming a new person. Empty when there is none.
    let refreshToken: String
    let expiresAt: Date

    func usable(at now: Date) -> Bool {
        now < expiresAt
    }
}

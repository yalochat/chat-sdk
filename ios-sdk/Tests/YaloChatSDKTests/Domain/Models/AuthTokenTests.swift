// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

struct AuthTokenTests {
    @Test func isUsableUntilItExpires() {
        let expiresAt: Date = Date(timeIntervalSince1970: 1_000)
        let token: AuthToken = AuthToken(accessToken: "a", refreshToken: "r", expiresAt: expiresAt)

        #expect(token.usable(at: expiresAt.addingTimeInterval(-1)))
        #expect(!token.usable(at: expiresAt))
    }
}

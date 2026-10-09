// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
@testable import YaloChatSDK

/// Keeps tokens in memory, and fails when told to.
final class FakeTokenStore: TokenStoreService, @unchecked Sendable {
    private let lock: NSLock = NSLock()
    private var tokens: [String: (token: AuthToken, ephemeral: Bool)] = [:]
    private var failing: Error?

    func fail(with error: Error?) {
        lock.withLock {
            failing = error
        }
    }

    func stored(_ sessionId: String) -> (token: AuthToken, ephemeral: Bool)? {
        lock.withLock {
            tokens[sessionId]
        }
    }

    func token(sessionId: String) throws -> AuthToken? {
        try lock.withLock {
            if let failing {
                throw failing
            }
            return tokens[sessionId]?.token
        }
    }

    func save(_ token: AuthToken, sessionId: String, ephemeral: Bool) throws {
        try lock.withLock {
            if let failing {
                throw failing
            }
            tokens[sessionId] = (token, ephemeral)
        }
    }

    func delete(sessionIds: [String]) throws {
        try lock.withLock {
            if let failing {
                throw failing
            }
            for sessionId in sessionIds {
                tokens[sessionId] = nil
            }
        }
    }

    func ephemeralSessionIds() throws -> Set<String> {
        try lock.withLock {
            if let failing {
                throw failing
            }
            return Set(tokens.filter { _, stored in stored.ephemeral }.keys)
        }
    }
}

extension TokenRepository {
    /// A repository whose tokens never reach the device.
    init(auth: YaloMessageAuthService, now: @escaping @Sendable () -> Date = { Date() }) {
        self.init(auth: auth, store: FakeTokenStore(), sessionId: "session-1", now: now)
    }
}

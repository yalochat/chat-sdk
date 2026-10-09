// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

private actor FakeAuthService: YaloMessageAuthService {
    private(set) var authentications: Int = 0
    private(set) var refreshes: [String] = []
    private let expiresAt: Date
    private let refreshFails: Bool
    private let authenticationFails: Bool

    init(expiresAt: Date, refreshFails: Bool = false, authenticationFails: Bool = false) {
        self.expiresAt = expiresAt
        self.refreshFails = refreshFails
        self.authenticationFails = authenticationFails
    }

    func authenticate() async throws -> AuthToken {
        authentications += 1
        // Long enough for a second caller to arrive while this one is out.
        try await Task.sleep(nanoseconds: 20_000_000)
        if authenticationFails {
            throw AuthServiceError.authenticateFailed(status: 500)
        }
        return AuthToken(accessToken: "authenticated-\(authentications)", refreshToken: "refresh", expiresAt: expiresAt)
    }

    func refresh(_ refreshToken: String) async throws -> AuthToken {
        refreshes.append(refreshToken)
        if refreshFails {
            throw AuthServiceError.refreshFailed(status: 401)
        }
        return AuthToken(accessToken: "refreshed", refreshToken: refreshToken, expiresAt: expiresAt)
    }
}

private final class TestClock: @unchecked Sendable {
    private let lock: NSLock = NSLock()
    private var current: Date = Date(timeIntervalSince1970: 1_000)

    var now: Date {
        lock.withLock {
            current
        }
    }

    func advance(by interval: TimeInterval) {
        lock.withLock {
            current = current.addingTimeInterval(interval)
        }
    }
}

struct TokenRepositoryTests {
    private let clock: TestClock = TestClock()
    private let store: FakeTokenStore = FakeTokenStore()

    private func repository(_ auth: FakeAuthService, ephemeral: Bool = false) -> TokenRepository {
        let clock: TestClock = clock
        return TokenRepository(auth: auth, store: store, sessionId: "session-1", ephemeral: ephemeral, now: { clock.now })
    }

    @Test func reusesATokenWhileItIsUsable() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        let tokens: TokenRepository = repository(auth)

        let first: String = try await tokens.token()
        let second: String = try await tokens.token()

        #expect(first == "authenticated-1")
        #expect(second == "authenticated-1")
        #expect(await auth.authentications == 1)
    }

    @Test func refreshesATokenThatRanOut() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        let tokens: TokenRepository = repository(auth)
        _ = try await tokens.token()
        clock.advance(by: 61)

        let token: String = try await tokens.token()

        #expect(token == "refreshed")
        #expect(await auth.refreshes == ["refresh"])
        #expect(await auth.authentications == 1)
    }

    @Test func authenticatesAgainWhenTheRefreshIsRefused() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60), refreshFails: true)
        let tokens: TokenRepository = repository(auth)
        _ = try await tokens.token()
        clock.advance(by: 61)

        let token: String = try await tokens.token()

        #expect(token == "authenticated-2")
    }

    @Test func aRefusedTokenIsReplacedByTheSamePerson() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        let tokens: TokenRepository = repository(auth)
        _ = try await tokens.token()

        await tokens.invalidate()
        let token: String = try await tokens.token()

        #expect(token == "refreshed")
        #expect(await auth.refreshes == ["refresh"])
    }

    @Test func invalidatingBeforeAnyTokenChangesNothing() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        let tokens: TokenRepository = repository(auth)

        await tokens.invalidate()

        #expect(try await tokens.token() == "authenticated-1")
    }

    @Test func callersAskingAtOnceShareOneExchange() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        let tokens: TokenRepository = repository(auth)

        async let first: String = tokens.token()
        async let second: String = tokens.token()
        let answers: [String] = try await [first, second]

        #expect(answers == ["authenticated-1", "authenticated-1"])
        #expect(await auth.authentications == 1)
    }

    @Test func reportsAFailedAuthenticationAndTriesAgainNextTime() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now, authenticationFails: true)
        let tokens: TokenRepository = repository(auth)

        await #expect(throws: AuthServiceError.authenticateFailed(status: 500)) {
            try await tokens.token()
        }
        _ = try? await tokens.token()

        #expect(await auth.authentications == 2)
    }

    @Test func aNewRunPicksUpTheStoredToken() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        _ = try await repository(auth).token()

        let token: String = try await repository(auth).token()

        #expect(token == "authenticated-1")
        #expect(await auth.authentications == 1)
    }

    @Test func aNewRunKeepsThePersonWhenTheStoredTokenRanOut() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        _ = try await repository(auth).token()
        clock.advance(by: 61)

        let token: String = try await repository(auth).token()

        #expect(token == "refreshed")
        #expect(await auth.authentications == 1)
        #expect(store.stored("session-1")?.token.accessToken == "refreshed")
    }

    @Test(arguments: [false, true])
    func storesWhetherTheSessionIsEphemeral(ephemeral: Bool) async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))

        _ = try await repository(auth, ephemeral: ephemeral).token()

        #expect(store.stored("session-1")?.ephemeral == ephemeral)
        #expect(await repository(auth).ephemeralSessions() == (ephemeral ? ["session-1"] : []))
    }

    @Test func aRefusedTokenIsStoredAsSpent() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        let tokens: TokenRepository = repository(auth)
        _ = try await tokens.token()

        await tokens.invalidate()

        #expect(store.stored("session-1")?.token.expiresAt == .distantPast)
    }

    @Test func aStoredTokenThatCannotBeReadIsForgotten() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        try store.save(AuthToken(accessToken: "old", refreshToken: "", expiresAt: .distantFuture), sessionId: "session-1", ephemeral: false)
        store.fail(with: TokenStoreServiceError.unreadable)
        let tokens: TokenRepository = repository(auth)

        let token: String = try await tokens.token()

        #expect(token == "authenticated-1")
    }

    @Test func aStoreThatFailsStillHandsOutTokens() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        store.fail(with: TokenStoreServiceError.keychainFailed(status: -1))
        let tokens: TokenRepository = repository(auth)

        #expect(try await tokens.token() == "authenticated-1")
        #expect(try await tokens.token() == "authenticated-1")
        #expect(await tokens.ephemeralSessions().isEmpty)
        await #expect(throws: TokenStoreServiceError.keychainFailed(status: -1)) {
            try await tokens.deleteSessions(["session-1"])
        }
    }

    @Test func deletingTheSessionForgetsTheTokenInHand() async throws {
        let auth: FakeAuthService = FakeAuthService(expiresAt: clock.now.addingTimeInterval(60))
        let tokens: TokenRepository = repository(auth)
        _ = try await tokens.token()

        try await tokens.deleteSessions(["other", "session-1"])

        #expect(store.stored("session-1") == nil)
        #expect(try await tokens.token() == "authenticated-2")
    }
}

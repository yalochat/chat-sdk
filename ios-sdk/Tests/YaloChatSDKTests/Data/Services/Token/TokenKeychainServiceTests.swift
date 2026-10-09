// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Security
import Testing
@testable import YaloChatSDK

struct TokenKeychainServiceTests {
    private let serviceName: String = "ai.yalo.chat.tests"
    private let fake: FakeKeychain = FakeKeychain()
    private let defaults: UserDefaults = UserDefaults(suiteName: "yalo-chat-tests-\(UUID().uuidString)")!
    private let token: AuthToken = AuthToken(
        accessToken: "access",
        refreshToken: "refresh",
        expiresAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    private func service() -> TokenKeychainService {
        TokenKeychainService(service: serviceName, keychain: fake.keychain, defaults: defaults)
    }

    @Test func readsBackWhatWasSaved() throws {
        try service().save(token, sessionId: "session-1", ephemeral: false)

        #expect(try service().token(sessionId: "session-1") == token)
        #expect(try service().token(sessionId: "session-2") == nil)
    }

    @Test func savingAgainReplacesTheToken() throws {
        try service().save(token, sessionId: "session-1", ephemeral: true)
        let newer: AuthToken = AuthToken(accessToken: "newer", refreshToken: "refresh", expiresAt: token.expiresAt)

        try service().save(newer, sessionId: "session-1", ephemeral: false)

        #expect(try service().token(sessionId: "session-1") == newer)
        #expect(try service().ephemeralSessionIds().isEmpty)
    }

    @Test func listsOnlyTheEphemeralSessions() throws {
        #expect(try service().ephemeralSessionIds().isEmpty)
        try service().save(token, sessionId: "kept", ephemeral: false)
        try service().save(token, sessionId: "visit-1", ephemeral: true)
        try service().save(token, sessionId: "visit-2", ephemeral: true)

        #expect(try service().ephemeralSessionIds() == ["visit-1", "visit-2"])
    }

    @Test func deleteForgetsOnlyThoseSessions() throws {
        try service().save(token, sessionId: "session-1", ephemeral: false)
        try service().save(token, sessionId: "session-2", ephemeral: false)

        try service().delete(sessionIds: ["session-1", "never-stored"])

        #expect(try service().token(sessionId: "session-1") == nil)
        #expect(try service().token(sessionId: "session-2") == token)
    }

    @Test func aNewInstallForgetsWhatAnEarlierOneLeft() throws {
        try service().save(token, sessionId: "session-1", ephemeral: false)

        defaults.removeObject(forKey: "\(serviceName).installed")

        #expect(try service().token(sessionId: "session-1") == nil)
    }

    @Test func aTokenItCannotReadIsReported() throws {
        _ = try service().token(sessionId: "session-1")
        let added: OSStatus = fake.keychain.add([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: "session-1",
            kSecValueData: Data("not json".utf8),
        ])
        #expect(added == errSecSuccess)

        #expect(throws: TokenStoreServiceError.unreadable) {
            try service().token(sessionId: "session-1")
        }
    }

    @Test func aKeychainThatFailsIsReported() throws {
        _ = try service().token(sessionId: "session-1")
        fake.failing = errSecInteractionNotAllowed
        let failure: TokenStoreServiceError = .keychainFailed(status: errSecInteractionNotAllowed)

        #expect(throws: failure) {
            try service().token(sessionId: "session-1")
        }
        #expect(throws: failure) {
            try service().save(token, sessionId: "session-1", ephemeral: false)
        }
        #expect(throws: failure) {
            try service().delete(sessionIds: ["session-1"])
        }
        #expect(throws: failure) {
            try service().ephemeralSessionIds()
        }
    }

    /// A test bundle may have no Keychain of its own, so either answer shows
    /// the call reached it with a query it understood.
    @Test func theSystemKeychainIsReached() {
        let system: TokenKeychainService.Keychain = .system
        let item: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "ai.yalo.chat.tests.\(UUID().uuidString)",
            kSecAttrAccount: "session-1",
        ]
        let reached: Set<OSStatus> = [errSecSuccess, errSecItemNotFound, errSecMissingEntitlement]

        #expect(reached.contains(system.add(item.merging([kSecValueData: Data("token".utf8)]) { _, new in new })))
        #expect(reached.contains(system.update(item, [kSecValueData: Data("newer".utf8)])))
        #expect(reached.contains(system.copyMatching(item.merging([kSecReturnData: true]) { _, new in new }).0))
        #expect(reached.contains(system.delete(item)))
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Security

/// Keeps tokens in the Keychain, one item per session.
///
/// Items are readable after the first unlock and never leave the device, the
/// same reach the Android SDK gives its keystore key. The Keychain outlives
/// the app being deleted while the messages do not, so the first use after an
/// install forgets whatever an earlier install left.
final class TokenKeychainService: TokenStoreService, @unchecked Sendable {
    /// The Security calls, swappable since a test bundle has no Keychain of its own.
    struct Keychain: Sendable {
        var copyMatching: @Sendable ([CFString: Any]) -> (OSStatus, CFTypeRef?)
        var add: @Sendable ([CFString: Any]) -> OSStatus
        var update: @Sendable ([CFString: Any], [CFString: Any]) -> OSStatus
        var delete: @Sendable ([CFString: Any]) -> OSStatus

        static let system: Keychain = Keychain(
            copyMatching: { query in
                var result: CFTypeRef?
                let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &result)
                return (status, result)
            },
            add: { attributes in
                SecItemAdd(attributes as CFDictionary, nil)
            },
            update: { query, attributes in
                SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            },
            delete: { query in
                SecItemDelete(query as CFDictionary)
            }
        )
    }

    private static let lock: NSLock = NSLock()
    private static let ephemeralMark: String = "ephemeral"
    private static let persistentMark: String = "persistent"

    private let service: String
    private let keychain: Keychain
    // Deleted with the app, unlike the Keychain, which is what tells an install apart.
    private let defaults: UserDefaults

    init(service: String = "ai.yalo.chat.token", keychain: Keychain = .system, defaults: UserDefaults = .standard) {
        self.service = service
        self.keychain = keychain
        self.defaults = defaults
    }

    func token(sessionId: String) throws -> AuthToken? {
        forgetEarlierInstalls()
        var query: [CFString: Any] = item(sessionId)
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne
        let (status, result): (OSStatus, CFTypeRef?) = keychain.copyMatching(query)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw TokenStoreServiceError.keychainFailed(status: status)
        }
        guard
            let data = result as? Data,
            let stored = try? JSONDecoder().decode(StoredToken.self, from: data)
        else {
            throw TokenStoreServiceError.unreadable
        }
        return AuthToken(
            accessToken: stored.access,
            refreshToken: stored.refresh,
            expiresAt: Date(timeIntervalSince1970: Double(stored.expiresAt) / 1_000)
        )
    }

    func save(_ token: AuthToken, sessionId: String, ephemeral: Bool) throws {
        forgetEarlierInstalls()
        let stored: StoredToken = StoredToken(
            access: token.accessToken,
            refresh: token.refreshToken,
            expiresAt: Int64((token.expiresAt.timeIntervalSince1970 * 1_000).rounded())
        )
        let attributes: [CFString: Any] = [
            kSecValueData: try JSONEncoder().encode(stored),
            kSecAttrLabel: ephemeral ? Self.ephemeralMark : Self.persistentMark,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        var status: OSStatus = keychain.update(item(sessionId), attributes)
        if status == errSecItemNotFound {
            status = keychain.add(item(sessionId).merging(attributes) { _, new in new })
        }
        guard status == errSecSuccess else {
            throw TokenStoreServiceError.keychainFailed(status: status)
        }
    }

    func delete(sessionIds: [String]) throws {
        forgetEarlierInstalls()
        for sessionId in sessionIds {
            let status: OSStatus = keychain.delete(item(sessionId))
            guard status == errSecSuccess || status == errSecItemNotFound else {
                throw TokenStoreServiceError.keychainFailed(status: status)
            }
        }
    }

    func ephemeralSessionIds() throws -> Set<String> {
        forgetEarlierInstalls()
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecReturnAttributes: true,
            kSecMatchLimit: kSecMatchLimitAll,
        ]
        let (status, result): (OSStatus, CFTypeRef?) = keychain.copyMatching(query)
        if status == errSecItemNotFound {
            return []
        }
        guard status == errSecSuccess, let items = result as? [[CFString: Any]] else {
            throw TokenStoreServiceError.keychainFailed(status: status)
        }
        return Set(items.compactMap { attributes in
            attributes[kSecAttrLabel] as? String == Self.ephemeralMark ? attributes[kSecAttrAccount] as? String : nil
        })
    }

    private func item(_ sessionId: String) -> [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: sessionId,
        ]
    }

    private func forgetEarlierInstalls() {
        let installed: String = "\(service).installed"
        Self.lock.withLock {
            guard !defaults.bool(forKey: installed) else {
                return
            }
            _ = keychain.delete([kSecClass: kSecClassGenericPassword, kSecAttrService: service])
            defaults.set(true, forKey: installed)
        }
    }
}

private struct StoredToken: Codable {
    let access: String
    let refresh: String
    /// Milliseconds since 1970, like the Android SDK.
    let expiresAt: Int64
}

// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Security
@testable import YaloChatSDK

/// Generic password items in memory, matched by service and account the way
/// the Keychain matches them. Answers `failing` to everything when it is set.
final class FakeKeychain: @unchecked Sendable {
    private let lock: NSLock = NSLock()
    private var items: [[CFString: Any]] = []
    var failing: OSStatus?

    var keychain: TokenKeychainService.Keychain {
        TokenKeychainService.Keychain(
            copyMatching: { query in self.copyMatching(query) },
            add: { attributes in self.add(attributes) },
            update: { query, attributes in self.update(query, attributes) },
            delete: { query in self.delete(query) }
        )
    }

    private func matches(_ item: [CFString: Any], _ query: [CFString: Any]) -> Bool {
        [kSecAttrService, kSecAttrAccount].allSatisfy { key in
            query[key] == nil || item[key] as? String == query[key] as? String
        }
    }

    private func copyMatching(_ query: [CFString: Any]) -> (OSStatus, CFTypeRef?) {
        lock.withLock {
            if let failing {
                return (failing, nil)
            }
            let found: [[CFString: Any]] = items.filter { item in matches(item, query) }
            guard let first = found.first else {
                return (errSecItemNotFound, nil)
            }
            if query[kSecReturnData] as? Bool == true {
                return (errSecSuccess, first[kSecValueData] as CFTypeRef?)
            }
            return (errSecSuccess, found as CFArray)
        }
    }

    private func add(_ attributes: [CFString: Any]) -> OSStatus {
        lock.withLock {
            if let failing {
                return failing
            }
            guard !items.contains(where: { item in matches(item, attributes) }) else {
                return errSecDuplicateItem
            }
            items.append(attributes)
            return errSecSuccess
        }
    }

    private func update(_ query: [CFString: Any], _ attributes: [CFString: Any]) -> OSStatus {
        lock.withLock {
            if let failing {
                return failing
            }
            guard let index = items.firstIndex(where: { item in matches(item, query) }) else {
                return errSecItemNotFound
            }
            items[index].merge(attributes) { _, new in new }
            return errSecSuccess
        }
    }

    private func delete(_ query: [CFString: Any]) -> OSStatus {
        lock.withLock {
            if let failing {
                return failing
            }
            let before: Int = items.count
            items.removeAll { item in matches(item, query) }
            return items.count < before ? errSecSuccess : errSecItemNotFound
        }
    }
}

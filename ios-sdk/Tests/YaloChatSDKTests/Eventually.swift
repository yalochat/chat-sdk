// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// Waits for `condition` to hold, for work that finishes on another task.
/// Generous, since CI machines can run the suite many times slower.
func eventually(timeout: TimeInterval = 10, _ condition: () async -> Bool) async -> Bool {
    let deadline: Date = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if await condition() {
            return true
        }
        try? await Task.sleep(nanoseconds: 5_000_000)
    }
    return await condition()
}

/// Keeps values written from several tasks.
final class Recorded<Value: Sendable>: @unchecked Sendable {
    private let lock: NSLock = NSLock()
    private var stored: [Value] = []

    var values: [Value] {
        lock.withLock {
            stored
        }
    }

    func append(_ value: Value) {
        lock.withLock {
            stored.append(value)
        }
    }
}

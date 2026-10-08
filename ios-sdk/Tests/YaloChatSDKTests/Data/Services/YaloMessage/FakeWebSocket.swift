// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
@testable import YaloChatSDK

/// A socket the test speaks for: frames pushed here are what the backend says.
final class FakeWebSocket: WebSocket, @unchecked Sendable {
    static let connectionAck: String = #"{"type":"CONNECTION_ACK_TYPE_CONNECTION_ACK","connectionId":"connection-1"}"#

    let url: URL
    private let lock: NSLock = NSLock()
    private var frames: [String] = []
    private var waiting: CheckedContinuation<String, Error>?
    private var written: [String] = []
    private var isClosed: Bool = false

    init(url: URL) {
        self.url = url
    }

    var sent: [String] {
        lock.withLock {
            written
        }
    }

    var closed: Bool {
        lock.withLock {
            isClosed
        }
    }

    func push(_ frame: String) {
        let reader: CheckedContinuation<String, Error>? = lock.withLock {
            guard let waiting else {
                frames.append(frame)
                return nil
            }
            self.waiting = nil
            return waiting
        }
        reader?.resume(returning: frame)
    }

    func write(_ frame: String) async throws {
        try lock.withLock {
            if isClosed {
                throw URLError(.networkConnectionLost)
            }
            written.append(frame)
        }
    }

    func read() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let ready: Result<String, Error>? = lock.withLock {
                if isClosed {
                    return .failure(URLError(.networkConnectionLost))
                }
                if !frames.isEmpty {
                    return .success(frames.removeFirst())
                }
                waiting = continuation
                return nil
            }
            if let ready {
                continuation.resume(with: ready)
            }
        }
    }

    func close() {
        let reader: CheckedContinuation<String, Error>? = lock.withLock {
            isClosed = true
            let reader: CheckedContinuation<String, Error>? = waiting
            waiting = nil
            return reader
        }
        reader?.resume(throwing: URLError(.networkConnectionLost))
    }
}

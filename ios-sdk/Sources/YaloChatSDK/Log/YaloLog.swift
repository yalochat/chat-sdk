// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import os

/// What the SDK says about itself, under the `ai.yalo.chat.sdk` subsystem with
/// `name` as the category.
///
/// A message is built only when it is going to be written.
///
/// No line at any level may carry a token or a signed address. What people
/// said is written only at `debug`.
struct YaloLog: Sendable {
    typealias Sink = @Sendable (LogLevel, String) -> Void

    static let subsystem: String = "ai.yalo.chat.sdk"

    private let level: LogLevel
    private let sink: Sink

    init(_ name: String, level: LogLevel = .warn, sink: Sink? = nil) {
        self.level = level
        self.sink = sink ?? Self.unified(category: name)
    }

    func debug(_ message: @autoclosure () -> String) {
        write(.debug, nil, message)
    }

    func info(_ message: @autoclosure () -> String) {
        write(.info, nil, message)
    }

    func warn(_ message: @autoclosure () -> String, error: Error? = nil) {
        write(.warn, error, message)
    }

    func error(_ message: @autoclosure () -> String, error: Error? = nil) {
        write(.error, error, message)
    }

    private func write(_ at: LogLevel, _ error: Error?, _ message: () -> String) {
        guard at != .silent, at.rank >= level.rank else {
            return
        }
        guard let error else {
            sink(at, message())
            return
        }
        sink(at, "\(message()): \(Self.describe(error))")
    }

    // A URLError carries the address it failed on, which can hold a token or a signature.
    static func describe(_ error: Error) -> String {
        if let failure = error as? URLError {
            return "URLError \(failure.code.rawValue)"
        }
        return String(describing: error)
    }

    private static func unified(category: String) -> Sink {
        let logger: Logger = Logger(subsystem: subsystem, category: category)
        return { at, line in
            switch at {
            case .debug:
                logger.debug("\(line, privacy: .public)")
            case .info:
                logger.info("\(line, privacy: .public)")
            case .warn:
                logger.warning("\(line, privacy: .public)")
            case .error:
                logger.error("\(line, privacy: .public)")
            case .silent:
                break
            }
        }
    }
}

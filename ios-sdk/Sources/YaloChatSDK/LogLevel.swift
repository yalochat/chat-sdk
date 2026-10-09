// Copyright (c) Yalochat, Inc. All rights reserved.

/// How much the SDK says about itself in the unified log.
///
/// Each level includes the ones after it, so `info` also writes warnings and
/// errors. `silent` writes nothing at all.
public enum LogLevel: Sendable {
    case debug
    case info
    case warn
    case error
    case silent
}

extension LogLevel {
    var rank: Int {
        switch self {
        case .debug:
            return 0
        case .info:
            return 1
        case .warn:
            return 2
        case .error:
            return 3
        case .silent:
            return 4
        }
    }
}

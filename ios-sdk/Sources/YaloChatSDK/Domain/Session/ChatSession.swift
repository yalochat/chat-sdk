// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// Which conversation a chat is on.
///
/// `id` scopes everything kept on the device, and `authUserId` is who the
/// backend is told it is talking to. Both carry the same suffix, so one
/// conversation on the device is one conversation on the backend. A nil
/// `authUserId` asks the backend for a fresh anonymous person.
///
/// Built like `computeSessionId` and `computeEffectiveAuthUserId` in the web
/// SDK and `sessionOf` in the Android SDK, so every client agrees on what one
/// session is.
struct ChatSession: Equatable {
    let id: String
    let authUserId: String?

    /// - Parameter ephemeralId: What tells one ephemeral chat from the next.
    ///   Ignored in the other modes.
    init(config: YaloChatClientConfig, ephemeralId: String = UUID().uuidString) {
        let suffix: String?
        switch config.sessionMode {
        case .shared:
            suffix = nil
        case .perContext:
            suffix = config.openContext.isEmpty ? nil : xxhash32(Self.json(config.openContext))
        case .ephemeral:
            suffix = ephemeralId
        }
        let base: String = config.baseSessionId
        id = suffix.map { "\(base)-\($0)" } ?? base
        authUserId = config.userId.map { userId in
            suffix.map { "\(userId)-\($0)" } ?? userId
        }
    }

    /// `context` written the way `JSON.stringify` writes it. A Swift
    /// dictionary has no order of its own, so the keys are sorted: the other
    /// SDKs hash keys in the order they were given, and agree with this one
    /// when that order is sorted.
    private static func json(_ context: [String: String]) -> String {
        let pairs: [String] = context
            .sorted { first, second in first.key < second.key }
            .map { key, value in "\(quoted(key)):\(quoted(value))" }
        return "{\(pairs.joined(separator: ","))}"
    }

    private static func quoted(_ text: String) -> String {
        var written: String = "\""
        for scalar in text.unicodeScalars {
            switch scalar {
            case "\"":
                written += "\\\""
            case "\\":
                written += "\\\\"
            case "\u{08}":
                written += "\\b"
            case "\u{0C}":
                written += "\\f"
            case "\n":
                written += "\\n"
            case "\r":
                written += "\\r"
            case "\t":
                written += "\\t"
            case _ where scalar.value < 0x20:
                written += String(format: "\\u%04x", scalar.value)
            default:
                written.unicodeScalars.append(scalar)
            }
        }
        return written + "\""
    }
}

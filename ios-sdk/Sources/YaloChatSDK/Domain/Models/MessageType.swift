// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// What a message carries. Unrecognised values read back as `unknown`.
enum MessageType: String, Equatable, Sendable {
    case text
    case image
    case voice
    case product
    case productCarousel
    case productConfirmation
    case promotion
    case video
    case attachment
    case chatStatus = "chat-status"
    case unknown

    static func of(_ wireName: String) -> MessageType {
        MessageType(rawValue: wireName) ?? .unknown
    }
}

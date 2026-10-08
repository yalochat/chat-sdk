// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// One message in a conversation.
///
/// `id` is the local row and is nil until the message is stored. `wiId` is the
/// backend's id and is nil for a message the user has just written.
/// `voice` is the recording of a voice message and nil for every other kind.
struct ChatMessage: Identifiable, Equatable, Sendable {
    enum Role: String, Equatable, Sendable {
        case user = "USER"
        case agent = "AGENT"
    }

    enum Status: String, Equatable, Sendable {
        case delivered = "DELIVERED"
        case read = "READ"
        case error = "ERROR"
        case sent = "SENT"
        case inProgress = "IN_PROGRESS"
        case clicked = "CLICKED"
    }

    var id: Int64?
    let role: Role
    let type: MessageType
    let timestamp: Date
    var wiId: String?
    var content: String
    var status: Status
    var header: String?
    var footer: String?
    var voice: VoiceNote?

    init(
        role: Role,
        type: MessageType,
        timestamp: Date,
        id: Int64? = nil,
        wiId: String? = nil,
        content: String = "",
        status: Status = .inProgress,
        header: String? = nil,
        footer: String? = nil,
        voice: VoiceNote? = nil
    ) {
        self.role = role
        self.type = type
        self.timestamp = timestamp
        self.id = id
        self.wiId = wiId
        self.content = content
        self.status = status
        self.header = header
        self.footer = footer
        self.voice = voice
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// One message in a conversation.
///
/// `id` is the local row and is nil until the message is stored. `wiId` is the
/// backend's id and is nil for a message the user has just written.
/// `voice` is the recording of a voice message and `image` the picture of an
/// image message. Both are nil for every other kind. `buttons` are the options
/// the channel attached to the message. `feedback` is how the person rated a
/// message from the channel, nil while they have not.
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

    enum Feedback: String, Equatable, Sendable {
        case thumbsUp = "THUMBS_UP"
        case thumbsDown = "THUMBS_DOWN"
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
    var buttons: [MessageButton]
    var voice: VoiceNote?
    var image: ImageAttachment?
    var feedback: Feedback?

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
        buttons: [MessageButton] = [],
        voice: VoiceNote? = nil,
        image: ImageAttachment? = nil,
        feedback: Feedback? = nil
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
        self.buttons = buttons
        self.voice = voice
        self.image = image
        self.feedback = feedback
    }
}

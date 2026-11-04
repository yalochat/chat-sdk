// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// A tappable option the channel attached to a message. `url` only means
/// something for a `link`, the one kind that leaves the conversation.
/// `selected` marks the postback the person tapped last on its message.
struct MessageButton: Equatable, Sendable, Codable {
    enum Kind: String, Equatable, Sendable, Codable {
        case reply
        case postback
        case link

        /// A kind this version does not know reads back as a reply, the one
        /// thing every button can do.
        init(from decoder: Decoder) throws {
            self = Kind(rawValue: try decoder.singleValueContainer().decode(String.self)) ?? .reply
        }
    }

    var text: String
    var kind: Kind = .reply
    var url: String?
    var selected: Bool = false
}

extension MessageButton {
    /// Buttons stored before `selected` existed read back as not selected.
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        kind = try container.decode(Kind.self, forKey: .kind)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        selected = try container.decodeIfPresent(Bool.self, forKey: .selected) ?? false
    }
}

extension ChatMessage {
    /// The buttons offered as quick replies. Answering moves the conversation
    /// on, so they are only offered until the person speaks.
    var quickReplies: [MessageButton] {
        buttons.filter { button in
            button.kind == .reply
        }
    }

    /// The buttons that stay under the message however far the conversation
    /// has moved on: postbacks, which say their text back, and links, which
    /// open their address.
    var actions: [MessageButton] {
        buttons.filter { button in
            button.kind != .reply
        }
    }
}

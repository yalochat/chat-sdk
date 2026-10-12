// Copyright (c) Yalochat, Inc. All rights reserved.

/// Where the chat shows the quick replies a message offers.
public enum QuickReplyType: Sendable, Equatable {
    /// In a bar between the conversation and the message input, holding only
    /// what the channel is offering right now.
    case modal

    /// Under the message that offered them, as part of the conversation.
    case inline
}

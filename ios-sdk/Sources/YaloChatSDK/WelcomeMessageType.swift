// Copyright (c) Yalochat, Inc. All rights reserved.

/// How the first message of a conversation is drawn.
public enum WelcomeMessageType: Sendable, Equatable {
    /// Like any other message.
    case none

    /// Alone and centered, with one quick reply per line, until the person
    /// sends something. From then on the conversation is drawn as usual.
    case verticalQuickReplies
}

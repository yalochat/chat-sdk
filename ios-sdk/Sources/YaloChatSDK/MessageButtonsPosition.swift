// Copyright (c) Yalochat, Inc. All rights reserved.

/// Where the buttons a channel message keeps are drawn.
public enum MessageButtonsPosition: Sendable, Equatable {
    /// Stacked under the bubble, each one the full width of the message.
    case belowMessage

    /// Inside the bubble, under the text, each one as wide as its text.
    case insideMessage
}

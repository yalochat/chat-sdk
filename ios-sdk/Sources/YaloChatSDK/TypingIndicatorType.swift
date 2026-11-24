// Copyright (c) Yalochat, Inc. All rights reserved.

/// What the chat shows while a reply is being written.
public enum TypingIndicatorType: Sendable, Equatable {
    /// Three animated dots.
    case threeDots

    /// The text "Writing...", which `writingIndicator` in `YaloChatTexts` can replace.
    case text
}

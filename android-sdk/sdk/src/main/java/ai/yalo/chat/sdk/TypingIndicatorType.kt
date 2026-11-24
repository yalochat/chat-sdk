// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

/** What the chat shows while a reply is being written. */
public enum class TypingIndicatorType {

    /** Three animated dots. */
    ThreeDots,

    /** The text "Writing...", which `writingIndicator` in [YaloChatTexts] can replace. */
    Text,
}

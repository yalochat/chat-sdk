// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

/** How the first message of a conversation is drawn. */
public enum class WelcomeMessageType {

    /** Like any other message. */
    None,

    /**
     * Alone and centered, with one quick reply per line, until the person
     * sends something. From then on the conversation is drawn as usual.
     */
    VerticalQuickReplies,
}

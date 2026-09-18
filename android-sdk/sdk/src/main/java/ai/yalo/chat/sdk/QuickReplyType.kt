// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

/** Where the chat puts the quick replies a message offers. */
public enum class QuickReplyType {

    /**
     * In a bar between the conversation and the message input, holding only
     * what the channel is offering right now.
     */
    Modal,

    /** Under the message that offered them, as part of the conversation. */
    Inline,
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

/**
 * How a conversation is scoped, and whether it is remembered between visits.
 *
 * Two chats that resolve to the same conversation show the same messages, so
 * this decides both what a person picks up when they come back and how far one
 * conversation reaches across an app.
 */
public enum class SessionMode {

    /**
     * One conversation per channel and user, kept between visits.
     *
     * The open context does not change which conversation is shown, so every
     * place the chat is opened from lands in the same history.
     */
    Shared,

    /**
     * One conversation per open context, kept between visits.
     *
     * Two chats opened with the same open context share a conversation. A
     * different open context starts its own, which suits a chat opened from a
     * product where each product should keep its own thread.
     */
    PerContext,

    /**
     * A fresh conversation every time, remembered nowhere.
     *
     * Nothing is left on the device once the chat is closed.
     */
    Ephemeral,
}

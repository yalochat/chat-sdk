// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

/** How a conversation is scoped, and whether it is remembered. */
public enum class SessionMode {

    /**
     * One conversation per person, remembered until the app's data is
     * cleared. What the chat was opened from makes no difference to which
     * conversation is shown.
     */
    Shared,

    /**
     * One conversation per `openContext`, remembered the same way [Shared] is.
     * Two chats opened from the same context carry on the same conversation,
     * and a different context starts its own.
     */
    PerContext,

    /**
     * A new conversation every time, and nothing left behind once it ends.
     *
     * Turning the device keeps the conversation, the same way the rest of the
     * screen survives. Starting the app again begins a new one.
     */
    Ephemeral,
}

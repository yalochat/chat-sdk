// Copyright (c) Yalochat, Inc. All rights reserved.

/// How a conversation is scoped, and whether it is remembered.
public enum SessionMode: Sendable, Equatable {
    /// One conversation per person, remembered until the app is deleted. What
    /// the chat was opened from makes no difference to which conversation is
    /// shown.
    case shared

    /// One conversation per `openContext`, remembered the same way `shared`
    /// is. Two chats opened from the same context carry on the same
    /// conversation, and a different context starts its own.
    case perContext

    /// A new conversation every time a chat is shown, and nothing left behind
    /// once it is closed.
    case ephemeral
}

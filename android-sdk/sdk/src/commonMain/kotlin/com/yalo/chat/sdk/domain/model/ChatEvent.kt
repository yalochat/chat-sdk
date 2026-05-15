// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Emitted by YaloMessageRepository.events() to drive the typing indicator lifecycle:
//   TypingStart — emitted when the user sends a message (agent is expected to reply)
//   TypingStop  — emitted when messages arrive from the server or on a fetch error
sealed class ChatEvent {
    data class TypingStart(val statusText: String) : ChatEvent()
    data object TypingStop : ChatEvent()
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.PageInfo

// Port of flutter-sdk/lib/src/ui/chat/view_models/messages/messages_state.dart
data class MessagesState(
    val messages: List<ChatMessage> = emptyList(),
    val userMessage: String = "",
    val isLoading: Boolean = false,
    val isConnected: Boolean = false,
    val chatStatus: ChatStatus = ChatStatus.Initial,
    val quickReplies: List<String> = emptyList(),
    val pageInfo: PageInfo = PageInfo(),
    // Typing indicator — mirrors Flutter's isSystemTypingMessage + chatStatusText fields.
    // Set to true + the status string when TypingStart is received; reset on TypingStop.
    val isSystemTypingMessage: Boolean = false,
    val chatStatusText: String = "",
)

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

// Port of flutter-sdk/lib/src/ui/chat/view_models/messages/messages_event.dart
sealed class MessagesEvent {
    object LoadMessages : MessagesEvent()
    object SubscribeToMessages : MessagesEvent()
    data class SendTextMessage(val text: String) : MessagesEvent()
    data class UpdateUserMessage(val value: String) : MessagesEvent()
    object ClearMessages : MessagesEvent()
    object ClearQuickReplies : MessagesEvent()
}

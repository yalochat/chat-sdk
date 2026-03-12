// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ImageData

// Port of flutter-sdk/lib/src/ui/chat/view_models/messages/messages_event.dart
sealed class MessagesEvent {
    data object LoadMessages : MessagesEvent()
    data object SubscribeToMessages : MessagesEvent()
    data class SendTextMessage(val text: String) : MessagesEvent()
    data class SendImageMessage(val imageData: ImageData) : MessagesEvent()
    // FDE-63: inserts the recorded voice message into the local store.
    data class SendVoiceMessage(val audioData: AudioData) : MessagesEvent()
    data class UpdateUserMessage(val value: String) : MessagesEvent()
    data object ClearMessages : MessagesEvent()
    data object ClearQuickReplies : MessagesEvent()
}

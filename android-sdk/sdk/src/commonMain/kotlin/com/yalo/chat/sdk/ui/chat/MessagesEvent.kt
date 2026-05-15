// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ImageData

enum class UnitType { UNIT, SUBUNIT }

sealed class MessagesEvent {
    data object LoadMessages : MessagesEvent()
    data object SubscribeToMessages : MessagesEvent()
    data class SendTextMessage(val text: String) : MessagesEvent()
    data class SendImageMessage(val imageData: ImageData) : MessagesEvent()
    data class SendVoiceMessage(val audioData: AudioData) : MessagesEvent()
    data class UpdateUserMessage(val value: String) : MessagesEvent()
    data object ClearMessages : MessagesEvent()
    data object ClearQuickReplies : MessagesEvent()
    data object SubscribeToEvents : MessagesEvent()
    data class ChatToggleMessageExpand(val messageId: Long) : MessagesEvent()
    data class ChatUpdateProductQuantity(
        val messageId: Long,
        val productSku: String,
        val unitType: UnitType,
        val quantity: Double,
    ) : MessagesEvent()
    data class RetryMessage(val messageId: Long) : MessagesEvent()
    data object PauseSync : MessagesEvent()
    data object ResumeSync : MessagesEvent()
}

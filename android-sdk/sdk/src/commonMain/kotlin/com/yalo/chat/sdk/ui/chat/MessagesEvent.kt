// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ImageData

// Port of flutter-sdk/lib/src/ui/chat/view_models/messages/messages_event.dart UnitType.
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
    // Mirrors Flutter's ChatSubscribeToEvents — starts collecting the typing events flow.
    data object SubscribeToEvents : MessagesEvent()
    // Mirrors Flutter's ChatToggleMessageExpand — toggles expand on a product list message.
    data class ChatToggleMessageExpand(val messageId: Long) : MessagesEvent()
    // Mirrors Flutter's ChatUpdateProductQuantity — updates unitsAdded or subunitsAdded on a product.
    data class ChatUpdateProductQuantity(
        val messageId: Long,
        val productSku: String,
        val unitType: UnitType,
        val quantity: Double,
    ) : MessagesEvent()
}

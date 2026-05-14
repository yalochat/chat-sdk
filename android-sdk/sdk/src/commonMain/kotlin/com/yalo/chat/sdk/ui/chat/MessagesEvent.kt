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
<<<<<<< HEAD
    data class RetryMessage(val messageId: Long) : MessagesEvent()
=======
    // Mirrors Flutter's ChatRetryMessage — re-sends a message that previously failed.
    data class RetryMessage(val messageId: Long) : MessagesEvent()
    // Mirrors Flutter's didChangeAppLifecycleState: pause/resume remote polling.
>>>>>>> 5502f3a (feat(kmp/ios/android): Flutter parity gaps — message retry, load-more cursor, lifecycle pause/resume, image error state)
    data object PauseSync : MessagesEvent()
    data object ResumeSync : MessagesEvent()
}

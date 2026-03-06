// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of MessageType enum from flutter-sdk/lib/src/domain/models/chat_message/chat_message.dart
// Unknown is the safe fallback for any unrecognized server value — never throws.
sealed class MessageType(val value: String) {
    data object Text : MessageType("text")
    data object Image : MessageType("image")
    data object Voice : MessageType("voice")
    data object Product : MessageType("product")
    data object ProductCarousel : MessageType("productCarousel")
    data object Promotion : MessageType("promotion")
    data object QuickReply : MessageType("quickReply")
    data object Unknown : MessageType("unknown")

    companion object {
        fun fromString(value: String): MessageType = when (value) {
            "text" -> Text
            "image" -> Image
            "voice" -> Voice
            "product" -> Product
            "productCarousel" -> ProductCarousel
            "promotion" -> Promotion
            "quickReply" -> QuickReply
            else -> Unknown
        }
    }
}

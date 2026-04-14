// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Unknown is the safe fallback for any unrecognized server value — never throws.
sealed class MessageType(val value: String) {
    data object Text : MessageType("text")
    data object Image : MessageType("image")
    data object Voice : MessageType("voice")
    data object Video : MessageType("video")
    data object Product : MessageType("product")
    data object ProductCarousel : MessageType("productCarousel")
    data object Promotion : MessageType("promotion")
    data object QuickReply : MessageType("quickReply")
    data object Buttons : MessageType("buttons")
    data object CTA : MessageType("cta")
    data object Unknown : MessageType("unknown")

    companion object {
        // Lazy to avoid JVM circular-initialization: companion runs before data objects
        // are fully initialized when MessageType class is first loaded.
        private val BY_VALUE: Map<String, MessageType> by lazy {
            listOf(Text, Image, Voice, Video, Product, ProductCarousel, Promotion, QuickReply, Buttons, CTA, Unknown)
                .associateBy { it.value }
        }

        fun fromString(value: String): MessageType = BY_VALUE[value] ?: Unknown
    }
}

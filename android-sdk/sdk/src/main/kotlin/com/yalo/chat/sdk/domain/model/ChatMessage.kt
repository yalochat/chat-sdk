// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of flutter-sdk/lib/src/domain/models/chat_message/chat_message.dart
// timestamp is epoch millis (Long) instead of DateTime — avoids any Android dependency.
// expand is intentionally excluded: it is a transient UI concern not persisted in DB.
data class ChatMessage(
    val id: Long? = null,
    val wiId: String? = null,
    val role: MessageRole,
    val type: MessageType,
    val status: MessageStatus = MessageStatus.IN_PROGRESS,
    val content: String = "",
    val fileName: String? = null,
    val amplitudes: List<Double> = emptyList(),
    val duration: Long? = null,
    // File size in bytes — included in the proto payload for image and voice messages.
    val byteCount: Long? = null,
    // MIME type of the media file — e.g. "image/jpeg", "audio/mp4".
    val mediaType: String? = null,
    val products: List<Product> = emptyList(),
    val quickReplies: List<QuickReply> = emptyList(),
    val timestamp: Long = System.currentTimeMillis(),
)

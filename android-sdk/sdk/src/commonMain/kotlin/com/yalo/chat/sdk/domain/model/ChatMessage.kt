// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import kotlinx.datetime.Clock

// timestamp is epoch millis (Long) instead of DateTime — avoids any Android dependency.
// expand is a transient UI flag — it is NOT persisted in DB and always defaults to false
// when messages are loaded from storage. Toggled in-memory by ChatToggleMessageExpand.
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
    // Transient UI state — not stored in DB. Defaults to false on every load from storage.
    val expand: Boolean = false,
    // Optional header/footer text for messages with buttons.
    val header: String? = null,
    val footer: String? = null,
    // Unified button list (proto 2.0). POSTBACK buttons send text; LINK buttons open URLs;
    // REPLY buttons surface as quick-reply chips above ChatInput.
    val buttons: List<Button> = emptyList(),
    val timestamp: Long = Clock.System.now().toEpochMilliseconds(),
)

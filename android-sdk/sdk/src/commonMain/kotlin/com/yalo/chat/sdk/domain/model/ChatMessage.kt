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
    val quickReplies: List<QuickReply> = emptyList(),
    // Optional header/footer text for buttons and CTA messages.
    val header: String? = null,
    val footer: String? = null,
    // Reply button labels for ButtonsMessage — tapping sends the label as a text message.
    val buttons: List<String> = emptyList(),
    // CTA buttons (text + URL) for CtaMessage — tapping opens the URL in the browser.
    val ctaButtons: List<CtaButton> = emptyList(),
    val timestamp: Long = Clock.System.now().toEpochMilliseconds(),
)

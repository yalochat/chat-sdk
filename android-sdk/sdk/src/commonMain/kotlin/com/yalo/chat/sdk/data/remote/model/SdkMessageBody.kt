// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote.model

import kotlinx.serialization.Serializable

// JSON HTTP adapter for the proto-generated SdkMessage.
// protobuf-kotlin-lite does not include JsonFormat, so we convert the proto object to this
// @Serializable class before handing it to Ktor. Field names mirror the proto3 JSON encoding
// (camelCase of the proto field names), which is what the /inapp/inbound_messages endpoint expects.
@Serializable
internal data class SdkMessageBody(
    val correlationId: String,
    val timestamp: String,
    val textMessageRequest: SdkTextMessageRequestBody? = null,
    val imageMessageRequest: SdkImageMessageRequestBody? = null,
    val voiceNoteMessageRequest: SdkVoiceNoteMessageRequestBody? = null,
    val addToCartRequest: SdkAddToCartRequestBody? = null,
    val removeFromCartRequest: SdkRemoveFromCartRequestBody? = null,
    val clearCartRequest: SdkClearCartRequestBody? = null,
    val addPromotionRequest: SdkAddPromotionRequestBody? = null,
)

// ── Text ──────────────────────────────────────────────────────────────────────

@Serializable
internal data class SdkTextMessageRequestBody(
    val content: SdkTextMessageBody,
    val timestamp: String,
)

@Serializable
internal data class SdkTextMessageBody(
    val text: String,
    val timestamp: String,
)

// ── Image ─────────────────────────────────────────────────────────────────────

@Serializable
internal data class SdkImageMessageRequestBody(
    val content: SdkImageMessageBody,
    val timestamp: String,
)

@Serializable
internal data class SdkImageMessageBody(
    val timestamp: String,
    val text: String? = null,
    val mediaUrl: String,
    val mediaType: String,
    val byteCount: Long,
    val fileName: String,
)

// ── Voice note ────────────────────────────────────────────────────────────────

@Serializable
internal data class SdkVoiceNoteMessageRequestBody(
    val content: SdkVoiceMessageBody,
    val timestamp: String,
)

@Serializable
internal data class SdkVoiceMessageBody(
    val timestamp: String,
    val mediaUrl: String,
    val mediaType: String,
    val byteCount: Long,
    val fileName: String,
    val amplitudesPreview: List<Float> = emptyList(),
    val duration: Double? = null,
)

// ── Cart operations ───────────────────────────────────────────────────────────

@Serializable
internal data class SdkAddToCartRequestBody(
    val sku: String,
    val quantity: Double,
    val timestamp: String,
    @kotlinx.serialization.SerialName("unit_type") val unitType: String? = null,
)

@Serializable
internal data class SdkRemoveFromCartRequestBody(
    val sku: String,
    val quantity: Double? = null,
    val timestamp: String,
    @kotlinx.serialization.SerialName("unit_type") val unitType: String? = null,
)

@Serializable
internal data class SdkClearCartRequestBody(
    val timestamp: String,
)

@Serializable
internal data class SdkAddPromotionRequestBody(
    val promotionId: String,
    val timestamp: String,
)


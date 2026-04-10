// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// JSON-encoded SdkMessage envelope returned by GET /inapp/messages.
// The server uses proto3 JSON encoding: camelCase field names, Timestamp as ISO 8601 string.
// Unknown fields are ignored via ignoreUnknownKeys = true on the Json instance.
@Serializable
internal data class YaloFetchMessagesResponse(
    val id: String,
    val message: SdkMessageResponseDto,
    val date: String,
    @SerialName("user_id") val userId: String,
    val status: String,
)

// Proto3 JSON for SdkMessage — the oneof payload field is inlined at this level
// using its camelCase field name (e.g. "textMessageRequest", not "Payload"/"TextMessageRequest").
// All fields are nullable so unknown/future message types skip silently in toChatMessage().
@Serializable
internal data class SdkMessageResponseDto(
    val textMessageRequest: SdkTextMessageResponseDto? = null,
    val imageMessageRequest: SdkImageMessageResponseDto? = null,
    val productMessageRequest: SdkProductMessageResponseDto? = null,
)

// ── Text ──────────────────────────────────────────────────────────────────────

@Serializable
internal data class SdkTextMessageResponseDto(
    // Nullable so a malformed TextMessageRequest (missing content) skips silently
    // rather than throwing SerializationException and failing the entire fetch batch.
    val content: SdkTextMessageContentDto? = null,
)

@Serializable
internal data class SdkTextMessageContentDto(
    val text: String,
    // Proto MessageRole JSON encoding: "MESSAGE_ROLE_USER" or "MESSAGE_ROLE_AGENT".
    // Omitted when the value is the default (MESSAGE_ROLE_UNSPECIFIED = 0).
    val role: String? = null,
)

// ── Product ───────────────────────────────────────────────────────────────────

// Proto3 JSON for ProductMessageRequest.
// orientation: "ORIENTATION_VERTICAL" → Product list, "ORIENTATION_HORIZONTAL" → ProductCarousel.
@Serializable
internal data class SdkProductMessageResponseDto(
    val products: List<SdkProductDto> = emptyList(),
    // Proto3 JSON enum value name, e.g. "ORIENTATION_VERTICAL" or "ORIENTATION_HORIZONTAL".
    // Absent when unspecified — treated as vertical (list) in toChatMessage().
    val orientation: String? = null,
)

// Mirrors proto Product message fields (proto3 JSON camelCase encoding).
@Serializable
internal data class SdkProductDto(
    val sku: String,
    val name: String,
    val price: Double,
    val imagesUrl: List<String> = emptyList(),
    val salePrice: Double? = null,
    val subunits: Double = 1.0,
    val unitStep: Double = 1.0,
    val unitName: String = "",
    val subunitName: String? = null,
    val subunitStep: Double = 1.0,
    val unitsAdded: Double = 0.0,
    val subunitsAdded: Double = 0.0,
)

// ── Image ─────────────────────────────────────────────────────────────────────

@Serializable
internal data class SdkImageMessageResponseDto(
    val content: SdkImageMessageContentDto? = null,
)

@Serializable
internal data class SdkImageMessageContentDto(
    // URL of the media file on the CDN — used to download the image bytes.
    val mediaUrl: String,
    // MIME type as declared by the sender; may be empty string if not set.
    val mediaType: String = "",
    // Optional caption text accompanying the image.
    val text: String? = null,
    val role: String? = null,
)

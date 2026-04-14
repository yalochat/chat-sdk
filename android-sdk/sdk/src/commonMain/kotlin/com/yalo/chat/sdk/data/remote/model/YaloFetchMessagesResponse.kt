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
    val videoMessageRequest: SdkVideoMessageResponseDto? = null,
    val productMessageRequest: SdkProductMessageResponseDto? = null,
    val buttonsMessageRequest: SdkButtonsMessageResponseDto? = null,
    val ctaMessageRequest: SdkCtaMessageResponseDto? = null,
)

// ── Text ──────────────────────────────────────────────────────────────────────

@Serializable
internal data class SdkTextMessageResponseDto(
    val content: SdkTextMessageContentDto? = null,
)

@Serializable
internal data class SdkTextMessageContentDto(
    val text: String,
    val role: String? = null,
)

// ── Product ───────────────────────────────────────────────────────────────────

@Serializable
internal data class SdkProductMessageResponseDto(
    val products: List<SdkProductDto> = emptyList(),
    val orientation: String? = null,
)

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
    val mediaUrl: String,
    val mediaType: String = "",
    val text: String? = null,
    val role: String? = null,
)

// ── Video ─────────────────────────────────────────────────────────────────────

// Port of flutter-sdk videoMessageRequest handling in _translateMessageResponse.
@Serializable
internal data class SdkVideoMessageResponseDto(
    val content: SdkVideoMessageContentDto? = null,
)

@Serializable
internal data class SdkVideoMessageContentDto(
    val mediaUrl: String,
    val mediaType: String = "",
    val text: String? = null,
    val role: String? = null,
    val fileName: String = "",
    // Duration in seconds (proto double); stored as Long millis in ChatMessage.
    val duration: Double = 0.0,
)

// ── Buttons ───────────────────────────────────────────────────────────────────

// Port of flutter-sdk buttonsMessageRequest — ButtonsMessage proto.
@Serializable
internal data class SdkButtonsMessageResponseDto(
    val content: SdkButtonsMessageContentDto? = null,
)

@Serializable
internal data class SdkButtonsMessageContentDto(
    val header: String? = null,
    val body: String = "",
    val footer: String? = null,
    val buttons: List<String> = emptyList(),
)

// ── CTA ───────────────────────────────────────────────────────────────────────

// Port of flutter-sdk ctaMessageRequest — CTAMessage proto.
@Serializable
internal data class SdkCtaMessageResponseDto(
    val content: SdkCtaMessageContentDto? = null,
)

@Serializable
internal data class SdkCtaMessageContentDto(
    val header: String? = null,
    val body: String = "",
    val footer: String? = null,
    val buttons: List<SdkCtaButtonDto> = emptyList(),
)

@Serializable
internal data class SdkCtaButtonDto(
    val text: String,
    val url: String,
)

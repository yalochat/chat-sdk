// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote.model

import kotlinx.serialization.Serializable
import yalo.external_channel.in_app.sdk.v1.SdkMessageOuterClass

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
// Mirrors proto ImageMessageRequest / ImageMessage.

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
// Mirrors proto VoiceNoteMessageRequest / VoiceMessage.

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

// ── Converter ─────────────────────────────────────────────────────────────────

// Converts a proto-generated SdkMessage to the JSON-serializable body sent to the backend.
// isoTimestamp is the ISO 8601 wall-clock string already computed by the caller so we don't
// re-convert the proto Timestamp.
internal fun SdkMessageOuterClass.SdkMessage.toBody(isoTimestamp: String): SdkMessageBody =
    SdkMessageBody(
        correlationId = correlationId,
        timestamp = isoTimestamp,
        textMessageRequest = if (hasTextMessageRequest()) SdkTextMessageRequestBody(
            content = SdkTextMessageBody(
                text = textMessageRequest.content.text,
                timestamp = isoTimestamp,
            ),
            timestamp = isoTimestamp,
        ) else null,
    )

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
)

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

// Converts a proto-generated SdkMessage to the JSON-serializable body sent to the backend.
// isoTimestamp is the ISO 8601 wall-clock string already computed by the caller so we don't
// re-convert the proto Timestamp (which would lose the exact string form used elsewhere).
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

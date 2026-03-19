// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// JSON-encoded SdkMessage envelope returned by GET /inapp/messages.
// The backend serialises the proto oneof field name in PascalCase ("Payload", "TextMessageRequest")
// so @SerialName is required to match those keys exactly.
@Serializable
internal data class YaloFetchMessagesResponse(
    val id: String,
    val message: SdkMessageResponseDto,
    val date: String,
    @SerialName("user_id") val userId: String,
    val status: String,
)

@Serializable
internal data class SdkMessageResponseDto(
    val timestamp: ProtoTimestampDto? = null,
    // Default to empty payload so unknown/future message types don't cause SerializationException
    // and crash the entire fetch batch — they are silently skipped in toChatMessage().
    @SerialName("Payload") val payload: SdkPayloadDto = SdkPayloadDto(),
)

// google.protobuf.Timestamp JSON encoding: {seconds, nanos}.
@Serializable
internal data class ProtoTimestampDto(
    val seconds: Long,
    val nanos: Int = 0,
)

// oneof payload — only one field is set per message.
// Future milestones will add VoiceMessageRequest, ImageMessageRequest, etc.
@Serializable
internal data class SdkPayloadDto(
    @SerialName("TextMessageRequest") val textMessageRequest: SdkTextMessageResponseDto? = null,
)

@Serializable
internal data class SdkTextMessageResponseDto(
    val content: SdkTextMessageContentDto,
)

@Serializable
internal data class SdkTextMessageContentDto(
    val text: String,
    // Proto MessageRole JSON encoding: "MESSAGE_ROLE_USER" or "MESSAGE_ROLE_AGENT".
    // Omitted when the value is the default (MESSAGE_ROLE_UNSPECIFIED = 0).
    val role: String? = null,
)

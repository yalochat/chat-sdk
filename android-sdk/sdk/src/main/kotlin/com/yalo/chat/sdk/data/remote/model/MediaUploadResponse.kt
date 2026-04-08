// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// Response from POST /all/media.
// The `id` field is used as `mediaUrl` in ImageMessageRequest and VoiceNoteMessageRequest protos.
@Serializable
internal data class MediaUploadResponse(
    val id: String,
    @SerialName("signed_url") val signedUrl: String,
    @SerialName("original_name") val originalName: String,
    val type: String,
    @SerialName("created_at") val createdAt: String,
    @SerialName("expires_at") val expiresAt: String,
)

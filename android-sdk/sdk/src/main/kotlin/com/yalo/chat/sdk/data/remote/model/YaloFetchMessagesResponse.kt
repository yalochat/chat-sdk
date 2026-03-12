// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// Port of flutter-sdk YaloFetchMessagesResponse + YaloMessage.
// snake_case server fields are mapped via @SerialName.
@Serializable
internal data class YaloFetchMessagesResponse(
    val id: String,
    val message: YaloMessageDto,
    val date: String,
    @SerialName("user_id") val userId: String,
    val status: String,
)

@Serializable
data class YaloMessageDto(
    val text: String,
    val role: String,
)

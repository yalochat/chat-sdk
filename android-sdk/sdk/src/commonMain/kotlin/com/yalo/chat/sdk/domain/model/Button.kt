// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

enum class ChatButtonType {
    @SerialName("REPLY") REPLY,
    @SerialName("POSTBACK") POSTBACK,
    @SerialName("LINK") LINK,
}

@Serializable
data class ChatButton(
    val text: String,
    val type: ChatButtonType,
    val url: String? = null,
)

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

enum class ButtonType {
    @SerialName("REPLY") REPLY,
    @SerialName("POSTBACK") POSTBACK,
    @SerialName("LINK") LINK,
}

@Serializable
data class Button(
    val text: String,
    val type: ButtonType,
    val url: String? = null,
)

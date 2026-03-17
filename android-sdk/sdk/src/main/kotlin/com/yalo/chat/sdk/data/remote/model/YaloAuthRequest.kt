// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
internal data class YaloAuthRequest(
    @SerialName("user_type") val userType: String = "anonymous",
    @SerialName("channel_id") val channelId: String,
    @SerialName("organization_id") val organizationId: String,
    val timestamp: Long,
)

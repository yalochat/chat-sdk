// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

internal const val USER_TYPE_ANONYMOUS = "anonymous"

@Serializable
internal data class YaloAuthRequest(
    @SerialName("user_type") val userType: String = USER_TYPE_ANONYMOUS,
    @SerialName("channel_id") val channelId: String,
    @SerialName("organization_id") val organizationId: String,
    val timestamp: Long,
)

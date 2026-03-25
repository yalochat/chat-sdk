// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote.model

import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

internal const val USER_TYPE_ANONYMOUS = "anonymous"

// @EncodeDefault ensures "user_type" is always present in the serialized JSON even though
// it has a Kotlin default value — kotlinx.serialization omits defaulted fields by default,
// but the API's required-field validation rejects requests without it.
@OptIn(ExperimentalSerializationApi::class)
@Serializable
internal data class YaloAuthRequest(
    @EncodeDefault(EncodeDefault.Mode.ALWAYS)
    @SerialName("user_type") val userType: String = USER_TYPE_ANONYMOUS,
    @SerialName("channel_id") val channelId: String,
    @SerialName("organization_id") val organizationId: String,
    val timestamp: Long,
)

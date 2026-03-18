// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.services.auth.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// Port of the anonymous-auth request body sent to POST /auth.
// snake_case fields are mapped via @SerialName to match the server contract.
@Serializable
internal data class YaloAuthRequest(
    @SerialName("user_type") val userType: String,
    @SerialName("channel_id") val channelId: String,
    @SerialName("organization_id") val organizationId: String,
    val timestamp: Long,
)

// Port of the token response body returned by both POST /auth and POST /oauth/token.
@Serializable
internal data class YaloAuthResponse(
    @SerialName("access_token") val accessToken: String,
    @SerialName("refresh_token") val refreshToken: String,
    @SerialName("expires_in") val expiresIn: Int,
)

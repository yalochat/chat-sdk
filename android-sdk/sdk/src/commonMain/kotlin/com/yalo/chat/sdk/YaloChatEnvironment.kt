// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

/** Selects which Yalo backend the SDK connects to. */
enum class YaloChatEnvironment(
    internal val apiBaseUrl: String,
    internal val wsBaseUrl: String,
) {
    PRODUCTION(
        apiBaseUrl = "https://api.yalochat.com/public-api-gateway/v1/channels",
        wsBaseUrl  = "wss://api.yalochat.com/public-api-gateway",
    ),
    STAGING(
        apiBaseUrl = "https://api-staging2.yalochat.com/public-api-gateway/v1/channels",
        wsBaseUrl  = "wss://api-staging2.yalochat.com/public-api-gateway",
    ),
}

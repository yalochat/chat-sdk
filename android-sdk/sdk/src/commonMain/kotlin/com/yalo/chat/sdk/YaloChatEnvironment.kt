// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

/** Selects which Yalo backend the SDK connects to. */
enum class YaloChatEnvironment(internal val apiBaseUrl: String) {
    PRODUCTION("https://api.yalochat.com/public-api-gateway/v1/channels"),
    STAGING("https://api-staging2.yalochat.com/public-api-gateway/v1/channels"),
}

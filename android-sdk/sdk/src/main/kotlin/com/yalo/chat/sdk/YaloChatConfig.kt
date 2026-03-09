// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

// Port of flutter-sdk YaloChatConfig.
// Phase 2 will add apiBaseUrl, theme, and other settings.
data class YaloChatConfig(
    val name: String,
    val flowKey: String,
    val authToken: String,
    val userToken: String,
)

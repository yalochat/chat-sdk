// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

// Port of flutter-sdk YaloChatConfig.
// Phase 2 M1 adds apiBaseUrl — required for real Ktor networking.
// Phase 2 M5 will add theme and other polish settings.
data class YaloChatConfig(
    val name: String,
    val flowKey: String,
    val authToken: String,
    val userToken: String,
    val apiBaseUrl: String,
)

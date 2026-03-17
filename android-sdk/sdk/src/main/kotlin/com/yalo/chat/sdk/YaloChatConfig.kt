// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import com.yalo.chat.sdk.ui.theme.ChatTheme

/**
 * Configuration passed to [YaloChat.init].
 *
 * @param name      Display name shown in the chat app bar.
 * @param flowKey   Yalo flow key that identifies the conversation flow.
 * @param authToken Bearer token for API authentication.
 * @param userToken Token identifying the end user.
 * @param apiBaseUrl Base URL for the Yalo Chat API (no trailing slash).
 * @param theme     Visual theme for the chat UI. Defaults to [ChatTheme.Default],
 *                  which matches the Flutter SDK's built-in light theme.
 *                  Use [ChatTheme.fromMaterialTheme] to inherit the host app's
 *                  Material color scheme automatically.
 */
data class YaloChatConfig(
    val name: String,
    val flowKey: String,
    val authToken: String,
    val userToken: String,
    val apiBaseUrl: String,
    val theme: ChatTheme = ChatTheme.Default,
)

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import com.yalo.chat.sdk.ui.theme.ChatTheme

/**
 * Configuration passed to [YaloChat.init].
 *
 * Mirrors Flutter SDK's `YaloChatClient` constructor so integrating teams use the same
 * credential names across both platforms.
 *
 * @param name           Display name shown in the chat app bar.
 * @param channelId      Yalo channel identifier (maps to `x-channel-id` request header).
 * @param organizationId Yalo organization identifier (used during anonymous authentication).
 * @param apiBaseUrl     Base URL for the Yalo Chat API (no trailing slash, no `/webchat` suffix).
 * @param theme          Visual theme for the chat UI. Defaults to [ChatTheme.Default],
 *                       which matches the Flutter SDK's built-in light theme.
 *                       Use [ChatTheme.fromMaterialTheme] to inherit the host app's
 *                       Material color scheme automatically.
 */
data class YaloChatConfig(
    val name: String,
    val channelId: String,
    val organizationId: String,
    val apiBaseUrl: String,
    val theme: ChatTheme = ChatTheme.Default,
)

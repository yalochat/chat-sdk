// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import com.yalo.chat.sdk.ui.theme.ChatTheme

/**
 * Configuration passed to [YaloChat.init].
 *
 * Mirrors Flutter SDK's `YaloChatClient` constructor so integrating teams use the same
 * credential names across both platforms.
 *
 * @param channelName        Display name shown in the chat app bar.
 * @param channelId          Yalo channel identifier (maps to `x-channel-id` request header).
 * @param organizationId     Yalo organization identifier (used during anonymous authentication).
 * @param theme              Visual theme for the chat UI. Defaults to [ChatTheme.Default],
 *                           which matches the Flutter SDK's built-in light theme.
 *                           Use [ChatTheme.fromMaterialTheme] to inherit the host app's
 *                           Material color scheme automatically.
 * @param useFakeRepository  When `true`, the SDK uses [com.yalo.chat.sdk.data.repository.fake.FakeYaloMessageRepository]
 *                           with pre-seeded messages instead of the real network repository.
 *                           Intended for local development and UI testing only — never set in production.
 */
data class YaloChatConfig(
    val channelName: String,
    val channelId: String,
    val organizationId: String,
    val theme: ChatTheme = ChatTheme.Default,
    val useFakeRepository: Boolean = false,
)

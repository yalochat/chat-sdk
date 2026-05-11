// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

/**
 * Configuration passed to the SDK entry point on each platform.
 *
 * Mirrors Flutter SDK's `YaloChatClient` constructor so integrating teams use the same
 * credential names across all platforms.
 *
 * @param channelName      Display name shown in the chat app bar.
 * @param channelId        Yalo channel identifier (maps to `x-channel-id` request header).
 * @param organizationId   Yalo organization identifier (used during anonymous authentication).
 * @param environment      Target backend environment. Defaults to [YaloChatEnvironment.PRODUCTION].
 * @param userId           Optional external user identifier. When set, auth uses
 *                         `user_type: "third_party_anonymous"` and binds the session to this id.
 * @param useFakeRepository For development/testing only. Replaces network calls with local
 *                         seed data. Must not be set to true in production builds.
 */
data class YaloChatConfig(
    val channelName: String,
    val channelId: String,
    val organizationId: String,
    val environment: YaloChatEnvironment = YaloChatEnvironment.PRODUCTION,
    val userId: String? = null,
    val useFakeRepository: Boolean = false,
)

/** Selects the real-time transport — SDK build-time flag, not exposed to integrators. */
internal enum class Transport { LONG_POLL, WEBSOCKET }

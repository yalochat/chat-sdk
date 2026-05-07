// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

/** Selects the real-time transport used to receive incoming messages. */
enum class Transport {
    /** HTTP polling on a 1-second interval (default — no extra config required). */
    LONG_POLL,
    /** WebSocket connection with automatic reconnect and exponential back-off. */
    WEBSOCKET,
}

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
 * @param transport        Incoming-message transport. Defaults to [Transport.LONG_POLL].
 * @param useFakeRepository When `true`, uses in-memory fake repositories with pre-seeded messages.
 *                          Intended for local development and UI testing only — never set in production.
 */
data class YaloChatConfig(
    val channelName: String,
    val channelId: String,
    val organizationId: String,
    val environment: YaloChatEnvironment = YaloChatEnvironment.PRODUCTION,
    val transport: Transport = Transport.LONG_POLL,
    val useFakeRepository: Boolean = false,
)

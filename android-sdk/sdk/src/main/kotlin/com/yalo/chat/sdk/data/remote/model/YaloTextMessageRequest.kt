// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote.model

import kotlinx.serialization.Serializable

// Port of flutter-sdk YaloTextMessageRequest + YaloTextMessage.
// The outer wrapper carries the epoch-second timestamp of the send request;
// the inner content carries the message payload.
@Serializable
data class YaloTextMessageRequest(
    val timestamp: Long,
    val content: YaloTextMessage,
)

@Serializable
data class YaloTextMessage(
    val timestamp: Long,
    val text: String,
    val status: String,
    val role: String,
)

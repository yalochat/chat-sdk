// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of MessageRole enum from flutter-sdk/lib/src/domain/models/chat_message/chat_message.dart
// Flutter: user('USER'), assistant('AGENT')
enum class MessageRole(val value: String) {
    USER("USER"),
    AGENT("AGENT");

    companion object {
        // Accepts both the legacy short form ("USER", "AGENT") and the proto3 JSON enum name
        // ("MESSAGE_ROLE_USER", "MESSAGE_ROLE_AGENT") so old and new API responses both parse.
        fun fromString(value: String): MessageRole = when (value) {
            "USER", "MESSAGE_ROLE_USER" -> USER
            "AGENT", "MESSAGE_ROLE_AGENT" -> AGENT
            else -> AGENT
        }
    }
}

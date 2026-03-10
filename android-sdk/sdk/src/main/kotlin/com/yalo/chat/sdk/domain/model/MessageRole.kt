// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of MessageRole enum from flutter-sdk/lib/src/domain/models/chat_message/chat_message.dart
// Flutter: user('USER'), assistant('AGENT')
enum class MessageRole(val value: String) {
    USER("USER"),
    AGENT("AGENT");

    companion object {
        fun fromString(value: String): MessageRole = entries.firstOrNull { it.value == value } ?: AGENT
    }
}

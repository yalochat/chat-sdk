// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of MessageRole enum from flutter-sdk/lib/src/domain/models/chat_message/chat_message.dart
// and proto/events/external_channel/in_app/sdk/sdk_message.proto.
// Flutter: user('USER'), assistant('AGENT'). Proto adds UNSPECIFIED as the zero-value sentinel.
enum class MessageRole(val value: String) {
    UNSPECIFIED("UNSPECIFIED"),
    USER("USER"),
    AGENT("AGENT");

    companion object {
        fun fromString(value: String): MessageRole = entries.firstOrNull { it.value == value } ?: AGENT
    }
}

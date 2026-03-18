// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of ResponseStatus enum from proto/events/external_channel/in_app/sdk/sdk_message.proto
// Indicates whether a channel operation succeeded or failed.
enum class ResponseStatus(val value: String) {
    UNSPECIFIED("UNSPECIFIED"),
    SUCCESS("SUCCESS"),
    ERROR("ERROR");

    companion object {
        fun fromString(value: String): ResponseStatus =
            entries.firstOrNull { it.value == value } ?: UNSPECIFIED
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

enum class MessageStatus(val value: String) {
    SENT("SENT"),
    DELIVERED("DELIVERED"),
    READ("READ"),
    IN_PROGRESS("IN_PROGRESS"),
    ERROR("ERROR");

    companion object {
        fun fromString(value: String): MessageStatus = entries.firstOrNull { it.value == value } ?: IN_PROGRESS
    }
}

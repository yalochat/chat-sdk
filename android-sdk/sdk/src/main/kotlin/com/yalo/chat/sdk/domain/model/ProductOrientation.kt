// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of ProductMessageRequest.Orientation from proto/events/external_channel/in_app/sdk/sdk_message.proto
// Controls how the product list is rendered in the client UI.
enum class ProductOrientation(val value: String) {
    UNSPECIFIED("UNSPECIFIED"),
    VERTICAL("VERTICAL"),
    HORIZONTAL("HORIZONTAL"); // Carousel

    companion object {
        fun fromString(value: String): ProductOrientation =
            entries.firstOrNull { it.value == value } ?: UNSPECIFIED
    }
}

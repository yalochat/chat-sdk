// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import kotlinx.serialization.Serializable

// A CTA button has a display label and a URL to open when tapped.
@Serializable
data class CtaButton(
    val text: String,
    val url: String,
)

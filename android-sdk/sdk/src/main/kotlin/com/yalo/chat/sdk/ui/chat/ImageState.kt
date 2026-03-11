// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.domain.model.ImageData

// Port of flutter-sdk/lib/src/ui/chat/view_models/image/image_state.dart
internal data class ImageState(
    // Image selected from gallery or captured by camera, awaiting user confirmation.
    val pickedImage: ImageData? = null,
    // True while the preview overlay is shown above the chat input.
    val isPreviewVisible: Boolean = false,
)

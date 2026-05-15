// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.domain.model.ImageData

internal data class ImageState(
    // Image selected from gallery or captured by camera, awaiting user confirmation.
    val pickedImage: ImageData? = null,
    // True while the preview overlay is shown above the chat input.
    val isPreviewVisible: Boolean = false,
    // Non-null while a Snackbar error is pending (e.g. failed gallery save or camera setup).
    // Cleared by ImageEvent.DismissError after the Snackbar is shown.
    val errorMessage: String? = null,
)

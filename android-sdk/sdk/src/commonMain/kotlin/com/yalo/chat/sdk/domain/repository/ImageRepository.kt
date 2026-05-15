// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ImageData

// Cancelled picker returns Result.Error — never null.
interface ImageRepository {
    suspend fun pickFromGallery(): Result<ImageData>
    suspend fun pickFromCamera(): Result<ImageData>
}

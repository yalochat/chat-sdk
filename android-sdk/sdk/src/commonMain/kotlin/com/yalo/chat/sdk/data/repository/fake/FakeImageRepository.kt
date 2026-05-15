// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ImageData
import com.yalo.chat.sdk.domain.repository.ImageRepository

// Stub — returns a fixed ImageData. No permission or picker involved.
class FakeImageRepository : ImageRepository {

    override suspend fun pickFromGallery(): Result<ImageData> =
        Result.Ok(ImageData(path = "fake_image.jpg"))

    override suspend fun pickFromCamera(): Result<ImageData> =
        Result.Ok(ImageData(path = "fake_image.jpg"))
}

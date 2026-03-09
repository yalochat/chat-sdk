// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ImageData
import com.yalo.chat.sdk.domain.repository.ImageRepository

// Phase 1 stub — returns a fixed ImageData. No permission or picker involved.
// Replaced in Phase 2 by ImageRepositoryLocal (Activity Result API, FDE-57).
class FakeImageRepository : ImageRepository {

    override suspend fun pickFromGallery(): Result<ImageData> =
        Result.Ok(ImageData(path = "fake_image.jpg"))

    override suspend fun pickFromCamera(): Result<ImageData> =
        Result.Ok(ImageData(path = "fake_image.jpg"))
}

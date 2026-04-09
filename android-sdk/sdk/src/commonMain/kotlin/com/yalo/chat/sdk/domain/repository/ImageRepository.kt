// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ImageData

// Port of flutter-sdk/lib/src/data/repositories/image/image_repository.dart
// Phase 1: implemented by FakeImageRepository (no-ops).
// Phase 2: implemented by ImageRepositoryLocal (Activity Result API).
// Cancelled picker returns Result.Error — never null.
interface ImageRepository {
    suspend fun pickFromGallery(): Result<ImageData>
    suspend fun pickFromCamera(): Result<ImageData>
}

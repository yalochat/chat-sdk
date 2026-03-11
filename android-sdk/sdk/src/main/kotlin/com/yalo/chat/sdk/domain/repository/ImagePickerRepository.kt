// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.local.CameraCapture
import com.yalo.chat.sdk.domain.model.ImageData

// Abstraction over platform image-pick operations used by ImageViewModel.
// Separated from ImageRepository (which mirrors the flutter-sdk pickImage API) because
// Android's Activity Result API requires the ViewModel to trigger side effects and
// receive results indirectly rather than awaiting a single suspend call.
//
// All URIs are passed as Strings so this interface (and the ViewModel that depends on it)
// is free of android.net.Uri — safe for KMP and JVM unit tests.
//
// ImageRepositoryLocal (in data/local) provides the Android implementation;
// FakeImagePickerRepository (in data/repository/fake) provides the JVM test double.
internal interface ImagePickerRepository {
    // Creates a FileProvider URI string + backing File for the camera capture intent.
    fun createCameraCapture(): CameraCapture

    // Copies a gallery content URI (as String) to internal storage and returns stable ImageData.
    suspend fun saveGalleryUri(uriString: String): Result<ImageData>
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.CameraCapture
import com.yalo.chat.sdk.domain.model.ImageData
import com.yalo.chat.sdk.domain.repository.ImagePickerRepository
import java.io.File

// JVM test double for ImagePickerRepository.
// Returns fixed in-memory values — no Android Context, FileProvider, or ContentResolver needed.
internal class FakeImagePickerRepository(
    private val cameraFile: File = File("fake_camera.jpg"),
    private val galleryImageData: ImageData = ImageData(path = "fake_gallery.jpg"),
    private val saveError: Exception? = null,
    // Set to make createCameraCapture() throw — tests the ViewModel's error handling path.
    private val captureError: Exception? = null,
) : ImagePickerRepository {

    override fun createCameraCapture(): CameraCapture {
        if (captureError != null) throw captureError
        return CameraCapture(uriString = "content://fake/camera", file = cameraFile)
    }

    override suspend fun saveGalleryUri(uriString: String): Result<ImageData> =
        if (saveError != null) Result.Error(saveError) else Result.Ok(galleryImageData)
}

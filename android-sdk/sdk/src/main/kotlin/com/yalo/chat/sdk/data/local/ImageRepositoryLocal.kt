// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.local

import android.content.Context
import android.net.Uri
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.CameraCapture
import com.yalo.chat.sdk.domain.model.ImageData
import com.yalo.chat.sdk.domain.repository.ImagePickerRepository
import java.io.File
import java.io.IOException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

// Port of flutter-sdk ImageRepositoryLocal (image_picker + image_gallery_saver).
// Handles two concerns:
//   1. createCameraCapture() — creates a FileProvider URI for camera intent + backing File reference.
//   2. saveGalleryUri()      — copies a gallery content URI to internal cache for a stable path.
// URI strings are used in the domain/ViewModel layer (KMP-compatible); android.net.Uri is
// used only at the Android platform boundary inside this class.
// Phase 2 M3 (FDE-57).
internal class ImageRepositoryLocal(private val context: Context) : ImagePickerRepository {

    // Creates a temp File in cache and wraps it in a FileProvider content URI string.
    // The returned CameraCapture carries:
    //   uriString — passed to TakePicture intent so the camera writes to our cache.
    //   file      — kept by ImageViewModel; on capture success, path is taken directly.
    override fun createCameraCapture(): CameraCapture {
        val dir = File(context.cacheDir, "yalo_camera").also { it.mkdirs() }
        val file = File(dir, "capture_${System.currentTimeMillis()}.jpg")
        val authority = "${context.packageName}.yalo.fileprovider"
        val uri = FileProvider.getUriForFile(context, authority, file)
        return CameraCapture(uriString = uri.toString(), file = file)
    }

    // Copies a gallery content URI (passed as a string) into the SDK's internal cache.
    // Returns a stable ImageData(path, mimeType) usable after the picker closes.
    // Content URIs from PickVisualMedia are only readable while the picker session is active,
    // so copying ensures the image remains accessible when the user taps Send.
    override suspend fun saveGalleryUri(uriString: String): Result<ImageData> =
        withContext(Dispatchers.IO) {
            try {
                val uri = Uri.parse(uriString)
                val mimeType = context.contentResolver.getType(uri) ?: "image/jpeg"
                val ext = MimeTypeMap.getSingleton().getExtensionFromMimeType(mimeType) ?: "jpg"
                val dir = File(context.cacheDir, "yalo_images").also { it.mkdirs() }
                val dest = File(dir, "img_${System.currentTimeMillis()}.$ext")
                val stream = context.contentResolver.openInputStream(uri)
                    ?: return@withContext Result.Error(IOException("Could not open stream for URI: $uri"))
                stream.use { input ->
                    dest.outputStream().use { output -> input.copyTo(output) }
                }
                Result.Ok(ImageData(path = dest.absolutePath, mimeType = mimeType))
            } catch (e: Exception) {
                Result.Error(e)
            }
        }
}

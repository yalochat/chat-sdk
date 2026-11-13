// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.image

import ai.yalo.chat.sdk.data.datasources.media.MediaContent
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.MediaStore

/** Reads whatever the person picked out of the gallery. */
internal interface ImageDataSource {

    /**
     * Describes what [uri] points at, or nothing when the device will not say.
     * Blocking, because it asks another process.
     */
    fun content(uri: Uri): MediaContent?

    /**
     * The path of the folder holding what [uri] points at, such as
     * `Pictures/Screenshots`, or nothing when the device will not say.
     * Blocking, because it asks another process.
     */
    fun folder(uri: Uri): String?
}

/** The device's own answer, through the content resolver. */
internal class ImageDeviceDataSource(context: Context) : ImageDataSource {

    private val applicationContext: Context = context.applicationContext

    override fun content(uri: Uri): MediaContent? = MediaContent.of(applicationContext, uri)

    override fun folder(uri: Uri): String? = try {
        when (uri.authority) {
            EXTERNAL_STORAGE_AUTHORITY -> DocumentsContract.getDocumentId(uri)
                .substringAfter(':')
                .substringBeforeLast('/', "")
            MEDIA_DOCUMENTS_AUTHORITY -> mediaFolder(uri)
            else -> null
        }
    } catch (error: RuntimeException) {
        // Another process answers this, and providers fail in their own ways:
        // a refused grant, an address they do not know, or no answer at all.
        null
    }

    // The media provider keeps the folder only from Android 10 on, and older
    // versions need a storage permission to read it.
    private fun mediaFolder(uri: Uri): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return null
        }
        val media = MediaStore.getMediaUri(applicationContext, uri) ?: return null
        return applicationContext.contentResolver
            .query(media, arrayOf(MediaStore.MediaColumns.RELATIVE_PATH), null, null, null)
            ?.use { cursor ->
                if (cursor.moveToFirst()) {
                    cursor.getString(0)?.trimEnd('/')
                } else {
                    null
                }
            }
    }

    private companion object {

        private const val EXTERNAL_STORAGE_AUTHORITY = "com.android.externalstorage.documents"
        private const val MEDIA_DOCUMENTS_AUTHORITY = "com.android.providers.media.documents"
    }
}

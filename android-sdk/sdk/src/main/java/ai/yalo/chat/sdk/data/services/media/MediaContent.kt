// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.media

import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
import java.io.FileNotFoundException
import java.io.InputStream

/**
 * A file on its way to the backend. The bytes are not here, so a video does not
 * have to fit in heap for the length of an upload.
 *
 * [sizeBytes] has to be the exact length [openStream] will produce: it is sent
 * ahead as the content length, and a number that does not match either hangs
 * the request or fails the write partway.
 */
internal data class MediaContent(
    val fileName: String,
    val mimeType: String,
    val sizeBytes: Long,

    /**
     * Must hand back a fresh stream every time. An upload turned away for a
     * stale token is sent again, and a drained stream would upload nothing.
     */
    val openStream: () -> InputStream,
) {

    internal companion object {

        /**
         * Describes whatever [uri] points at, or null when the device will not
         * say. Blocking, because it asks another process.
         */
        fun of(context: Context, uri: Uri): MediaContent? {
            val resolver = context.applicationContext.contentResolver
            val mimeType = resolver.getType(uri) ?: return null
            val details = resolver.query(uri, PROJECTION, null, null, null)?.use { cursor ->
                if (!cursor.moveToFirst()) {
                    return@use null
                }
                val name = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                val size = cursor.getColumnIndex(OpenableColumns.SIZE)
                // A missing column reads back as -1 and a null size as zero,
                // which would send an empty file under a promised length.
                if (name < 0 || size < 0 || cursor.isNull(name) || cursor.isNull(size)) {
                    return@use null
                }
                cursor.getString(name) to cursor.getLong(size)
            } ?: return null

            return MediaContent(
                fileName = details.first,
                mimeType = mimeType,
                sizeBytes = details.second,
                // The resolver is captured rather than the context, because
                // this outlives the call that built it.
                openStream = {
                    resolver.openInputStream(uri) ?: throw FileNotFoundException("Cannot read $uri")
                },
            )
        }

        private val PROJECTION = arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE)
    }
}

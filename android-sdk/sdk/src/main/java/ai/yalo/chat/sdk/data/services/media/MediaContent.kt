// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.media

import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
import java.io.FileNotFoundException
import java.io.InputStream

/**
 * A file on its way to the backend: what to call it, what it holds, how big it
 * is, and how to read it.
 *
 * The bytes are not here. A voice note is small but a video is not, and holding
 * one in memory for the length of an upload is how a chat runs an app out of
 * heap. [openStream] hands over a stream instead, and the upload writes it
 * straight to the socket.
 *
 * [sizeBytes] has to be the exact length [openStream] will produce. It is sent
 * ahead as the content length, and a number that does not match is worse than
 * no number at all: too large and the request never finishes, too small and the
 * write fails partway.
 */
internal data class MediaContent(
    val fileName: String,
    val mimeType: String,
    val sizeBytes: Long,

    /**
     * Opens the content for reading.
     *
     * Must hand back a **fresh** stream every time it is called. An upload that
     * is turned away because its token expired is sent a second time, and a
     * stream that was already drained would upload nothing at all.
     */
    val openStream: () -> InputStream,
) {

    internal companion object {

        /**
         * Describes whatever [uri] points at, or null if the device will not say.
         *
         * A name, a type and a length are all needed before anything can be
         * sent, and a picker can hand back a [Uri] that has lost any of them.
         * That is reported as nothing to upload rather than raised, the same way
         * a token that cannot be read back reads as no token.
         *
         * Blocking. This asks another process, so callers keep it off the main
         * thread.
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
                // A column that is missing reads back as -1, and a size that is
                // null reads back as zero, which would send an empty file under
                // a request that promised one.
                if (name < 0 || size < 0 || cursor.isNull(name) || cursor.isNull(size)) {
                    return@use null
                }
                cursor.getString(name) to cursor.getLong(size)
            } ?: return null

            return MediaContent(
                fileName = details.first,
                mimeType = mimeType,
                sizeBytes = details.second,
                // The resolver is captured rather than the context, because this
                // outlives the call that built it.
                openStream = {
                    resolver.openInputStream(uri) ?: throw FileNotFoundException("Cannot read $uri")
                },
            )
        }

        private val PROJECTION = arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE)
    }
}

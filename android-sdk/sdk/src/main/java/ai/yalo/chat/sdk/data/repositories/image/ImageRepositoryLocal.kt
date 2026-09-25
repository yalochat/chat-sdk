// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.image

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.data.datasources.image.ImageDataSource
import ai.yalo.chat.sdk.data.datasources.media.MediaContent
import ai.yalo.chat.sdk.domain.models.ImageAttachment
import ai.yalo.chat.sdk.log.YaloLog
import android.net.Uri
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.IOException

/**
 * Copies a picked picture into [imagesDir] and describes it.
 *
 * The copy is what makes an image message survive being sent. What the channel
 * is told is the id of the upload, which is not something to download from, and
 * the gallery stops answering for a picked file as soon as the app is
 * restarted. Pictures are kept in the app's own files rather than in the cache
 * for the same reason: the system is free to throw the cache away whenever it
 * wants the room.
 */
internal class ImageRepositoryLocal(
    private val source: ImageDataSource,
    private val imagesDir: File,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
    private val now: () -> Long = System::currentTimeMillis,
    logLevel: LogLevel = LogLevel.Warn,
) : ImageRepository {

    private val log = YaloLog(LOG_NAME, logLevel)

    override suspend fun store(uri: Uri): Result<ImageAttachment> = withContext(dispatcher) {
        val content = source.content(uri)
        if (content == null) {
            log.warn { "the device will not say what was picked" }
            return@withContext Result.failure(IOException(NOT_READABLE))
        }
        val file = File(imagesDir, nameOf(content))
        try {
            imagesDir.mkdirs()
            content.openStream().use { picked ->
                file.outputStream().use { copy -> picked.copyTo(copy) }
            }
        } catch (error: IOException) {
            file.delete()
            log.warn(error) { NOT_READABLE }
            return@withContext Result.failure(error)
        }
        log.info { "kept ${file.length()} bytes of ${content.mimeType} as ${file.name}" }
        Result.success(
            ImageAttachment(
                mediaType = content.mimeType,
                fileName = content.fileName,
                byteCount = file.length(),
                localPath = file.absolutePath,
            ),
        )
    }

    /**
     * What the copy is called on disk, which is not what the person's own file
     * is called: two pictures picked from the same gallery can share a name,
     * and one of them would overwrite the other.
     */
    private fun nameOf(content: MediaContent): String {
        val extension = content.fileName.substringAfterLast('.', "")
        return if (extension.isEmpty()) {
            "$IMAGE_PREFIX${now()}"
        } else {
            "$IMAGE_PREFIX${now()}.$extension"
        }
    }

    private companion object {

        private const val LOG_NAME = "Images"
        private const val NOT_READABLE = "The picture could not be read"
        private const val IMAGE_PREFIX = "image-"
    }
}

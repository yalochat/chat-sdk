// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.media

import ai.yalo.chat.sdk.data.datasources.media.Media
import ai.yalo.chat.sdk.data.datasources.media.MediaContent
import ai.yalo.chat.sdk.domain.models.MessageType
import java.io.File
import java.io.IOException

/**
 * Stands in for the backend's files so a test can say what it does without a
 * network.
 *
 * Set [uploadFailure] or [downloadFailure] to make that call come back failed,
 * which is how a test asks what the chat does when a file never gets anywhere.
 */
internal class FakeMediaRepository(
    var uploadFailure: Throwable? = null,
    var downloadFailure: Throwable? = null,
) : MediaRepository {

    /** Every upload that was asked for, in order. */
    val uploaded: MutableList<MediaContent> = mutableListOf()

    /** Every address a download was asked for, in order. */
    val downloaded: MutableList<String> = mutableListOf()

    var mediaId: String = "media-1"

    /** What a download hands back. A test that plays a note has to set one. */
    var downloadedFile: File? = null

    override suspend fun upload(content: MediaContent): Result<Media> {
        uploadFailure?.let { error -> return Result.failure(error) }
        uploaded.add(content)
        return Result.success(
            Media(
                id = mediaId,
                signedUrl = "https://media.example.com/$mediaId",
                originalName = content.fileName,
                type = MessageType.Voice,
            ),
        )
    }

    override suspend fun download(url: String): Result<File> {
        downloadFailure?.let { error -> return Result.failure(error) }
        downloaded.add(url)
        val file = downloadedFile ?: return Result.failure(IOException("Nothing to hand back"))
        return Result.success(file)
    }
}

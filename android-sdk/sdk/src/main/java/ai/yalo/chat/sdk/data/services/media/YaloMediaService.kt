// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.media

import ai.yalo.chat.sdk.domain.models.MessageType
import java.io.File
import java.io.IOException

/** [signedUrl] expires, so it is worth following rather than keeping. */
internal data class Media(
    val id: String,
    val signedUrl: String,
    val originalName: String,
    val type: MessageType,
)

/** The backend turned the token away, the one outcome worth trying again with a new one. */
internal class TokenRefusedException : IOException("Upload failed: 401")

/**
 * Moves the files a conversation carries to the backend and back.
 *
 * [token] is handed in per call: what a good one is, and what to do when the
 * backend will not take it, is the caller's.
 */
internal interface YaloMediaService {

    suspend fun upload(content: MediaContent, token: String): Result<Media>

    /**
     * Fetches [url] into the cache and returns the file holding it. Asking twice
     * costs one download, and the file stays until the system reclaims the cache.
     */
    suspend fun download(url: String): Result<File>
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.media

import ai.yalo.chat.sdk.domain.models.MessageType
import java.io.File

/** [signedUrl] expires, so it is worth following rather than keeping. */
internal data class Media(
    val id: String,
    val signedUrl: String,
    val originalName: String,
    val type: MessageType,
)

/** Moves the files a conversation carries to the backend and back. */
internal interface YaloMediaService {

    /** An upload the backend turns away for a stale token is sent again with a new one. */
    suspend fun upload(content: MediaContent): Result<Media>

    /**
     * Fetches [url] into the cache and returns the file holding it. Asking twice
     * costs one download, and the file stays until the system reclaims the cache.
     */
    suspend fun download(url: String): Result<File>
}

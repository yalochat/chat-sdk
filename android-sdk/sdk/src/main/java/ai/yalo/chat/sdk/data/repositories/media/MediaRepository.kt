// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.media

import ai.yalo.chat.sdk.data.datasources.media.Media
import ai.yalo.chat.sdk.data.datasources.media.MediaContent
import java.io.File

/**
 * The files a conversation carries, on their way to the backend and back.
 *
 * Nothing that asks for an upload has to know a token is involved, or that one
 * can run out partway.
 */
internal interface MediaRepository {

    /** Sends [content] to the backend, and answers with the media it created. */
    suspend fun upload(content: MediaContent): Result<Media>

    /**
     * Fetches [url] into the cache and returns the file holding it. Asking twice
     * costs one download, and the file stays until the system reclaims the cache.
     */
    suspend fun download(url: String): Result<File>
}

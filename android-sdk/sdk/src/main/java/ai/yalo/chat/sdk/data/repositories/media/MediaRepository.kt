// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.media

import ai.yalo.chat.sdk.data.services.media.Media
import ai.yalo.chat.sdk.data.services.media.MediaContent
import java.io.File

/** The files a conversation carries, with getting into the backend taken care of. */
internal interface MediaRepository {

    /** An upload the backend turns away for a stale token is sent again with a new one. */
    suspend fun upload(content: MediaContent): Result<Media>

    /**
     * Fetches [url] into the cache and returns the file holding it. Asking twice
     * costs one download, and the file stays until the system reclaims the cache.
     */
    suspend fun download(url: String): Result<File>
}

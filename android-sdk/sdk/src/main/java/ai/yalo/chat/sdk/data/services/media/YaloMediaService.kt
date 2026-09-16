// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.media

import ai.yalo.chat.sdk.domain.models.MessageType
import java.io.File

/**
 * A file the backend has taken in and now holds.
 *
 * [id] is what a message refers to when it carries this media. [signedUrl] is
 * how it is read back, and it only works for a while: the backend signs a fresh
 * one each time it describes the media, so it is worth following rather than
 * keeping.
 */
internal data class Media(
    val id: String,
    val signedUrl: String,
    val originalName: String,
    val type: MessageType,
)

/** Moves the files a conversation carries to the backend and back. */
internal interface YaloMediaService {

    /**
     * Sends [content] and returns what the backend made of it.
     *
     * The token is obtained and attached here, and an upload the backend turns
     * away because that token is no longer good is sent again with a new one.
     */
    suspend fun upload(content: MediaContent): Result<Media>

    /**
     * Fetches [url] into the cache and returns the file holding it.
     *
     * Asking twice for the same media costs one download. The file stays until
     * the system reclaims the cache, so callers read it rather than keeping
     * their own copy.
     */
    suspend fun download(url: String): Result<File>
}

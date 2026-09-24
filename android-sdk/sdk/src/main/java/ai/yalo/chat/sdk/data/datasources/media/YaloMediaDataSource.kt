// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.media

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

/** Moves the files a conversation carries to the backend and back. */
internal interface YaloMediaDataSource {

    /**
     * Sends [content] under [token], once.
     *
     * A backend that turns the upload away for the token answers with a
     * [StaleTokenException], which is the one failure worth sending again under
     * another token. Whether that happens is not decided here.
     */
    suspend fun upload(content: MediaContent, token: String): Result<Media>

    /**
     * Fetches [url] into the cache and returns the file holding it. Asking twice
     * costs one download, and the file stays until the system reclaims the cache.
     */
    suspend fun download(url: String): Result<File>
}

/** The backend refused the token an upload was sent under. */
internal class StaleTokenException :
    IOException("The token was refused, so the upload was not taken")

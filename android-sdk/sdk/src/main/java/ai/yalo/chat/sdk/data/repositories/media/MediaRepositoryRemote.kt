// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.media

import ai.yalo.chat.sdk.data.datasources.media.Media
import ai.yalo.chat.sdk.data.datasources.media.MediaContent
import ai.yalo.chat.sdk.data.datasources.media.StaleTokenException
import ai.yalo.chat.sdk.data.datasources.media.YaloMediaDataSource
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import java.io.File

/**
 * Puts a token on every upload, and is the only thing here that knows an
 * upload carries one.
 *
 * A token can be refused although it was not due to run out yet, by a backend
 * that was told to forget it or by a clock that disagrees. That is the one
 * failure worth answering, so it is answered once: the token is dropped and the
 * file goes again under a new one. A second refusal is reported.
 *
 * Nothing is kept here. [MediaContent] hands out a new stream for every read,
 * which is what lets the same file be sent twice.
 */
internal class MediaRepositoryRemote(
    private val source: YaloMediaDataSource,
    private val auth: TokenRepository,
) : MediaRepository {

    override suspend fun upload(content: MediaContent): Result<Media> {
        val sent = send(content)
        if (sent.exceptionOrNull() !is StaleTokenException) {
            return sent
        }
        auth.invalidateToken()
        return send(content)
    }

    override suspend fun download(url: String): Result<File> = source.download(url)

    private suspend fun send(content: MediaContent): Result<Media> {
        val token = auth.token().getOrElse { cause -> return Result.failure(cause) }
        return source.upload(content, token)
    }
}

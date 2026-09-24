// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.media

import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import ai.yalo.chat.sdk.data.services.media.Media
import ai.yalo.chat.sdk.data.services.media.MediaContent
import ai.yalo.chat.sdk.data.services.media.TokenRefusedException
import ai.yalo.chat.sdk.data.services.media.YaloMediaService
import java.io.File

/** Puts a token on what [YaloMediaService] does, and answers a refused one. */
internal class MediaRepositoryRemote(
    private val media: YaloMediaService,
    private val tokens: TokenRepository,
) : MediaRepository {

    override suspend fun upload(content: MediaContent): Result<Media> {
        val sent = send(content).getOrElse { cause ->
            if (cause !is TokenRefusedException) {
                return Result.failure(cause)
            }
            // Nothing in the content is spent by a first attempt: it opens a new
            // stream every time it is read.
            tokens.invalidateToken()
            return send(content)
        }
        return Result.success(sent)
    }

    private suspend fun send(content: MediaContent): Result<Media> {
        val token = tokens.token().getOrElse { cause -> return Result.failure(cause) }
        return media.upload(content, token)
    }

    override suspend fun download(url: String): Result<File> = media.download(url)
}

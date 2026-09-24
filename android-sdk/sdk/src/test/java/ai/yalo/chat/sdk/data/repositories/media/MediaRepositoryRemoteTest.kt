// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.media

import ai.yalo.chat.sdk.data.repositories.token.AuthToken
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import ai.yalo.chat.sdk.data.services.media.Media
import ai.yalo.chat.sdk.data.services.media.MediaContent
import ai.yalo.chat.sdk.data.services.media.TokenRefusedException
import ai.yalo.chat.sdk.data.services.media.YaloMediaService
import ai.yalo.chat.sdk.domain.models.MessageType
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.ByteArrayInputStream
import java.io.File
import java.io.IOException

class MediaRepositoryRemoteTest {

    private val media = FakeMediaService()
    private val tokens = FakeTokenRepository()

    @Test
    fun putsTheCurrentTokenOnTheUpload() = runBlocking {
        repository().upload(content())

        assertEquals(listOf("access"), media.tokensUsed)
    }

    @Test
    fun sendsNothingWhenNoTokenCanBeHad() = runBlocking {
        tokens.failure = IOException("no token")

        val result = repository().upload(content())

        assertEquals("no token", result.exceptionOrNull()?.message)
        assertTrue(media.tokensUsed.isEmpty())
    }

    @Test
    fun getsANewTokenAndSendsTheFileAgainWhenTheOldTokenIsRefused() = runBlocking {
        media.refuseTokens = 1

        val result = repository().upload(content())

        assertTrue(result.isSuccess)
        assertEquals(1, tokens.invalidations)
        assertEquals(listOf("access", "refreshed"), media.tokensUsed)
    }

    @Test
    fun givesUpWhenTheSecondTokenIsRefusedToo() = runBlocking {
        media.refuseTokens = 2

        val result = repository().upload(content())

        assertTrue(result.exceptionOrNull() is TokenRefusedException)
        assertEquals(2, media.tokensUsed.size)
    }

    @Test
    fun leavesAFailureThatIsNotAboutTheTokenAlone() = runBlocking {
        media.failure = IOException("Upload failed: 500")

        val result = repository().upload(content())

        assertEquals("Upload failed: 500", result.exceptionOrNull()?.message)
        assertEquals(1, media.tokensUsed.size)
    }

    @Test
    fun downloadsWithoutATokenBecauseTheAddressIsAlreadySigned() = runBlocking {
        repository().download("https://files.example/pic.jpg")

        assertEquals(listOf("https://files.example/pic.jpg"), media.downloaded)
        assertTrue(media.tokensUsed.isEmpty())
    }

    private fun repository() = MediaRepositoryRemote(media = media, tokens = tokens)

    private fun content(): MediaContent = MediaContent(
        fileName = "photo.jpg",
        mimeType = "image/jpeg",
        sizeBytes = 3,
        openStream = { ByteArrayInputStream("abc".toByteArray()) },
    )

    private class FakeMediaService : YaloMediaService {
        val tokensUsed = mutableListOf<String>()
        val downloaded = mutableListOf<String>()
        var refuseTokens: Int = 0
        var failure: Throwable? = null

        override suspend fun upload(content: MediaContent, token: String): Result<Media> {
            tokensUsed += token
            failure?.let { cause -> return Result.failure(cause) }
            if (refuseTokens > 0) {
                refuseTokens--
                return Result.failure(TokenRefusedException())
            }
            return Result.success(
                Media("yalo_1", "https://files.example/1", content.fileName, MessageType.Image),
            )
        }

        override suspend fun download(url: String): Result<File> {
            downloaded += url
            return Result.success(File("cached"))
        }
    }

    private class FakeTokenRepository : TokenRepository {
        var invalidations: Int = 0
            private set
        var failure: Throwable? = null
        private var current = "access"

        override suspend fun token(): Result<String> =
            failure?.let { cause -> Result.failure(cause) } ?: Result.success(current)

        override suspend fun invalidateToken() {
            invalidations++
            current = "refreshed"
        }

        override suspend fun storedSessions(): Map<String, AuthToken> = emptyMap()

        override suspend fun clearSessions(sessionIds: Set<String>) = Unit

        override suspend fun clearAllSessions() = Unit
    }
}

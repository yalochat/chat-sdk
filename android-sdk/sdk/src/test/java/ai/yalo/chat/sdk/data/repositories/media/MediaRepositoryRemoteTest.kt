// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.media

import ai.yalo.chat.sdk.data.datasources.media.Media
import ai.yalo.chat.sdk.data.datasources.media.MediaContent
import ai.yalo.chat.sdk.data.datasources.media.StaleTokenException
import ai.yalo.chat.sdk.data.datasources.media.YaloMediaDataSource
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import ai.yalo.chat.sdk.domain.models.MessageType
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.ByteArrayInputStream
import java.io.File
import java.io.IOException

/**
 * Covers the one thing this side decides, which is what token a file is sent
 * under and what to do when the backend will not take it.
 */
class MediaRepositoryRemoteTest {

    private val source = FakeMediaDataSource()
    private val auth = FakeTokenRepository()

    @Test
    fun sendsTheFileUnderTheTokenItWasGiven() = runTest {
        repository().upload(content())

        assertEquals(listOf("access"), source.tokens)
    }

    @Test
    fun answersWithTheMediaTheBackendCreated() = runTest {
        val media = repository().upload(content()).getOrNull()

        assertEquals("yalo_1", media?.id)
    }

    @Test
    fun sendsTheFileAgainUnderANewTokenWhenTheOldOneWasRefused() = runTest {
        source.answers += Result.failure(StaleTokenException())

        val media = repository().upload(content()).getOrNull()

        assertEquals("yalo_1", media?.id)
        assertEquals(listOf("access", "refreshed"), source.tokens)
    }

    @Test
    fun dropsTheRefusedTokenBeforeAskingForAnother() = runTest {
        source.answers += Result.failure(StaleTokenException())

        repository().upload(content())

        assertEquals(1, auth.invalidations)
    }

    @Test
    fun givesUpWhenTheSecondTokenIsRefusedToo() = runTest {
        repeat(2) { source.answers += Result.failure(StaleTokenException()) }

        val result = repository().upload(content())

        assertTrue(result.exceptionOrNull() is StaleTokenException)
        assertEquals(2, source.tokens.size)
    }

    // Sending the same file again would cost an upload and end the same way.
    @Test
    fun sendsNothingAgainWhenTheUploadFailedForAnotherReason() = runTest {
        source.answers += Result.failure(IOException("Upload failed: 500"))

        val result = repository().upload(content())

        assertEquals("Upload failed: 500", result.exceptionOrNull()?.message)
        assertEquals(1, source.tokens.size)
    }

    @Test
    fun sendsNothingWhenNoTokenCanBeHad() = runTest {
        auth.failure = IOException("no token")

        val result = repository().upload(content())

        assertEquals("no token", result.exceptionOrNull()?.message)
        assertTrue(source.tokens.isEmpty())
    }

    @Test
    fun asksForNoTokenToFollowAnAddressThatIsAlreadySigned() = runTest {
        repository().download("https://files.example/yalo_1?signature=first")

        assertEquals("https://files.example/yalo_1?signature=first", source.downloaded)
        assertTrue(source.tokens.isEmpty())
    }

    private fun repository(): MediaRepository = MediaRepositoryRemote(source = source, auth = auth)

    private fun content(): MediaContent = MediaContent(
        fileName = "photo.jpg",
        mimeType = "image/jpeg",
        sizeBytes = 9L,
        openStream = { ByteArrayInputStream("the-bytes".toByteArray()) },
    )

    private class FakeMediaDataSource : YaloMediaDataSource {

        /** One token per attempt, in the order the attempts were made. */
        val tokens = mutableListOf<String>()

        /** What to answer the next uploads with, a success once these run out. */
        val answers = ArrayDeque<Result<Media>>()

        var downloaded: String? = null

        override suspend fun upload(content: MediaContent, token: String): Result<Media> {
            tokens += token
            return answers.removeFirstOrNull() ?: Result.success(MEDIA)
        }

        override suspend fun download(url: String): Result<File> {
            downloaded = url
            return Result.success(File(url))
        }

        private companion object {
            val MEDIA = Media(
                id = "yalo_1",
                signedUrl = "https://files.example/yalo_1",
                originalName = "photo.jpg",
                type = MessageType.Image,
            )
        }
    }

    private class FakeTokenRepository : TokenRepository {

        var current: String = "access"
        var failure: Throwable? = null
        var invalidations: Int = 0

        override suspend fun token(): Result<String> =
            failure?.let { cause -> Result.failure(cause) } ?: Result.success(current)

        override suspend fun invalidateToken() {
            invalidations++
            current = "refreshed"
        }

        override suspend fun clearSession() = Unit
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.media

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import ai.yalo.chat.sdk.domain.models.MessageType
import kotlinx.coroutines.runBlocking
import mockwebserver3.MockResponse
import mockwebserver3.MockWebServer
import mockwebserver3.SocketEffect
import okhttp3.OkHttpClient
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.io.ByteArrayInputStream
import java.io.File
import java.io.IOException
import java.io.InputStream

@RunWith(RobolectricTestRunner::class)
class YaloMediaServiceRemoteTest {

    @get:Rule
    val cache = TemporaryFolder()

    private lateinit var server: MockWebServer
    private val auth = FakeTokenRepository()

    @Before
    fun startServer() {
        server = MockWebServer()
        server.start()
    }

    @After
    fun stopServer() {
        server.close()
    }

    @Test
    fun sendsTheFileToTheMediaEndpointWithTheToken() = runBlocking {
        server.enqueue(created())

        service().upload(content())

        val request = server.takeRequest()
        assertEquals("/v1/channels/all/media", request.url.encodedPath)
        assertEquals("Bearer access", request.headers["Authorization"])
    }

    @Test
    fun sendsTheFileAsAFormPartNamedFile() = runBlocking {
        server.enqueue(created())

        service().upload(content(fileName = "holiday.jpg", payload = "the-bytes"))

        val body = requireNotNull(server.takeRequest().body).utf8()
        assertTrue(body.contains("""name="file"; filename="holiday.jpg""""))
        assertTrue(body.contains("Content-Type: image/jpeg"))
        assertTrue(body.contains("the-bytes"))
    }

    // What this is really testing is that the body streams under a length the
    // request states up front. A body that could not say how long it was would
    // be sent in chunks instead, and there are gateways that will not take it.
    @Test
    fun saysHowLongTheFileIsRatherThanSendingItInChunks() = runBlocking {
        server.enqueue(created())

        service().upload(content(payload = "0123456789"))

        val request = server.takeRequest()
        assertTrue(request.chunkSizes.orEmpty().isEmpty())
        assertNotNull(request.headers["Content-Length"])
    }

    @Test
    fun readsBackTheMediaTheBackendCreated() = runBlocking {
        server.enqueue(created(id = "yalo_42", type = "voice"))

        val media = service().upload(content()).getOrNull()

        assertEquals("yalo_42", media?.id)
        assertEquals("https://files.example/yalo_42?signature=first", media?.signedUrl)
        assertEquals("photo.jpg", media?.originalName)
        assertEquals(MessageType.Voice, media?.type)
    }

    @Test
    fun readsTheFieldsAnEndpointSpellsInCamelCase() = runBlocking {
        server.enqueue(
            response(
                201,
                """{"id":"yalo_1","signedUrl":"https://files.example/1","originalName":"a.jpg","type":"image"}""",
            ),
        )

        val media = service().upload(content()).getOrNull()

        assertEquals("https://files.example/1", media?.signedUrl)
        assertEquals("a.jpg", media?.originalName)
    }

    // The second request carrying the payload is the point. A body that had
    // already been spent would be sent empty, and the test would still see two
    // requests and a success.
    @Test
    fun getsANewTokenAndSendsTheFileAgainWhenTheOldTokenIsRefused() = runBlocking {
        server.enqueue(response(401))
        server.enqueue(created())

        val media = service().upload(content(payload = "the-bytes")).getOrNull()

        server.takeRequest()
        val retry = server.takeRequest()
        assertEquals("yalo_1", media?.id)
        assertEquals(1, auth.invalidations)
        assertEquals("Bearer refreshed", retry.headers["Authorization"])
        assertTrue(requireNotNull(retry.body).utf8().contains("the-bytes"))
    }

    @Test
    fun givesUpWhenTheSecondTokenIsRefusedToo() = runBlocking {
        server.enqueue(response(401))
        server.enqueue(response(401))

        val result = service().upload(content())

        assertTrue(result.isFailure)
        assertEquals(2, server.requestCount)
        assertTrue(result.exceptionOrNull()?.message?.contains("401") == true)
    }

    @Test
    fun reportsAFailureWhenTheBackendWillNotTakeTheFile() = runBlocking {
        server.enqueue(response(500))

        val result = service().upload(content())

        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull()?.message?.contains("500") == true)
    }

    // A 200 is not a success here. A proxy answering with a page of its own
    // would otherwise be parsed as though it were media.
    @Test
    fun reportsAFailureWhenTheBackendAnswersWithoutCreatingAnything() = runBlocking {
        server.enqueue(response(200, """{"id":"yalo_1"}"""))

        assertTrue(service().upload(content()).isFailure)
    }

    @Test
    fun reportsAFailureWhenTheBackendSendsSomethingThatIsNotMedia() = runBlocking {
        server.enqueue(response(201, "not json at all"))

        assertTrue(service().upload(content()).isFailure)
    }

    @Test
    fun reportsAFailureWhenNoTokenCanBeHad() = runBlocking {
        auth.failure = IOException("no token")

        val result = service().upload(content())

        assertEquals(0, server.requestCount)
        assertEquals("no token", result.exceptionOrNull()?.message)
    }

    @Test
    fun keepsADownloadedFileInTheCache() = runBlocking {
        server.enqueue(response(200, "the-picture"))

        val file = service().download(server.url("/files/pic.jpg").toString()).getOrNull()

        assertEquals("the-picture", file?.readText())
    }

    @Test
    fun answersASecondDownloadWithoutAskingAgain() = runBlocking {
        server.enqueue(response(200, "the-picture"))
        val service = service()
        val address = server.url("/files/pic.jpg").toString()

        service.download(address)
        val again = service.download(address)

        assertEquals(1, server.requestCount)
        assertEquals("the-picture", again.getOrNull()?.readText())
    }

    // The backend signs a fresh address every time it describes the same file,
    // so a cache keyed on the whole address would never hit and would keep one
    // copy per signature.
    @Test
    fun treatsTwoSignaturesForTheSameFileAsOneDownload() = runBlocking {
        server.enqueue(response(200, "the-picture"))
        val service = service()

        val first = service.download(server.url("/files/pic.jpg?signature=first").toString())
        val second = service.download(server.url("/files/pic.jpg?signature=second").toString())

        assertEquals(1, server.requestCount)
        assertEquals(first.getOrNull(), second.getOrNull())
    }

    @Test
    fun reportsAFailureWhenTheFileIsNotThere() = runBlocking {
        server.enqueue(response(404))

        val result = service().download(server.url("/files/pic.jpg").toString())

        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull()?.message?.contains("404") == true)
    }

    @Test
    fun reportsAFailureWhenTheAddressIsNotAnAddress() = runBlocking {
        val result = service().download("not an address")

        assertTrue(result.isFailure)
        assertEquals(0, server.requestCount)
    }

    // A download that stops halfway must not leave anything a later read would
    // mistake for the whole file.
    @Test
    fun leavesNothingBehindWhenADownloadStopsHalfway() = runBlocking {
        repeat(2) {
            server.enqueue(
                MockResponse.Builder()
                    .code(200)
                    .body("a".repeat(1_024))
                    .onResponseBody(SocketEffect.CloseSocket())
                    .build(),
            )
        }

        val result = service().download(server.url("/files/pic.jpg").toString())

        assertTrue(result.isFailure)
        assertTrue(cacheDir().listFiles().orEmpty().isEmpty())
    }

    @Test
    fun doesNotSendTheTokenToWhoeverStoresTheFile() = runBlocking {
        server.enqueue(response(200, "the-picture"))

        service().download(server.url("/files/pic.jpg").toString())

        assertFalse(server.takeRequest().headers.names().contains("Authorization"))
    }

    @Test
    fun reportsAFailureWhenTheFileCannotBeRead() = runBlocking {
        repeat(2) { server.enqueue(created()) }
        val unreadable = MediaContent(
            fileName = "photo.jpg",
            mimeType = "image/jpeg",
            sizeBytes = 9L,
            openStream = {
                object : InputStream() {
                    override fun read(): Int = throw IOException("the file went away")
                }
            },
        )

        assertTrue(service().upload(unreadable).isFailure)
    }

    @Test
    fun bringsItsOwnClientWhenItIsNotGivenOne() = runBlocking {
        server.enqueue(created())

        val service = YaloMediaServiceRemote(
            auth = auth,
            baseUrl = server.url("/"),
            cacheDir = cacheDir(),
        )

        assertEquals("yalo_1", service.upload(content()).getOrNull()?.id)
    }

    private fun service(): YaloMediaServiceRemote = YaloMediaServiceRemote(
        auth = auth,
        baseUrl = server.url("/"),
        cacheDir = cacheDir(),
        client = OkHttpClient(),
        logLevel = LogLevel.Debug,
    )

    private fun cacheDir(): File = File(cache.root, "media")

    private fun content(
        fileName: String = "photo.jpg",
        mimeType: String = "image/jpeg",
        payload: String = "the-bytes",
    ): MediaContent = MediaContent(
        fileName = fileName,
        mimeType = mimeType,
        sizeBytes = payload.length.toLong(),
        openStream = { ByteArrayInputStream(payload.toByteArray()) },
    )

    private fun created(id: String = "yalo_1", type: String = "image"): MockResponse = response(
        201,
        """
        {"id":"$id","signed_url":"https://files.example/$id?signature=first",
         "original_name":"photo.jpg","type":"$type"}
        """.trimIndent(),
    )

    private fun response(code: Int, body: String = ""): MockResponse =
        MockResponse.Builder().code(code).body(body).build()

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

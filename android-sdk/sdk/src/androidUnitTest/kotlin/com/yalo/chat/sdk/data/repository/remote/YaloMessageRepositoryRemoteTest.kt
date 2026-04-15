// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.model.Product
import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.client.engine.mock.respondError
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.headersOf
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.take
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.yield
import kotlinx.serialization.json.Json
import java.io.File
import java.nio.file.Files
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class YaloMessageRepositoryRemoteTest {

    // Minimal JWT whose payload {"user_id":"test-user"} satisfies auth calls.
    private val fakeJwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" +
        ".eyJ1c2VyX2lkIjoidGVzdC11c2VyIn0" +
        ".fakesig"

    private val authResponse =
        """{"access_token":"$fakeJwt","refresh_token":"rt","expires_in":3600}"""

    private lateinit var tempDir: File

    @BeforeTest
    fun setUp() {
        tempDir = Files.createTempDirectory("repo-test-").toFile()
    }

    @AfterTest
    fun tearDown() {
        tempDir.deleteRecursively()
    }

    // Builds a repo backed by a MockEngine that auto-handles /auth and serves data
    // responses from the provided list in order. /auth never consumes a response slot.
    private fun buildRepo(responses: List<String>): YaloMessageRepositoryRemote {
        var callIndex = 0
        val engine = MockEngine { request ->
            if (request.url.encodedPath.endsWith("/auth")) {
                respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            } else {
                val body = if (callIndex < responses.size) responses[callIndex++] else "[]"
                respond(body, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            }
        }
        val client = HttpClient(engine) {
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        val apiService = YaloChatApiService(
            apiBaseUrl = "https://api.test",
            channelId = "channel-id",
            organizationId = "org-id",
            httpClient = client,
        )
        return YaloMessageRepositoryRemote(apiService, pollingIntervalMs = 0L, tempDir = tempDir.absolutePath)
    }

    // Builds a repo with full control over the engine — used for media upload/download tests.
    private fun buildRepoWithEngine(
        engine: MockEngine,
        tempDir: File? = this.tempDir,
    ): YaloMessageRepositoryRemote {
        val client = HttpClient(engine) {
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        val apiService = YaloChatApiService(
            apiBaseUrl = "https://api.test",
            channelId = "channel-id",
            organizationId = "org-id",
            httpClient = client,
        )
        return YaloMessageRepositoryRemote(apiService, pollingIntervalMs = 0L, tempDir = tempDir?.absolutePath)
    }

    private fun textMessageJson(id: String, text: String, role: String? = null): String {
        val roleField = if (role != null) ""","role":"$role"""" else ""
        return """[{"id":"$id","message":{"timestamp":"2024-01-01T12:00:00Z","textMessageRequest":{"content":{"text":"$text"$roleField}}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"}]"""
    }

    private fun imageMessageJson(id: String, mediaUrl: String, mediaType: String = "image/jpeg"): String =
        """[{"id":"$id","message":{"timestamp":"2024-01-01T12:00:00Z","imageMessageRequest":{"content":{"mediaUrl":"$mediaUrl","mediaType":"$mediaType","role":"MESSAGE_ROLE_AGENT"}}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"}]"""

    private val mediaUploadOkResponse =
        """{"id":"media-id-1","signed_url":"https://cdn.example.com/file","original_name":"test.jpg","type":"image","created_at":"2024-01-01T00:00:00Z","expires_at":"2024-12-31T00:00:00Z"}"""

    private fun tempFile(name: String, content: ByteArray = ByteArray(8) { it.toByte() }): File {
        val file = File(tempDir, name)
        file.writeBytes(content)
        return file
    }

    // ── sendMessage — text ─────────────────────────────────────────────────────

    @Test
    fun `sendMessage text returns Ok when api succeeds`() = runTest {
        val repo = buildRepo(listOf("{}"))
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Text,
            status = MessageStatus.SENT, content = "hello",
        )
        assertIs<Result.Ok<Unit>>(repo.sendMessage(message))
    }

    // ── sendMessage — image ────────────────────────────────────────────────────

    @Test
    fun `sendMessage image uploads to CDN then posts imageMessageRequest`() = runTest {
        val imageFile = tempFile("test.jpg")
        val requestedPaths = mutableListOf<String>()
        val engine = MockEngine { request ->
            requestedPaths.add(request.url.encodedPath)
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.endsWith("/all/media") ->
                    respond(mediaUploadOkResponse, HttpStatusCode.Created, headersOf(HttpHeaders.ContentType, "application/json"))
                else ->
                    respond("{}", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            }
        }
        val repo = buildRepoWithEngine(engine)
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Image,
            status = MessageStatus.SENT, fileName = imageFile.absolutePath, mediaType = "image/jpeg",
        )

        val result = repo.sendMessage(message)

        assertIs<Result.Ok<Unit>>(result)
        assertTrue(requestedPaths.any { it.endsWith("/all/media") }, "upload endpoint not called")
        assertTrue(requestedPaths.any { it.endsWith("/inapp/inbound_messages") }, "send endpoint not called")
    }

    @Test
    fun `sendMessage image returns Error when file is missing`() = runTest {
        val repo = buildRepo(emptyList())
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Image,
            status = MessageStatus.SENT, fileName = "/nonexistent/image.jpg", mediaType = "image/jpeg",
        )
        assertIs<Result.Error<Unit>>(repo.sendMessage(message))
    }

    @Test
    fun `sendMessage image returns Error when upload fails`() = runTest {
        val imageFile = tempFile("fail.jpg")
        val engine = MockEngine { request ->
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.endsWith("/all/media") ->
                    respondError(HttpStatusCode.InternalServerError)
                else ->
                    respond("{}", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            }
        }
        val repo = buildRepoWithEngine(engine)
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Image,
            status = MessageStatus.SENT, fileName = imageFile.absolutePath, mediaType = "image/jpeg",
        )
        assertIs<Result.Error<Unit>>(repo.sendMessage(message))
    }

    @Test
    fun `sendMessage image without fileName returns Error`() = runTest {
        val repo = buildRepo(emptyList())
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Image,
            status = MessageStatus.SENT, mediaType = "image/jpeg",
        )
        assertIs<Result.Error<Unit>>(repo.sendMessage(message))
    }

    // ── sendMessage — voice ────────────────────────────────────────────────────

    @Test
    fun `sendMessage voice uploads to CDN then posts voiceNoteMessageRequest`() = runTest {
        val voiceFile = tempFile("rec.m4a")
        val requestedPaths = mutableListOf<String>()
        val engine = MockEngine { request ->
            requestedPaths.add(request.url.encodedPath)
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.endsWith("/all/media") ->
                    respond(mediaUploadOkResponse, HttpStatusCode.Created, headersOf(HttpHeaders.ContentType, "application/json"))
                else ->
                    respond("{}", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            }
        }
        val repo = buildRepoWithEngine(engine)
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Voice,
            status = MessageStatus.SENT, fileName = voiceFile.absolutePath, mediaType = "audio/mp4",
        )

        val result = repo.sendMessage(message)

        assertIs<Result.Ok<Unit>>(result)
        assertTrue(requestedPaths.any { it.endsWith("/all/media") }, "upload endpoint not called")
        assertTrue(requestedPaths.any { it.endsWith("/inapp/inbound_messages") }, "send endpoint not called")
    }

    @Test
    fun `sendMessage voice without fileName returns Error`() = runTest {
        val repo = buildRepo(emptyList())
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Voice,
            status = MessageStatus.SENT, mediaType = "audio/mp4",
        )
        assertIs<Result.Error<Unit>>(repo.sendMessage(message))
    }

    @Test
    fun `sendMessage voice returns Error when upload fails`() = runTest {
        val voiceFile = tempFile("rec.m4a")
        val engine = MockEngine { request ->
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.endsWith("/all/media") ->
                    respondError(HttpStatusCode.InternalServerError)
                else ->
                    respond("{}", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            }
        }
        val repo = buildRepoWithEngine(engine)
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Voice,
            status = MessageStatus.SENT, fileName = voiceFile.absolutePath, mediaType = "audio/mp4",
        )
        assertIs<Result.Error<Unit>>(repo.sendMessage(message))
    }

    // ── fetchMessages ──────────────────────────────────────────────────────────

    @Test
    fun `fetchMessages maps response to ChatMessage`() = runTest {
        val repo = buildRepo(listOf(textMessageJson("id-1", "Hello from server", "MESSAGE_ROLE_AGENT")))
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(1, result.result.size)
        assertEquals("Hello from server", result.result.first().content)
        assertEquals(MessageRole.AGENT, result.result.first().role)
        assertEquals(MessageType.Text, result.result.first().type)
    }

    @Test
    fun `fetchMessages returns empty list when server returns empty array`() = runTest {
        val repo = buildRepo(listOf("[]"))
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(0, result.result.size)
    }

    @Test
    fun `fetchMessages does not deduplicate — same message returned on each call`() = runTest {
        val repo = buildRepo(listOf(textMessageJson("id-1", "Hi"), textMessageJson("id-1", "Hi")))
        val first = repo.fetchMessages(since = 0L)
        val second = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(first)
        assertIs<Result.Ok<List<ChatMessage>>>(second)
        assertEquals(1, first.result.size)
        assertEquals(1, second.result.size)
    }

    // ── pollIncomingMessages — text ────────────────────────────────────────────

    @Test
    fun `pollIncomingMessages emits batch from first poll`() = runTest {
        val repo = buildRepo(listOf(textMessageJson("id-1", "Hi"), "[]"))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals("Hi", batch.first().content)
    }

    @Test
    fun `pollIncomingMessages deduplicates — same wiId emitted only once across batches`() = runTest {
        val bothMessages = """[
            {"id":"id-1","message":{"timestamp":"2024-01-01T12:00:00Z","textMessageRequest":{"content":{"text":"First"}}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"},
            {"id":"id-2","message":{"timestamp":"2024-01-01T12:00:01Z","textMessageRequest":{"content":{"text":"Second"}}},"date":"2024-01-01T12:00:01Z","user_id":"u1","status":"IN_DELIVERY"}
        ]"""
        val repo = buildRepo(listOf(textMessageJson("id-1", "First"), bothMessages))
        val batches = repo.pollIncomingMessages().take(2).toList()
        assertEquals(2, batches.size)
        assertEquals(1, batches[0].size)
        assertEquals("First", batches[0].first().content)
        assertEquals(1, batches[1].size)
        assertEquals("Second", batches[1].first().content)
    }

    @Test
    fun `pollIncomingMessages continues polling after network error`() = runTest {
        var dataCallIndex = 0
        val engine = MockEngine { request ->
            if (request.url.encodedPath.endsWith("/auth")) {
                respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            } else {
                dataCallIndex++
                if (dataCallIndex == 1) respondError(HttpStatusCode.InternalServerError)
                else respond(
                    textMessageJson("id-1", "After error", "MESSAGE_ROLE_AGENT"),
                    HttpStatusCode.OK,
                    headersOf(HttpHeaders.ContentType, "application/json"),
                )
            }
        }
        val repo = buildRepoWithEngine(engine)
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals("After error", batch.first().content)
    }

    @Test
    fun `pollIncomingMessages maps MESSAGE_ROLE_USER to USER`() = runTest {
        val repo = buildRepo(listOf(textMessageJson("id-1", "Hey", "MESSAGE_ROLE_USER"), "[]"))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(MessageRole.USER, batch.first().role)
    }

    @Test
    fun `pollIncomingMessages maps MESSAGE_ROLE_AGENT to AGENT`() = runTest {
        val repo = buildRepo(listOf(textMessageJson("id-1", "Hey", "MESSAGE_ROLE_AGENT"), "[]"))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(MessageRole.AGENT, batch.first().role)
    }

    @Test
    fun `pollIncomingMessages defaults role to AGENT when role is absent`() = runTest {
        val repo = buildRepo(listOf(textMessageJson("id-1", "Hey"), "[]"))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(MessageRole.AGENT, batch.first().role)
    }

    @Test
    fun `pollIncomingMessages status is always DELIVERED`() = runTest {
        val repo = buildRepo(listOf(textMessageJson("id-1", "msg"), "[]"))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(MessageStatus.DELIVERED, batch.first().status)
    }

    @Test
    fun `pollIncomingMessages suppresses empty poll cycles`() = runTest {
        val repo = buildRepo(listOf("[]", textMessageJson("id-1", "Eventually")))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals("Eventually", batch.first().content)
        assertTrue(batch.first().role == MessageRole.AGENT)
    }

    // ── pollIncomingMessages — agent image receive ─────────────────────────────

    @Test
    fun `pollIncomingMessages downloads agent image and returns Image ChatMessage`() = runTest {
        val fakeImageBytes = ByteArray(16) { it.toByte() }
        val cdnUrl = "https://cdn.example.com/image.jpg"
        val engine = MockEngine { request ->
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.endsWith("/inapp/messages") ->
                    respond(
                        imageMessageJson("img-1", cdnUrl),
                        HttpStatusCode.OK,
                        headersOf(HttpHeaders.ContentType, "application/json"),
                    )
                request.url.toString() == cdnUrl ->
                    respond(fakeImageBytes, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "image/jpeg"))
                else ->
                    respond("[]", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            }
        }
        val repo = buildRepoWithEngine(engine)

        val batch = repo.pollIncomingMessages().first()

        assertEquals(1, batch.size)
        val msg = batch.first()
        assertEquals(MessageType.Image, msg.type)
        assertEquals(MessageRole.AGENT, msg.role)
        assertEquals(MessageStatus.DELIVERED, msg.status)
        assertNotNull(msg.fileName, "fileName should be local temp path")
        assertEquals(fakeImageBytes.size.toLong(), msg.byteCount)
        assertEquals("image/jpeg", msg.mediaType)
        // Verify the file was actually written to disk
        assertTrue(File(msg.fileName!!).exists())
    }

    @Test
    fun `pollIncomingMessages skips agent image when download fails`() = runTest {
        val cdnUrl = "https://cdn.example.com/image.jpg"
        var pollCount = 0
        val engine = MockEngine { request ->
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.endsWith("/inapp/messages") -> {
                    pollCount++
                    val body = if (pollCount == 1) imageMessageJson("img-1", cdnUrl)
                               else textMessageJson("txt-1", "fallback")
                    respond(body, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                }
                else -> respondError(HttpStatusCode.InternalServerError) // CDN download fails
            }
        }
        // First poll: image skipped (download fails). Second poll: text arrives.
        val repo = buildRepoWithEngine(engine)
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals(MessageType.Text, batch.first().type)
    }

    @Test
    fun `pollIncomingMessages skips agent image when tempDir is null`() = runTest {
        val cdnUrl = "https://cdn.example.com/image.jpg"
        val fakeImageBytes = ByteArray(4)
        var pollCount = 0
        val engine = MockEngine { request ->
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.endsWith("/inapp/messages") -> {
                    pollCount++
                    val body = if (pollCount == 1) imageMessageJson("img-1", cdnUrl)
                               else textMessageJson("txt-1", "fallback")
                    respond(body, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                }
                else -> respond(fakeImageBytes, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "image/jpeg"))
            }
        }
        // First poll: image skipped (no tempDir). Second poll: text arrives.
        val repo = buildRepoWithEngine(engine, tempDir = null)
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals(MessageType.Text, batch.first().type)
    }

    // ── events() — typing indicator lifecycle ─────────────────────────────────

    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun `sendMessage text emits TypingStart on events flow`() = runTest(UnconfinedTestDispatcher()) {
        val repo = buildRepo(listOf("{}"))
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Text,
            status = MessageStatus.SENT, content = "hello",
        )
        val collectedEvents = mutableListOf<ChatEvent>()
        val collectJob = launch { repo.events().collect { collectedEvents.add(it) } }
        repo.sendMessage(message)
        yield()
        collectJob.cancel()
        assertEquals(1, collectedEvents.size)
        assertIs<ChatEvent.TypingStart>(collectedEvents[0])
        assertEquals("Writing message...", (collectedEvents[0] as ChatEvent.TypingStart).statusText)
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun `sendMessage image emits TypingStart on events flow`() = runTest(UnconfinedTestDispatcher()) {
        val imageFile = tempFile("img.jpg")
        val engine = MockEngine { request ->
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.endsWith("/all/media") ->
                    respond(mediaUploadOkResponse, HttpStatusCode.Created, headersOf(HttpHeaders.ContentType, "application/json"))
                else ->
                    respond("{}", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            }
        }
        val repo = buildRepoWithEngine(engine)
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Image,
            status = MessageStatus.SENT, fileName = imageFile.absolutePath, mediaType = "image/jpeg",
        )
        val collectedEvents = mutableListOf<ChatEvent>()
        val collectJob = launch { repo.events().collect { collectedEvents.add(it) } }
        repo.sendMessage(message)
        yield()
        collectJob.cancel()
        assertTrue(collectedEvents.isNotEmpty())
        assertIs<ChatEvent.TypingStart>(collectedEvents.first())
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun `pollIncomingMessages emits TypingStop when messages are received`() = runTest(UnconfinedTestDispatcher()) {
        val repo = buildRepo(listOf(textMessageJson("id-1", "Hi")))
        val collectedEvents = mutableListOf<ChatEvent>()
        val collectJob = launch { repo.events().collect { collectedEvents.add(it) } }
        repo.pollIncomingMessages().first()
        yield()
        collectJob.cancel()
        assertEquals(1, collectedEvents.size)
        assertIs<ChatEvent.TypingStop>(collectedEvents[0])
    }

    // ── pollIncomingMessages — product messages ────────────────────────────────

    private fun productMessageJson(
        id: String,
        orientation: String,
        products: List<Map<String, Any>> = emptyList(),
    ): String {
        val productsJson = products.joinToString(",") { p ->
            """{"sku":"${p["sku"]}","name":"${p["name"]}","price":${p["price"]},"imagesUrl":${p["imagesUrl"] ?: "[]"},"unitName":"${p["unitName"] ?: ""}","unitStep":${p["unitStep"] ?: 1.0}}"""
        }
        return """[{"id":"$id","message":{"productMessageRequest":{"products":[$productsJson],"orientation":"$orientation"}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"}]"""
    }

    @Test
    fun `fetchMessages maps productMessageRequest vertical orientation to Product type`() = runTest {
        val json = productMessageJson("prod-1", "ORIENTATION_VERTICAL")
        val repo = buildRepo(listOf(json))
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(1, result.result.size)
        assertEquals(MessageType.Product, result.result.first().type)
        assertEquals(MessageRole.AGENT, result.result.first().role)
        assertEquals(MessageStatus.DELIVERED, result.result.first().status)
    }

    @Test
    fun `fetchMessages maps productMessageRequest horizontal orientation to ProductCarousel type`() = runTest {
        val json = productMessageJson("prod-2", "ORIENTATION_HORIZONTAL")
        val repo = buildRepo(listOf(json))
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(MessageType.ProductCarousel, result.result.first().type)
    }

    @Test
    fun `fetchMessages maps productMessageRequest unspecified orientation to Product type`() = runTest {
        val json = productMessageJson("prod-3", "ORIENTATION_UNSPECIFIED")
        val repo = buildRepo(listOf(json))
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(MessageType.Product, result.result.first().type)
    }

    @Test
    fun `fetchMessages maps productMessageRequest absent orientation field to Product type`() = runTest {
        // JSON with no "orientation" key at all — must default to vertical (Product list),
        // not crash. Proto3 omits default-value fields on the wire; backend may omit it.
        val json = """[{"id":"prod-null","message":{"productMessageRequest":{"products":[]}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"}]"""
        val repo = buildRepo(listOf(json))
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(MessageType.Product, result.result.first().type)
    }

    @Test
    fun `fetchMessages maps product fields correctly`() = runTest {
        val json = productMessageJson(
            id = "prod-4",
            orientation = "ORIENTATION_VERTICAL",
            products = listOf(
                mapOf("sku" to "p1", "name" to "Milk", "price" to 10.0, "imagesUrl" to """["https://img.example.com/milk.jpg"]""", "unitName" to "unit", "unitStep" to 1.0),
            ),
        )
        val repo = buildRepo(listOf(json))
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val products: List<Product> = result.result.first().products
        assertEquals(1, products.size)
        assertEquals("p1", products.first().sku)
        assertEquals("Milk", products.first().name)
        assertEquals(10.0, products.first().price)
        assertEquals(listOf("https://img.example.com/milk.jpg"), products.first().imagesUrl)
    }

    @Test
    fun `pollIncomingMessages emits product message`() = runTest {
        val json = productMessageJson("prod-5", "ORIENTATION_VERTICAL")
        val repo = buildRepo(listOf(json))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals(MessageType.Product, batch.first().type)
        assertEquals(MessageRole.AGENT, batch.first().role)
    }

    // ── pollIncomingMessages — buttons messages ────────────────────────────────────

    private fun buttonsMessageJson(
        id: String,
        body: String = "Pick one",
        buttons: List<String> = listOf("Yes", "No"),
        header: String? = null,
        footer: String? = null,
    ): String {
        val headerField = if (header != null) """"header":"$header",""" else ""
        val footerField = if (footer != null) ""","footer":"$footer"""" else ""
        val buttonsJson = buttons.joinToString(",") { """"$it"""" }
        return """[{"id":"$id","message":{"buttonsMessageRequest":{"content":{${headerField}"body":"$body","buttons":[$buttonsJson]$footerField}}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"}]"""
    }

    @Test
    fun `pollIncomingMessages emits buttons message`() = runTest {
        val json = buttonsMessageJson("btn-1", body = "Choose:", buttons = listOf("A", "B"))
        val repo = buildRepo(listOf(json))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals(MessageType.Buttons, batch.first().type)
        assertEquals(MessageRole.AGENT, batch.first().role)
        assertEquals("Choose:", batch.first().content)
        assertEquals(listOf("A", "B"), batch.first().buttons)
    }

    @Test
    fun `pollIncomingMessages emits buttons message with header and footer`() = runTest {
        val json = buttonsMessageJson("btn-2", body = "Help?", header = "Order", footer = "Tap one", buttons = listOf("Track", "Cancel"))
        val repo = buildRepo(listOf(json))
        val batch = repo.pollIncomingMessages().first()
        assertEquals("Order", batch.first().header)
        assertEquals("Tap one", batch.first().footer)
        assertEquals(listOf("Track", "Cancel"), batch.first().buttons)
    }

    // ── pollIncomingMessages — CTA messages ────────────────────────────────────────

    private fun ctaMessageJson(
        id: String,
        body: String = "Visit us",
        buttons: List<Pair<String, String>> = listOf("Open" to "https://example.com"),
        header: String? = null,
        footer: String? = null,
    ): String {
        val headerField = if (header != null) """"header":"$header",""" else ""
        val footerField = if (footer != null) ""","footer":"$footer"""" else ""
        val buttonsJson = buttons.joinToString(",") { (text, url) -> """{"text":"$text","url":"$url"}""" }
        return """[{"id":"$id","message":{"ctaMessageRequest":{"content":{${headerField}"body":"$body","buttons":[$buttonsJson]$footerField}}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"}]"""
    }

    @Test
    fun `pollIncomingMessages emits CTA message`() = runTest {
        val json = ctaMessageJson("cta-1", body = "Shop now", buttons = listOf("View" to "https://shop.example.com"))
        val repo = buildRepo(listOf(json))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals(MessageType.CTA, batch.first().type)
        assertEquals(MessageRole.AGENT, batch.first().role)
        assertEquals("Shop now", batch.first().content)
        assertEquals(1, batch.first().ctaButtons.size)
        assertEquals("View", batch.first().ctaButtons.first().text)
        assertEquals("https://shop.example.com", batch.first().ctaButtons.first().url)
    }

    @Test
    fun `pollIncomingMessages emits CTA message with header and footer`() = runTest {
        val json = ctaMessageJson("cta-2", header = "Promo", footer = "Limited", buttons = listOf("Buy" to "https://a.com", "Learn" to "https://b.com"))
        val repo = buildRepo(listOf(json))
        val batch = repo.pollIncomingMessages().first()
        assertEquals("Promo", batch.first().header)
        assertEquals("Limited", batch.first().footer)
        assertEquals(2, batch.first().ctaButtons.size)
    }

    // ── pollIncomingMessages — video messages ──────────────────────────────────────

    private fun videoMessageJson(id: String, mediaUrl: String, caption: String = "", mediaType: String = "video/mp4"): String =
        """[{"id":"$id","message":{"videoMessageRequest":{"content":{"mediaUrl":"$mediaUrl","mediaType":"$mediaType","text":"$caption","role":"MESSAGE_ROLE_AGENT","duration":5.0}}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"}]"""

    @Test
    fun `pollIncomingMessages emits video message and saves file locally`() = runTest {
        val videoBytes = ByteArray(16) { it.toByte() }
        val engine = MockEngine { request ->
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.endsWith("/inapp/messages") ->
                    respond(
                        videoMessageJson("vid-1", "https://cdn.example.com/video.mp4", caption = "Watch this"),
                        HttpStatusCode.OK,
                        headersOf(HttpHeaders.ContentType, "application/json"),
                    )
                else ->
                    respond(videoBytes, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "video/mp4"))
            }
        }
        val repo = buildRepoWithEngine(engine)
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        val msg = batch.first()
        assertEquals(MessageType.Video, msg.type)
        assertEquals(MessageRole.AGENT, msg.role)
        assertEquals("Watch this", msg.content)
        assertEquals(5_000L, msg.duration)
        assertNotNull(msg.fileName, "fileName should be set to the local file path")
        assertTrue(File(msg.fileName!!).exists(), "downloaded video file should exist on disk")
    }

    @Test
    fun `pollIncomingMessages skips video message when download fails`() = runTest {
        var pollCount = 0
        val engine = MockEngine { request ->
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.endsWith("/inapp/messages") -> {
                    pollCount++
                    val body = if (pollCount == 1) videoMessageJson("vid-2", "https://cdn.example.com/video.mp4")
                               else textMessageJson("txt-1", "fallback")
                    respond(body, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                }
                else -> respondError(HttpStatusCode.InternalServerError) // CDN download fails
            }
        }
        // First poll: video skipped (download fails). Second poll: text arrives.
        val repo = buildRepoWithEngine(engine)
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals(MessageType.Text, batch.first().type)
    }

    // ── TypingStop behaviour ──────────────────────────────────────────────────────

    @Test
    fun `pollIncomingMessages does not emit TypingStop when all polled messages are already cached`() = runTest {
        // Polls: (1) id-1 new → TypingStop + emit, (2) id-1 cached → no TypingStop no emit,
        // (3) id-2 new → TypingStop + emit. take(2) waits for exactly the two emissions,
        // spanning all three polls. If the bug returned (TypingStop on raw.isNotEmpty rather
        // than batch.isNotEmpty) the count would be 3 instead of 2.
        val repo = buildRepo(listOf(
            textMessageJson("id-1", "First"),
            textMessageJson("id-1", "First"),  // cached — no emit, no TypingStop
            textMessageJson("id-2", "Second"),
        ))
        val events = mutableListOf<ChatEvent>()
        val eventJob = launch { repo.events().collect { events.add(it) } }
        repo.pollIncomingMessages().take(2).toList()
        runCurrent() // flush any buffered events into eventJob before cancelling
        eventJob.cancel()
        assertEquals(2, events.count { it is ChatEvent.TypingStop })
    }

    // ── ensureReceiptOrder ────────────────────────────────────────────────────────

    @Test
    fun `ensureReceiptOrder does not rewrite message IDs on first poll`() = runTest {
        // On the very first poll pollHighWater is 0, so historical IDs must be preserved.
        // The message date is 2024-01-01T12:00:00Z → stableId ~1_704_110_400_000.
        // Without the fix the ID would be bumped to current time (~1_700_000_000_000+).
        val repo = buildRepo(listOf(textMessageJson("id-first", "Hello")))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        val id = batch.first().id!!
        // stableId for 2024-01-01 is ~1_704_110_400_000; current time is well above 1_750_000_000_000.
        assertTrue(id < 1_750_000_000_000L,
            "ID $id was bumped to current time on first poll — historical IDs should be preserved")
    }

    @Test
    fun `ensureReceiptOrder rewrites out-of-order IDs on subsequent polls`() = runTest {
        // Both messages have the same 2024 date, so their stableIds are close.
        // After the first poll sets pollHighWater, the second message is bumped so
        // its id is strictly greater — verified by take(2) which avoids an infinite loop.
        val batches = buildRepo(listOf(
            textMessageJson("id-a", "First"),
            textMessageJson("id-b", "Second"),
        )).pollIncomingMessages().take(2).toList()
        assertEquals(2, batches.size)
        val id1 = batches[0].first().id!!
        val id2 = batches[1].first().id!!
        assertTrue(id2 > id1, "Second poll ID $id2 must be > first poll ID $id1")
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun `pollIncomingMessages emits TypingStop on network error`() = runTest(UnconfinedTestDispatcher()) {
        var dataCallIndex = 0
        val engine = MockEngine { request ->
            if (request.url.encodedPath.endsWith("/auth")) {
                respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            } else {
                dataCallIndex++
                if (dataCallIndex == 1) respondError(HttpStatusCode.InternalServerError)
                else respond(
                    textMessageJson("id-1", "After error"),
                    HttpStatusCode.OK,
                    headersOf(HttpHeaders.ContentType, "application/json"),
                )
            }
        }
        val repo = buildRepoWithEngine(engine)
        val collectedEvents = mutableListOf<ChatEvent>()
        val collectJob = launch { repo.events().collect { collectedEvents.add(it) } }
        repo.pollIncomingMessages().first()
        yield()
        collectJob.cancel()
        assertTrue(collectedEvents.isNotEmpty())
        assertTrue(collectedEvents.all { it is ChatEvent.TypingStop })
    }
}

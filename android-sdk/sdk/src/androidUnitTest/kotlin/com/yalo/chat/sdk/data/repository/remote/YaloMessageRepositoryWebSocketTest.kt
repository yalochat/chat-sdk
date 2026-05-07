// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.YaloMessageServiceWebSocket
import com.yalo.chat.sdk.data.remote.model.SdkMessageResponseDto
import com.yalo.chat.sdk.data.remote.model.SdkTextMessageContentDto
import com.yalo.chat.sdk.data.remote.model.SdkTextMessageResponseDto
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import com.yalo.chat.sdk.domain.model.ChatCommand
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.MessageType
import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.websocket.WebSockets
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.headersOf
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
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
import kotlin.test.assertNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class YaloMessageRepositoryWebSocketTest {

    private val fakeJwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" +
        ".eyJ1c2VyX2lkIjoidGVzdC11c2VyIn0" +
        ".fakesig"
    private val authResponse =
        """{"access_token":"$fakeJwt","refresh_token":"rt","expires_in":3600}"""

    private lateinit var tempDir: File

    @BeforeTest
    fun setUp() {
        tempDir = Files.createTempDirectory("ws-repo-test-").toFile()
    }

    @AfterTest
    fun tearDown() {
        tempDir.deleteRecursively()
    }

    private fun buildComponents(
        fetchResponse: String = "[]",
        sendResponse: String = "{}",
    ): Triple<YaloMessageServiceWebSocket, YaloChatApiService, YaloMessageRepositoryWebSocket> {
        val engine = MockEngine { request ->
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                request.url.encodedPath.contains("/messages") && request.method.value == "GET" ->
                    respond(fetchResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
                else ->
                    respond(sendResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            }
        }
        val client = HttpClient(engine) {
            install(WebSockets)
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        val apiService = YaloChatApiService(
            apiBaseUrl = "https://api.test",
            channelId = "channel-id",
            organizationId = "org-id",
            httpClient = client,
        )
        val wsService = YaloMessageServiceWebSocket(
            wsUrl = "wss://api.test/websocket/v1/connect/inapp",
            apiService = apiService,
            httpClient = client,
        )
        val repo = YaloMessageRepositoryWebSocket(
            wsService = wsService,
            apiService = apiService,
            tempDir = tempDir.absolutePath,
        )
        return Triple(wsService, apiService, repo)
    }

    private fun textFrame(id: String, text: String): YaloFetchMessagesResponse =
        YaloFetchMessagesResponse(
            id = id,
            message = SdkMessageResponseDto(
                textMessageRequest = SdkTextMessageResponseDto(
                    content = SdkTextMessageContentDto(text = text),
                ),
            ),
            date = "2024-01-01T12:00:00Z",
            userId = "u1",
            status = "IN_DELIVERY",
        )

    // ── pollIncomingMessages ───────────────────────────────────────────────────

    @Test
    fun `pollIncomingMessages emits message for each unique frame`() = runTest(UnconfinedTestDispatcher()) {
        val (wsService, _, repo) = buildComponents()
        val received = mutableListOf<String>()

        val job = launch {
            repo.pollIncomingMessages().collect { batch ->
                batch.forEach { received.add(it.content) }
            }
        }
        yield()

        wsService._frames.emit(textFrame("wi-1", "Hello"))
        wsService._frames.emit(textFrame("wi-2", "World"))
        yield()

        assertEquals(listOf("Hello", "World"), received)
        job.cancel()
    }

    @Test
    fun `pollIncomingMessages deduplicates frames with same wiId`() = runTest(UnconfinedTestDispatcher()) {
        val (wsService, _, repo) = buildComponents()
        val received = mutableListOf<String>()

        val job = launch {
            repo.pollIncomingMessages().collect { batch ->
                batch.forEach { received.add(it.content) }
            }
        }
        yield()

        wsService._frames.emit(textFrame("wi-dup", "First"))
        wsService._frames.emit(textFrame("wi-dup", "Duplicate"))
        wsService._frames.emit(textFrame("wi-dup", "Triplicate"))
        yield()

        assertEquals(listOf("First"), received)
        job.cancel()
    }

    @Test
    fun `pollIncomingMessages emits TypingStop event on new frame`() = runTest(UnconfinedTestDispatcher()) {
        val (wsService, _, repo) = buildComponents()
        val events = mutableListOf<ChatEvent>()

        val eventJob = launch { repo.events().collect { events.add(it) } }
        val msgJob = launch { repo.pollIncomingMessages().collect {} }
        yield()

        wsService._frames.emit(textFrame("wi-event", "Test"))
        yield()

        assertTrue(events.any { it is ChatEvent.TypingStop })
        eventJob.cancel()
        msgJob.cancel()
    }

    @Test
    fun `warmDedupCache prevents frames with pre-loaded ids from being emitted`() = runTest(UnconfinedTestDispatcher()) {
        val (wsService, _, repo) = buildComponents()
        repo.warmDedupCache(listOf("wi-known"))
        val received = mutableListOf<String>()

        val job = launch {
            repo.pollIncomingMessages().collect { batch ->
                batch.forEach { received.add(it.content) }
            }
        }
        yield()

        wsService._frames.emit(textFrame("wi-known", "Should be skipped"))
        wsService._frames.emit(textFrame("wi-new", "Should arrive"))
        yield()

        assertEquals(listOf("Should arrive"), received)
        job.cancel()
    }

    // ── fetchMessages ──────────────────────────────────────────────────────────

    @Test
    fun `fetchMessages returns Ok with empty list when server returns empty array`() = runTest {
        val (_, _, repo) = buildComponents(fetchResponse = "[]")
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<*>>(result)
        assertTrue((result as Result.Ok).result.isEmpty())
    }

    @Test
    fun `fetchMessages parses text message from server response`() = runTest {
        val json = """[{"id":"msg-1","message":{"timestamp":"2024-01-01T12:00:00Z","textMessageRequest":{"content":{"text":"Hi there"}}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"}]"""
        val (_, _, repo) = buildComponents(fetchResponse = json)
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<*>>(result)
        val messages = (result as Result.Ok).result
        assertEquals(1, messages.size)
        assertEquals("Hi there", messages[0].content)
        assertEquals(MessageType.Text, messages[0].type)
    }

    // ── sendMessage ────────────────────────────────────────────────────────────

    @Test
    fun `sendMessage text returns Ok`() = runTest {
        val (_, _, repo) = buildComponents(sendResponse = "{}")
        val result = repo.sendMessage(
            com.yalo.chat.sdk.domain.model.ChatMessage(
                id = 1L,
                role = com.yalo.chat.sdk.domain.model.MessageRole.USER,
                type = MessageType.Text,
                status = com.yalo.chat.sdk.domain.model.MessageStatus.SENT,
                content = "Test message",
                timestamp = 0L,
            )
        )
        assertIs<Result.Ok<Unit>>(result)
    }

    @Test
    fun `sendMessage emits TypingStart event`() = runTest(UnconfinedTestDispatcher()) {
        val (_, _, repo) = buildComponents(sendResponse = "{}")
        val events = mutableListOf<ChatEvent>()
        val job = launch { repo.events().collect { events.add(it) } }
        yield()

        repo.sendMessage(
            com.yalo.chat.sdk.domain.model.ChatMessage(
                id = 1L,
                role = com.yalo.chat.sdk.domain.model.MessageRole.USER,
                type = MessageType.Text,
                status = com.yalo.chat.sdk.domain.model.MessageStatus.SENT,
                content = "Hello",
                timestamp = 0L,
            )
        )

        assertTrue(events.any { it is ChatEvent.TypingStart })
        job.cancel()
    }

    // ── Command registration ───────────────────────────────────────────────────

    @Test
    fun `registerCommand invokes callback on addToCart instead of API`() = runTest {
        val (_, _, repo) = buildComponents()
        var capturedPayload: Map<String, Any?>? = null
        repo.registerCommand(ChatCommand.ADD_TO_CART) { capturedPayload = it }

        val result = repo.addToCart("sku-001", 2.0)

        assertIs<Result.Ok<Unit>>(result)
        assertNotNull(capturedPayload)
        assertEquals("sku-001", capturedPayload?.get("sku"))
        assertEquals(2.0, capturedPayload?.get("quantity"))
    }

    @Test
    fun `commandsSnapshot reflects registered commands`() = runTest {
        val (_, _, repo) = buildComponents()
        val cb: (Map<String, Any?>?) -> Unit = {}
        repo.registerCommand(ChatCommand.CLEAR_CART, cb)

        assertTrue(repo.commandsSnapshot.containsKey(ChatCommand.CLEAR_CART))
    }

    // ── pause / resume ─────────────────────────────────────────────────────────

    @Test
    fun `start launches a connection job`() = runTest(UnconfinedTestDispatcher()) {
        val (wsService, _, repo) = buildComponents()
        assertNull(wsService.connectionJob)

        repo.start(this)
        assertNotNull(wsService.connectionJob)

        wsService.disconnect()
    }

    @Test
    fun `pause cancels the connection job`() = runTest(UnconfinedTestDispatcher()) {
        val (wsService, _, repo) = buildComponents()
        repo.start(this)
        assertNotNull(wsService.connectionJob)

        repo.pause()
        assertNull(wsService.connectionJob)
    }

    @Test
    fun `resume after pause re-launches the connection job`() = runTest(UnconfinedTestDispatcher()) {
        val (wsService, _, repo) = buildComponents()
        repo.start(this)
        repo.pause()
        assertNull(wsService.connectionJob)

        repo.resume()
        assertNotNull(wsService.connectionJob)

        wsService.disconnect()
    }

    @Test
    fun `resume without prior pause is a no-op`() = runTest(UnconfinedTestDispatcher()) {
        val (wsService, _, repo) = buildComponents()
        // No start() — paused flag is false. resume() should not start a connection.
        repo.resume()
        assertNull(wsService.connectionJob)
    }
}

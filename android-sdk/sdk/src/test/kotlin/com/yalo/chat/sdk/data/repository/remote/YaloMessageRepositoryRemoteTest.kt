// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.client.engine.mock.respondError
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.headersOf
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.take
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.yield
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher

class YaloMessageRepositoryRemoteTest {

    // Minimal JWT whose payload {"user_id":"test-user"} is used to satisfy auth calls.
    private val fakeJwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" +
        ".eyJ1c2VyX2lkIjoidGVzdC11c2VyIn0" +
        ".fakesig"

    // Wraps responses in a MockEngine that auto-handles /auth before serving data responses
    // from the provided list. /auth never consumes a response slot.
    private fun buildRepo(responses: List<String>): YaloMessageRepositoryRemote {
        val authResponse = """{"access_token":"$fakeJwt","refresh_token":"rt","expires_in":3600}"""
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
        return YaloMessageRepositoryRemote(apiService, pollingIntervalMs = 0L)
    }

    private fun messageJson(id: String, text: String, role: String? = null): String {
        val roleField = if (role != null) ""","role":"$role"""" else ""
        return """[{"id":"$id","message":{"timestamp":{"seconds":1704110400,"nanos":0},"Payload":{"TextMessageRequest":{"content":{"text":"$text"$roleField}}}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"}]"""
    }

    // ── sendMessage ────────────────────────────────────────────────────────────

    @Test
    fun `sendMessage text returns Ok when api succeeds`() = runTest {
        val repo = buildRepo(listOf("{}"))
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Text,
            status = MessageStatus.SENT, content = "hello",
        )
        assertIs<Result.Ok<Unit>>(repo.sendMessage(message))
    }

    @Test
    fun `sendMessage non-text type returns Error`() = runTest {
        val repo = buildRepo(emptyList())
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Image,
            status = MessageStatus.SENT, content = "",
        )
        assertIs<Result.Error<Unit>>(repo.sendMessage(message))
    }

    // ── fetchMessages ──────────────────────────────────────────────────────────

    @Test
    fun `fetchMessages maps response to ChatMessage`() = runTest {
        val repo = buildRepo(listOf(messageJson("id-1", "Hello from server", "MESSAGE_ROLE_AGENT")))
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
        val repo = buildRepo(listOf(messageJson("id-1", "Hi"), messageJson("id-1", "Hi")))
        val first = repo.fetchMessages(since = 0L)
        val second = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(first)
        assertIs<Result.Ok<List<ChatMessage>>>(second)
        assertEquals(1, first.result.size)
        assertEquals(1, second.result.size)
    }

    // ── pollIncomingMessages ───────────────────────────────────────────────────
    // Each emission is now a List<ChatMessage> (one poll cycle = one batch).

    @Test
    fun `pollIncomingMessages emits batch from first poll`() = runTest {
        val repo = buildRepo(listOf(messageJson("id-1", "Hi"), "[]"))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals("Hi", batch.first().content)
    }

    @Test
    fun `pollIncomingMessages deduplicates — same wiId emitted only once across batches`() = runTest {
        // Poll 1: [id-1]. Poll 2: [id-1 (dup), id-2 (new)] → batch 2 = [id-2] only.
        val bothMessages = """[
            {"id":"id-1","message":{"timestamp":{"seconds":1704110400,"nanos":0},"Payload":{"TextMessageRequest":{"content":{"text":"First"}}}},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"IN_DELIVERY"},
            {"id":"id-2","message":{"timestamp":{"seconds":1704110401,"nanos":0},"Payload":{"TextMessageRequest":{"content":{"text":"Second"}}}},"date":"2024-01-01T12:00:01Z","user_id":"u1","status":"IN_DELIVERY"}
        ]"""
        val repo = buildRepo(listOf(messageJson("id-1", "First"), bothMessages))
        val batches = repo.pollIncomingMessages().take(2).toList()
        assertEquals(2, batches.size)
        assertEquals(1, batches[0].size)
        assertEquals("First", batches[0].first().content)
        assertEquals(1, batches[1].size)
        assertEquals("Second", batches[1].first().content)
    }

    @Test
    fun `pollIncomingMessages continues polling after network error`() = runTest {
        // Mirrors Flutter _startPolling(): on error the loop continues without restarting.
        // First call returns 500, second call returns a message — first() collects it.
        val authResponse = """{"access_token":"$fakeJwt","refresh_token":"rt","expires_in":3600}"""
        var dataCallIndex = 0
        val engine = MockEngine { request ->
            if (request.url.encodedPath.endsWith("/auth")) {
                respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            } else {
                dataCallIndex++
                if (dataCallIndex == 1) respondError(HttpStatusCode.InternalServerError)
                else respond(
                    messageJson("id-1", "After error", "MESSAGE_ROLE_AGENT"),
                    HttpStatusCode.OK,
                    headersOf(HttpHeaders.ContentType, "application/json"),
                )
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
        val repo = YaloMessageRepositoryRemote(apiService, pollingIntervalMs = 0L)
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals("After error", batch.first().content)
    }

    @Test
    fun `pollIncomingMessages maps MESSAGE_ROLE_USER to USER`() = runTest {
        val repo = buildRepo(listOf(messageJson("id-1", "Hey", "MESSAGE_ROLE_USER"), "[]"))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(MessageRole.USER, batch.first().role)
    }

    @Test
    fun `pollIncomingMessages maps MESSAGE_ROLE_AGENT to AGENT`() = runTest {
        val repo = buildRepo(listOf(messageJson("id-1", "Hey", "MESSAGE_ROLE_AGENT"), "[]"))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(MessageRole.AGENT, batch.first().role)
    }

    @Test
    fun `pollIncomingMessages defaults role to AGENT when role is absent`() = runTest {
        val repo = buildRepo(listOf(messageJson("id-1", "Hey"), "[]"))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(MessageRole.AGENT, batch.first().role)
    }

    @Test
    fun `pollIncomingMessages status is always DELIVERED`() = runTest {
        val repo = buildRepo(listOf(messageJson("id-1", "msg"), "[]"))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(MessageStatus.DELIVERED, batch.first().status)
    }

    @Test
    fun `pollIncomingMessages suppresses empty poll cycles`() = runTest {
        // First poll returns nothing, second returns a message → first() skips the empty cycle.
        val repo = buildRepo(listOf("[]", messageJson("id-1", "Eventually")))
        val batch = repo.pollIncomingMessages().first()
        assertEquals(1, batch.size)
        assertEquals("Eventually", batch.first().content)
        assertTrue(batch.first().role == MessageRole.AGENT)
    }

    // ── events() — typing indicator lifecycle ─────────────────────────────────

    // UnconfinedTestDispatcher is needed so the collect coroutine starts eagerly before
    // sendMessage()/pollIncomingMessages() call tryEmit() — SharedFlow with replay=0 drops
    // emissions that have no active subscribers at the time of emission.
    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun `sendMessage text emits TypingStart on events flow`() = runTest(UnconfinedTestDispatcher()) {
        val repo = buildRepo(listOf("{}"))
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Text,
            status = MessageStatus.SENT, content = "hello",
        )
        val collectedEvents = mutableListOf<ChatEvent>()
        // UnconfinedTestDispatcher: launch runs eagerly so collect is active before sendMessage.
        val collectJob = launch { repo.events().collect { collectedEvents.add(it) } }
        repo.sendMessage(message)
        yield() // drain unconfined event queue before cancelling
        collectJob.cancel()
        assertEquals(1, collectedEvents.size)
        assertIs<ChatEvent.TypingStart>(collectedEvents[0])
        assertEquals("Writing message...", (collectedEvents[0] as ChatEvent.TypingStart).statusText) // matches TYPING_STATUS_TEXT
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun `sendMessage non-text does not emit TypingStart`() = runTest(UnconfinedTestDispatcher()) {
        val repo = buildRepo(emptyList())
        val message = ChatMessage(
            role = MessageRole.USER, type = MessageType.Image,
            status = MessageStatus.SENT, content = "",
        )
        val collectedEvents = mutableListOf<ChatEvent>()
        val collectJob = launch { repo.events().collect { collectedEvents.add(it) } }
        repo.sendMessage(message)
        yield() // drain unconfined event queue before cancelling
        collectJob.cancel()
        assertTrue(collectedEvents.isEmpty())
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun `pollIncomingMessages emits TypingStop when messages are received`() = runTest(UnconfinedTestDispatcher()) {
        val repo = buildRepo(listOf(messageJson("id-1", "Hi")))
        val collectedEvents = mutableListOf<ChatEvent>()
        val collectJob = launch { repo.events().collect { collectedEvents.add(it) } }
        // Consume the first non-empty batch — TypingStop should be emitted before it.
        repo.pollIncomingMessages().first()
        // yield() drains the unconfined event queue so collectJob processes the TypingStop
        // before we cancel it. Without this, collectJob.cancel() races with the pending delivery.
        yield()
        collectJob.cancel()
        assertEquals(1, collectedEvents.size)
        assertIs<ChatEvent.TypingStop>(collectedEvents[0])
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun `pollIncomingMessages emits TypingStop on network error`() = runTest(UnconfinedTestDispatcher()) {
        val authResponse = """{"access_token":"$fakeJwt","refresh_token":"rt","expires_in":3600}"""
        var dataCallIndex = 0
        val engine = MockEngine { request ->
            if (request.url.encodedPath.endsWith("/auth")) {
                respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            } else {
                dataCallIndex++
                if (dataCallIndex == 1) respondError(HttpStatusCode.InternalServerError)
                // Second call returns a message so pollIncomingMessages().first() can complete.
                else respond(
                    messageJson("id-1", "After error"),
                    HttpStatusCode.OK,
                    headersOf(HttpHeaders.ContentType, "application/json"),
                )
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
        val repo = YaloMessageRepositoryRemote(apiService, pollingIntervalMs = 0L)
        val collectedEvents = mutableListOf<ChatEvent>()
        val collectJob = launch { repo.events().collect { collectedEvents.add(it) } }
        // first() completes after the second (successful) poll cycle.
        repo.pollIncomingMessages().first()
        yield() // drain unconfined event queue before cancelling
        collectJob.cancel()
        // First error poll → TypingStop; second successful poll → another TypingStop.
        assertTrue(collectedEvents.isNotEmpty())
        assertTrue(collectedEvents.all { it is ChatEvent.TypingStop })
    }
}

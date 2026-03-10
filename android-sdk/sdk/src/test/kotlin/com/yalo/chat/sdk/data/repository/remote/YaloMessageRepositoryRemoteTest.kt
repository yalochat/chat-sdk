// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
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
import kotlinx.coroutines.flow.take
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs

class YaloMessageRepositoryRemoteTest {

    private fun buildRepo(responses: List<String>): YaloMessageRepositoryRemote {
        var callIndex = 0
        val engine = MockEngine {
            val body = if (callIndex < responses.size) responses[callIndex++] else "[]"
            respond(body, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
        }
        val client = HttpClient(engine) {
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        val apiService = YaloChatApiService(
            apiBaseUrl = "https://api.test",
            authToken = "auth",
            userToken = "user",
            flowKey = "flow",
            httpClient = client,
        )
        return YaloMessageRepositoryRemote(apiService, pollingIntervalMs = 0L)
    }

    private fun messageJson(id: String, text: String, role: String = "AGENT") =
        """[{"id":"$id","message":{"text":"$text","role":"$role"},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"DELIVERED"}]"""

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
        val repo = buildRepo(listOf(messageJson("id-1", "Hello from server", "AGENT")))
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

    @Test
    fun `pollIncomingMessages emits messages from first poll`() = runTest {
        val repo = buildRepo(listOf(messageJson("id-1", "Hi"), "[]"))
        val messages = repo.pollIncomingMessages().take(1).toList()
        assertEquals(1, messages.size)
        assertEquals("Hi", messages.first().content)
    }

    @Test
    fun `pollIncomingMessages deduplicates — same wiId is emitted only once`() = runTest {
        // First poll: id-1 only. Second poll: id-1 (dup) + id-2 (new).
        val bothMessages = """[
            {"id":"id-1","message":{"text":"First","role":"AGENT"},"date":"2024-01-01T12:00:00Z","user_id":"u1","status":"DELIVERED"},
            {"id":"id-2","message":{"text":"Second","role":"AGENT"},"date":"2024-01-01T12:00:01Z","user_id":"u1","status":"DELIVERED"}
        ]"""
        val repo = buildRepo(listOf(messageJson("id-1", "First"), bothMessages))
        // take(2): id-1 from poll 1, id-2 from poll 2; id-1 is suppressed by the cache
        val messages = repo.pollIncomingMessages().take(2).toList()
        assertEquals(2, messages.size)
        assertEquals("First", messages[0].content)
        assertEquals("Second", messages[1].content)
    }

    @Test
    fun `pollIncomingMessages swallows network error and continues on next tick`() = runTest {
        var callIndex = 0
        val engine = MockEngine {
            callIndex++
            if (callIndex == 1) respondError(HttpStatusCode.InternalServerError)
            else respond(
                messageJson("id-1", "After error"),
                HttpStatusCode.OK,
                headersOf(HttpHeaders.ContentType, "application/json"),
            )
        }
        val client = HttpClient(engine) {
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        val apiService = YaloChatApiService(
            apiBaseUrl = "https://api.test", authToken = "a", userToken = "u", flowKey = "f",
            httpClient = client,
        )
        val repo = YaloMessageRepositoryRemote(apiService, pollingIntervalMs = 0L)
        // First poll errors; second poll succeeds — we should still receive the message
        val messages = repo.pollIncomingMessages().take(1).toList()
        assertEquals(1, messages.size)
        assertEquals("After error", messages.first().content)
    }

    @Test
    fun `pollIncomingMessages sets MessageRole from server role field`() = runTest {
        val repo = buildRepo(listOf(messageJson("id-1", "Hey", "USER"), "[]"))
        val messages = repo.pollIncomingMessages().take(1).toList()
        assertEquals(MessageRole.USER, messages.first().role)
    }

    @Test
    fun `pollIncomingMessages status is always DELIVERED`() = runTest {
        val repo = buildRepo(listOf(messageJson("id-1", "msg"), "[]"))
        val messages = repo.pollIncomingMessages().take(1).toList()
        assertEquals(MessageStatus.DELIVERED, messages.first().status)
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.model.SdkMessageBody
import com.yalo.chat.sdk.data.remote.model.SdkTextMessageBody
import com.yalo.chat.sdk.data.remote.model.SdkTextMessageRequestBody
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.MockRequestHandler
import io.ktor.client.engine.mock.respond
import io.ktor.client.engine.mock.respondError
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.headersOf
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNull
import kotlin.test.assertTrue

class YaloChatApiServiceTest {

    // A minimal JWT whose payload decodes to {"user_id":"test-user"}.
    // Header:  {"alg":"HS256","typ":"JWT"} → eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
    // Payload: {"user_id":"test-user"}     → eyJ1c2VyX2lkIjoidGVzdC11c2VyIn0
    private val fakeJwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" +
        ".eyJ1c2VyX2lkIjoidGVzdC11c2VyIn0" +
        ".fakesig"
    private val fakeUserId = "test-user"
    private val fakeChannelId = "channel-id"

    // Wraps a request handler in a MockEngine that auto-responds to /auth before
    // delegating all other requests to the provided handler.
    private fun apiService(handler: MockRequestHandler): YaloChatApiService {
        val authResponse = """{"access_token":"$fakeJwt","refresh_token":"rt","expires_in":3600}"""
        val engine = MockEngine { request ->
            if (request.url.encodedPath.endsWith("/auth")) {
                respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            } else {
                handler(request)
            }
        }
        val client = HttpClient(engine) {
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        return YaloChatApiService(
            apiBaseUrl = "https://api.test",
            channelId = fakeChannelId,
            organizationId = "org-id",
            httpClient = client,
        )
    }

    private val testRequest = SdkMessageBody(
        correlationId = "test-correlation-id",
        timestamp = "2024-01-01T00:00:00Z",
        textMessageRequest = SdkTextMessageRequestBody(
            content = SdkTextMessageBody(text = "hello", timestamp = "2024-01-01T00:00:00Z"),
            timestamp = "2024-01-01T00:00:00Z",
        ),
    )

    // ── sendTextMessage ────────────────────────────────────────────────────────

    @Test
    fun `sendTextMessage returns Ok on HTTP 200`() = runTest {
        val service = apiService {
            respond("{}", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
        }
        assertIs<Result.Ok<Unit>>(service.sendMessage(testRequest))
    }

    @Test
    fun `sendTextMessage returns Error on HTTP 500`() = runTest {
        val service = apiService {
            respondError(HttpStatusCode.InternalServerError)
        }
        val result = service.sendMessage(testRequest)
        assertIs<Result.Error<Unit>>(result)
        assertTrue(result.error.message?.contains("500") == true)
    }

    @Test
    fun `sendTextMessage returns Error on network exception`() = runTest {
        val authResponse = """{"access_token":"$fakeJwt","refresh_token":"rt","expires_in":3600}"""
        var authHandled = false
        val engine = MockEngine { request ->
            if (request.url.encodedPath.endsWith("/auth")) {
                authHandled = true
                respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            } else {
                throw RuntimeException("no network")
            }
        }
        val client = HttpClient(engine) {
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        val service = YaloChatApiService("https://api.test", fakeChannelId, "org-id", client)
        assertIs<Result.Error<Unit>>(service.sendMessage(testRequest))
        assertTrue(authHandled)
    }

    @Test
    fun `sendTextMessage sends correct auth headers`() = runTest {
        var capturedHeaders: io.ktor.http.Headers? = null
        val service = apiService { request ->
            capturedHeaders = request.headers
            respond("{}", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
        }
        service.sendMessage(testRequest)
        assertEquals("Bearer $fakeJwt", capturedHeaders?.get("Authorization"))
        assertEquals(fakeUserId, capturedHeaders?.get("x-user-id"))
        assertEquals(fakeChannelId, capturedHeaders?.get("x-channel-id"))
    }

    @Test
    fun `sendTextMessage uses inapp inbound_messages endpoint`() = runTest {
        var capturedUrl: io.ktor.http.Url? = null
        val service = apiService { request ->
            capturedUrl = request.url
            respond("{}", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
        }
        service.sendMessage(testRequest)
        assertTrue(capturedUrl?.encodedPath?.endsWith("/inapp/inbound_messages") == true)
    }

    // ── fetchMessages ──────────────────────────────────────────────────────────

    @Test
    fun `fetchMessages returns Ok with parsed list on HTTP 200`() = runTest {
        val body = """
            [{"id":"msg-1","message":{"timestamp":"2024-01-01T00:00:00Z","textMessageRequest":{"content":{"text":"Hi"}}},"date":"2024-01-01T00:00:00Z","user_id":"u1","status":"IN_DELIVERY"}]
        """.trimIndent()
        val service = apiService {
            respond(body, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
        }
        val result = service.fetchMessages()
        assertIs<Result.Ok<List<YaloFetchMessagesResponse>>>(result)
        assertEquals(1, result.result.size)
        assertEquals("msg-1", result.result.first().id)
        assertEquals("Hi", result.result.first().message.textMessageRequest?.content?.text)
    }

    @Test
    fun `fetchMessages returns empty list when server returns empty array`() = runTest {
        val service = apiService {
            respond("[]", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
        }
        val result = service.fetchMessages()
        assertIs<Result.Ok<List<YaloFetchMessagesResponse>>>(result)
        assertTrue(result.result.isEmpty())
    }

    @Test
    fun `fetchMessages returns Error on HTTP 401`() = runTest {
        val service = apiService { respondError(HttpStatusCode.Unauthorized) }
        val result = service.fetchMessages()
        assertIs<Result.Error<*>>(result)
        assertTrue(result.error.message?.contains("401") == true)
    }

    @Test
    fun `fetchMessages returns Error on network exception`() = runTest {
        val authResponse = """{"access_token":"$fakeJwt","refresh_token":"rt","expires_in":3600}"""
        val engine = MockEngine { request ->
            if (request.url.encodedPath.endsWith("/auth")) {
                respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            } else {
                throw RuntimeException("timeout")
            }
        }
        val client = HttpClient(engine) {
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        val service = YaloChatApiService("https://api.test", fakeChannelId, "org-id", client)
        assertIs<Result.Error<*>>(service.fetchMessages())
    }

    @Test
    fun `fetchMessages does not send since query parameter`() = runTest {
        // Flutter FIXME disables the since param — we match that behaviour.
        var capturedUrl: io.ktor.http.Url? = null
        val service = apiService { request ->
            capturedUrl = request.url
            respond("[]", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
        }
        service.fetchMessages()
        assertNull(capturedUrl?.parameters?.get("since"))
    }

    @Test
    fun `fetchMessages uses inapp messages endpoint`() = runTest {
        var capturedUrl: io.ktor.http.Url? = null
        val service = apiService { request ->
            capturedUrl = request.url
            respond("[]", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
        }
        service.fetchMessages()
        assertTrue(capturedUrl?.encodedPath?.endsWith("/inapp/messages") == true)
    }

    // ── Authentication ─────────────────────────────────────────────────────────

    @Test
    fun `auth failure propagates as Error from sendTextMessage`() = runTest {
        val engine = MockEngine { respondError(HttpStatusCode.Unauthorized) }
        val client = HttpClient(engine) {
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        val service = YaloChatApiService("https://api.test", fakeChannelId, "org-id", client)
        assertIs<Result.Error<Unit>>(service.sendMessage(testRequest))
    }

    @Test
    fun `token is cached and auth is called only once for two consecutive requests`() = runTest {
        var authCallCount = 0
        val authResponse = """{"access_token":"$fakeJwt","refresh_token":"rt","expires_in":3600}"""
        val engine = MockEngine { request ->
            if (request.url.encodedPath.endsWith("/auth")) {
                authCallCount++
                respond(authResponse, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            } else {
                respond("[]", HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
            }
        }
        val client = HttpClient(engine) {
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        val service = YaloChatApiService("https://api.test", fakeChannelId, "org-id", client)
        service.fetchMessages()
        service.fetchMessages()
        assertEquals(1, authCallCount)
    }
}

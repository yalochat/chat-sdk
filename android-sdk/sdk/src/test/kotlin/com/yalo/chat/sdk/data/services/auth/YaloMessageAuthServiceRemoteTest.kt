// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.services.auth

import com.yalo.chat.sdk.common.Result
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
import kotlin.test.assertTrue

class YaloMessageAuthServiceRemoteTest {

    companion object {
        private const val BASE_URL = "https://api.test"
        private const val CHANNEL_ID = "ch-1"
        private const val ORGANIZATION_ID = "org-1"
        private const val ACCESS_TOKEN = "access-token-abc"
        private const val REFRESH_TOKEN = "refresh-token-xyz"

        private fun authResponseBody(
            access: String = ACCESS_TOKEN,
            refresh: String = REFRESH_TOKEN,
            expiresIn: Int = 3600,
        ) = """{"access_token":"$access","refresh_token":"$refresh","expires_in":$expiresIn}"""

        // expiresIn=0 makes the token immediately stale.
        private fun expiredAuthResponseBody() = authResponseBody(expiresIn = 0)
    }

    private fun buildService(handler: MockRequestHandler): YaloMessageAuthServiceRemote {
        val engine = MockEngine(handler)
        val client = HttpClient(engine) {
            install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        }
        return YaloMessageAuthServiceRemote(
            baseUrl = BASE_URL,
            channelId = CHANNEL_ID,
            organizationId = ORGANIZATION_ID,
            httpClient = client,
        )
    }

    // ── POST /auth — no cache ───────────────────────────────────────────────────

    @Test
    fun `auth POSTs to baseUrl slash auth when no cache exists`() = runTest {
        var capturedUrl: io.ktor.http.Url? = null
        val service = buildService { request ->
            capturedUrl = request.url
            respond(
                authResponseBody(),
                HttpStatusCode.OK,
                headersOf(HttpHeaders.ContentType, "application/json"),
            )
        }
        service.auth()
        assertEquals("$BASE_URL/auth", capturedUrl?.toString())
    }

    @Test
    fun `auth sends Content-Type application-json on initial fetch`() = runTest {
        var capturedHeaders: io.ktor.http.Headers? = null
        val service = buildService { request ->
            capturedHeaders = request.headers
            respond(
                authResponseBody(),
                HttpStatusCode.OK,
                headersOf(HttpHeaders.ContentType, "application/json"),
            )
        }
        service.auth()
        assertTrue(
            capturedHeaders?.get(HttpHeaders.ContentType)
                ?.contains("application/json") == true
        )
    }

    @Test
    fun `auth returns Ok with access token on HTTP 200`() = runTest {
        val service = buildService {
            respond(
                authResponseBody(),
                HttpStatusCode.OK,
                headersOf(HttpHeaders.ContentType, "application/json"),
            )
        }
        val result = service.auth()
        assertIs<Result.Ok<String>>(result)
        assertEquals(ACCESS_TOKEN, result.result)
    }

    @Test
    fun `auth returns Error on non-200 response`() = runTest {
        val service = buildService { respondError(HttpStatusCode.Unauthorized) }
        val result = service.auth()
        assertIs<Result.Error<String>>(result)
        assertTrue(result.error.message?.contains("401") == true)
    }

    @Test
    fun `auth returns Error when client throws`() = runTest {
        val service = buildService { throw RuntimeException("network error") }
        assertIs<Result.Error<String>>(service.auth())
    }

    // ── Cache — valid token ─────────────────────────────────────────────────────

    @Test
    fun `auth returns cached token without making a second HTTP call when token is valid`() = runTest {
        var callCount = 0
        val service = buildService {
            callCount++
            respond(
                authResponseBody(),
                HttpStatusCode.OK,
                headersOf(HttpHeaders.ContentType, "application/json"),
            )
        }
        service.auth()          // populates cache
        val result = service.auth() // should use cache

        assertEquals(1, callCount, "Expected exactly one HTTP call; cache should serve the second")
        assertIs<Result.Ok<String>>(result)
        assertEquals(ACCESS_TOKEN, result.result)
    }

    // ── Cache — expired token / refresh ────────────────────────────────────────

    @Test
    fun `auth calls oauth-token endpoint when cached token has expired`() = runTest {
        var lastUrl: io.ktor.http.Url? = null
        val service = buildService { request ->
            lastUrl = request.url
            val body = if (request.url.encodedPath.endsWith("/auth")) {
                expiredAuthResponseBody()
            } else {
                authResponseBody(access = "new-access-token")
            }
            respond(body, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
        }

        service.auth()          // fetches expired token
        val result = service.auth() // should refresh

        assertEquals("$BASE_URL/oauth/token", lastUrl?.toString())
        assertIs<Result.Ok<String>>(result)
        assertEquals("new-access-token", result.result)
    }

    @Test
    fun `auth sends grant_type and refresh_token in refresh request body`() = runTest {
        var capturedBody: String? = null
        val service = buildService { request ->
            val body = if (request.url.encodedPath.endsWith("/auth")) {
                expiredAuthResponseBody()
            } else {
                capturedBody = request.body.toByteArray().decodeToString()
                authResponseBody()
            }
            respond(body, HttpStatusCode.OK, headersOf(HttpHeaders.ContentType, "application/json"))
        }

        service.auth()  // seed expired cache
        service.auth()  // triggers refresh

        assertTrue(capturedBody?.contains("grant_type=refresh_token") == true)
        assertTrue(capturedBody?.contains("refresh_token=$REFRESH_TOKEN") == true)
    }

    @Test
    fun `auth clears cache and returns Error when refresh returns non-200`() = runTest {
        var callCount = 0
        val service = buildService { request ->
            callCount++
            when {
                request.url.encodedPath.endsWith("/auth") ->
                    respond(
                        expiredAuthResponseBody(),
                        HttpStatusCode.OK,
                        headersOf(HttpHeaders.ContentType, "application/json"),
                    )
                else -> respondError(HttpStatusCode.Unauthorized)
            }
        }

        service.auth()                          // populates expired cache
        val refreshResult = service.auth()      // refresh fails
        assertIs<Result.Error<String>>(refreshResult)

        // After cache is cleared the next call should go back to /auth.
        val retryResult = service.auth()
        // The retry itself also gets expiredAuthResponseBody so it returns Ok; what
        // matters is that a third HTTP call was made (not served from cache).
        assertEquals(3, callCount, "Expected 3 HTTP calls: initial /auth, failed /oauth/token, retry /auth")
        // retry returns Ok because the mock returns 200 for /auth again
        assertIs<Result.Ok<String>>(retryResult)
    }

    @Test
    fun `auth returns Error when refresh client throws`() = runTest {
        val service = buildService { request ->
            if (request.url.encodedPath.endsWith("/auth")) {
                respond(
                    expiredAuthResponseBody(),
                    HttpStatusCode.OK,
                    headersOf(HttpHeaders.ContentType, "application/json"),
                )
            } else {
                throw RuntimeException("network error during refresh")
            }
        }

        service.auth()                          // seed expired cache
        val result = service.auth()             // refresh throws
        assertIs<Result.Error<String>>(result)
    }
}

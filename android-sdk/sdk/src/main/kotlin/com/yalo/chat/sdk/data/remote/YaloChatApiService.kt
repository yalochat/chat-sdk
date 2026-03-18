// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.model.YaloAuthRequest
import com.yalo.chat.sdk.data.remote.model.YaloAuthResponse
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import com.yalo.chat.sdk.data.remote.model.YaloTextMessageRequest
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.forms.submitForm
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.request.parameter
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.Parameters
import io.ktor.http.contentType
import io.ktor.http.isSuccess
import io.ktor.serialization.kotlinx.json.json
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.serialization.json.Json

private const val HEADER_USER_ID = "x-user-id"
private const val HEADER_CHANNEL_ID = "x-channel-id"
private const val HEADER_AUTHORIZATION = "Authorization"
// Refresh 30 s before actual expiry to avoid a race between expiry check and the API call.
private const val TOKEN_REFRESH_BUFFER_MS = 30_000L

// Port of flutter-sdk YaloChatClient.
// Ktor replaces Dart's http package — same headers and endpoints.
// All network errors are wrapped in Result.Error; no exceptions are thrown.
//
// Auth flow mirrors Flutter: POST /auth with channelId + organizationId → access_token.
// The token is cached and refreshed automatically via POST /oauth/token.
// A Mutex serialises concurrent auth calls so only one in-flight /auth request can exist.
//
// KMP note: the HttpClient (with its platform engine) is provided by the caller —
// YaloChat.kt on Android passes an Android-engine client, tests pass a MockEngine client.
// When splitting to KMP: YaloChat.kt moves to androidMain and provides the Android engine;
// an iosMain counterpart provides the Darwin engine.
internal class YaloChatApiService(
    apiBaseUrl: String,
    private val channelId: String,
    private val organizationId: String,
    // Provided by the platform (YaloChat.kt on Android, tests via MockEngine).
    internal val httpClient: HttpClient,
) {
    private val apiBaseUrl = apiBaseUrl.trimEnd('/').removeSuffix("/webchat")
    private val tokenMutex = Mutex()
    private var accessToken: String? = null
    private var storedRefreshToken: String? = null
    private var tokenExpiresAt: Long = 0L
    private var userId: String = ""

    // ── Token management ───────────────────────────────────────────────────────

    // Returns a valid (accessToken, userId) pair, authenticating or refreshing as needed.
    // Mutex ensures only one in-flight auth call at a time even under concurrent requests.
    private suspend fun ensureValidToken(): Result<Pair<String, String>> =
        tokenMutex.withLock {
            val token = accessToken
            if (token != null && System.currentTimeMillis() < tokenExpiresAt - TOKEN_REFRESH_BUFFER_MS) {
                if (userId.isEmpty()) return@withLock Result.Error(RuntimeException("auth succeeded but user_id could not be extracted from JWT"))
                return@withLock Result.Ok(token to userId)
            }
            val rt = storedRefreshToken
            if (rt != null) {
                val refreshResult = doRefreshToken(rt)
                if (refreshResult is Result.Ok) return@withLock refreshResult
                // Refresh failed — clear stale tokens so the next call goes straight to re-auth
                // instead of retrying the refresh and doubling auth traffic.
                accessToken = null
                storedRefreshToken = null
            }
            doAuthenticate()
        }

    private suspend fun doAuthenticate(): Result<Pair<String, String>> {
        return try {
            val response = httpClient.post("$apiBaseUrl/auth") {
                contentType(ContentType.Application.Json)
                setBody(
                    YaloAuthRequest(
                        channelId = channelId,
                        organizationId = organizationId,
                        timestamp = System.currentTimeMillis(),
                    )
                )
            }
            if (response.status.isSuccess()) {
                val auth: YaloAuthResponse = response.body()
                cacheTokens(auth)
                if (userId.isEmpty()) {
                    accessToken = null
                    storedRefreshToken = null
                    return Result.Error(RuntimeException("auth succeeded but user_id could not be extracted from JWT"))
                }
                Result.Ok(auth.accessToken to userId)
            } else {
                Result.Error(RuntimeException("HTTP ${response.status.value}: auth failed"))
            }
        } catch (e: Exception) {
            Result.Error(e)
        }
    }

    private suspend fun doRefreshToken(refreshToken: String): Result<Pair<String, String>> {
        return try {
            val response = httpClient.submitForm(
                url = "$apiBaseUrl/oauth/token",
                formParameters = Parameters.build {
                    append("grant_type", "refresh_token")
                    append("refresh_token", refreshToken)
                },
            )
            if (response.status.isSuccess()) {
                val auth: YaloAuthResponse = response.body()
                cacheTokens(auth)
                if (userId.isEmpty()) {
                    accessToken = null
                    storedRefreshToken = null
                    return Result.Error(RuntimeException("token refresh succeeded but user_id could not be extracted from JWT"))
                }
                Result.Ok(auth.accessToken to userId)
            } else {
                Result.Error(RuntimeException("HTTP ${response.status.value}: token refresh failed"))
            }
        } catch (e: Exception) {
            Result.Error(e)
        }
    }

    private fun cacheTokens(auth: YaloAuthResponse) {
        accessToken = auth.accessToken
        storedRefreshToken = auth.refreshToken
        tokenExpiresAt = System.currentTimeMillis() + auth.expiresIn * 1000L
        userId = extractUserIdFromJwt(auth.accessToken)
    }

    // JWT payloads use URL-safe base64 without padding. Normalise to standard base64 with
    // padding so kotlin.io.encoding.Base64.Default (which requires padding) can decode it.
    @OptIn(ExperimentalEncodingApi::class)
    private fun extractUserIdFromJwt(token: String): String = try {
        val rawPayload = token.split(".").getOrNull(1) ?: return ""
        val padded = when (rawPayload.length % 4) {
            2 -> "$rawPayload=="
            3 -> "$rawPayload="
            else -> rawPayload
        }.replace('-', '+').replace('_', '/')
        val decoded = String(Base64.Default.decode(padded), Charsets.UTF_8)
        Regex(""""user_id"\s*:\s*"([^"]+)"""").find(decoded)?.groupValues?.get(1) ?: ""
    } catch (_: Exception) {
        ""
    }

    // ── API calls ─────────────────────────────────────────────────────────────

    // POST /webchat/inbound_messages — send a text message to the Yalo backend.
    suspend fun sendTextMessage(request: YaloTextMessageRequest): Result<Unit> {
        val tokenResult = ensureValidToken()
        if (tokenResult is Result.Error) return Result.Error(tokenResult.error)
        val (token, uid) = (tokenResult as Result.Ok).result
        return try {
            val response = httpClient.post("$apiBaseUrl/webchat/inbound_messages") {
                contentType(ContentType.Application.Json)
                header(HEADER_USER_ID, uid)
                header(HEADER_CHANNEL_ID, channelId)
                header(HEADER_AUTHORIZATION, "Bearer $token")
                setBody(request)
            }
            if (response.status.isSuccess()) Result.Ok(Unit)
            else Result.Error(RuntimeException("HTTP ${response.status.value}: send failed"))
        } catch (e: Exception) {
            Result.Error(e)
        }
    }

    // GET /webchat/messages?since={timestamp} — fetch messages newer than the given timestamp.
    suspend fun fetchMessages(since: Long): Result<List<YaloFetchMessagesResponse>> {
        val tokenResult = ensureValidToken()
        if (tokenResult is Result.Error) return Result.Error(tokenResult.error)
        val (token, uid) = (tokenResult as Result.Ok).result
        return try {
            val response = httpClient.get("$apiBaseUrl/webchat/messages") {
                parameter("since", since)
                header(HEADER_USER_ID, uid)
                header(HEADER_CHANNEL_ID, channelId)
                header(HEADER_AUTHORIZATION, "Bearer $token")
            }
            if (response.status.isSuccess()) Result.Ok(response.body())
            else Result.Error(RuntimeException("HTTP ${response.status.value}: fetch failed"))
        } catch (e: Exception) {
            Result.Error(e)
        }
    }
}

// Builds a configured HttpClient with ContentNegotiation (JSON) and optional debug logging.
// Called from YaloChat.kt with the platform engine (Android/Darwin/etc.).
// internal: not part of the public SDK API surface.
internal fun buildHttpClient(engine: io.ktor.client.engine.HttpClientEngine, debug: Boolean): HttpClient =
    HttpClient(engine) {
        install(ContentNegotiation) {
            json(Json { ignoreUnknownKeys = true })
        }
        if (debug) {
            install(io.ktor.client.plugins.logging.Logging) {
                logger = object : io.ktor.client.plugins.logging.Logger {
                    override fun log(message: String) { println(message) }
                }
                // HEADERS only — avoids logging request/response bodies in plaintext.
                level = io.ktor.client.plugins.logging.LogLevel.HEADERS
                // Redact sensitive headers so they never appear in Logcat.
                sanitizeHeader { header ->
                    header == io.ktor.http.HttpHeaders.Authorization ||
                        header.equals(HEADER_USER_ID, ignoreCase = true) ||
                        header.equals(HEADER_CHANNEL_ID, ignoreCase = true)
                }
            }
        }
    }

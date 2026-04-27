// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.model.SdkAddPromotionRequestBody
import com.yalo.chat.sdk.data.remote.model.SdkAddToCartRequestBody
import com.yalo.chat.sdk.data.remote.model.SdkClearCartRequestBody
import com.yalo.chat.sdk.data.remote.model.SdkRemoveFromCartRequestBody
import com.yalo.chat.sdk.data.remote.model.YaloAuthRequest
import com.yalo.chat.sdk.data.remote.model.YaloAuthResponse
import com.yalo.chat.sdk.data.remote.model.MediaUploadResponse
import com.yalo.chat.sdk.data.remote.model.SdkMessageBody
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.forms.formData
import io.ktor.client.request.forms.submitForm
import io.ktor.client.request.forms.submitFormWithBinaryData
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
import kotlinx.datetime.Clock
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

private const val HEADER_USER_ID = "x-user-id"
private const val HEADER_CHANNEL_ID = "x-channel-id"
private const val HEADER_AUTHORIZATION = "Authorization"
private const val CLAIM_USER_ID = "user_id"
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
    private val apiBaseUrl = apiBaseUrl.trimEnd('/').removeSuffix("/inapp").removeSuffix("/webchat")
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
            if (token != null && Clock.System.now().toEpochMilliseconds() < tokenExpiresAt - TOKEN_REFRESH_BUFFER_MS) {
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
                        timestamp = Clock.System.now().toEpochMilliseconds(),
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
        tokenExpiresAt = Clock.System.now().toEpochMilliseconds() + auth.expiresIn * 1000L
        userId = extractUserIdFromJwt(auth.accessToken)
    }

    // JWT payloads use URL-safe base64 without padding. Add padding so
    // Base64.UrlSafe (which requires it) can decode, then parse the JSON
    // payload properly instead of using a regex on the raw string.
    @OptIn(ExperimentalEncodingApi::class)
    private fun extractUserIdFromJwt(token: String): String = try {
        val rawPayload = token.split(".").getOrNull(1) ?: return ""
        val padding = when (rawPayload.length % 4) {
            2 -> "=="
            3 -> "="
            else -> ""
        }
        val decoded = Base64.UrlSafe.decode(rawPayload + padding).decodeToString()
        Json.parseToJsonElement(decoded).jsonObject[CLAIM_USER_ID]?.jsonPrimitive?.contentOrNull ?: ""
    } catch (_: Exception) {
        ""
    }

    // ── API calls ─────────────────────────────────────────────────────────────

    // POST /inapp/inbound_messages — send a message to the Yalo backend.
    suspend fun sendMessage(request: SdkMessageBody): Result<Unit> {
        val tokenResult = ensureValidToken()
        if (tokenResult is Result.Error) return Result.Error(tokenResult.error)
        val (token, uid) = (tokenResult as Result.Ok).result
        return try {
            val response = httpClient.post("$apiBaseUrl/inapp/inbound_messages") {
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

    // POST /all/media — multipart upload of a media file (image or voice).
    // Returns 201 with MediaUploadResponse JSON; the `id` field is used as `mediaUrl` in protos.
    // Mirrors Flutter's YaloMediaServiceRemote.uploadMedia().
    suspend fun uploadMedia(
        bytes: ByteArray,
        filename: String,
        mimeType: String,
    ): Result<MediaUploadResponse> {
        val tokenResult = ensureValidToken()
        if (tokenResult is Result.Error) return Result.Error(tokenResult.error)
        val (token, _) = (tokenResult as Result.Ok).result
        return try {
            val response = httpClient.submitFormWithBinaryData(
                url = "$apiBaseUrl/all/media",
                formData = formData {
                    append(
                        key = "file",
                        value = bytes,
                        headers = io.ktor.http.Headers.build {
                            append(io.ktor.http.HttpHeaders.ContentType, mimeType)
                            append(
                                io.ktor.http.HttpHeaders.ContentDisposition,
                                "filename=\"$filename\""
                            )
                        },
                    )
                },
            ) {
                header(HEADER_AUTHORIZATION, "Bearer $token")
            }
            if (response.status.value == 201) Result.Ok(response.body())
            else Result.Error(RuntimeException("HTTP ${response.status.value}: media upload failed"))
        } catch (e: Exception) {
            Result.Error(e)
        }
    }

    // GET <mediaUrl> — download media bytes from CDN. No auth header required (signed URL).
    // Mirrors Flutter's YaloMediaServiceRemote.downloadMedia().
    suspend fun downloadMedia(url: String): Result<ByteArray> =
        try {
            val response = httpClient.get(url)
            if (response.status.isSuccess()) Result.Ok(response.body<ByteArray>())
            else Result.Error(RuntimeException("HTTP ${response.status.value}: media download failed"))
        } catch (e: Exception) {
            Result.Error(e)
        }

    // Cart operations — mirrors flutter-sdk YaloMessageServiceRemote.
    // Each method builds the corresponding proto-JSON SdkMessageBody and POSTs to /inapp/inbound_messages.

    suspend fun addToCart(sku: String, quantity: Double): Result<Unit> {
        val now = Clock.System.now().toString()
        return sendMessage(SdkMessageBody(
            correlationId = "add-to-cart-$sku-${Clock.System.now().toEpochMilliseconds()}",
            timestamp = now,
            addToCartRequest = SdkAddToCartRequestBody(sku = sku, quantity = quantity, timestamp = now),
        ))
    }

    suspend fun removeFromCart(sku: String, quantity: Double?): Result<Unit> {
        val now = Clock.System.now().toString()
        return sendMessage(SdkMessageBody(
            correlationId = "remove-from-cart-$sku-${Clock.System.now().toEpochMilliseconds()}",
            timestamp = now,
            removeFromCartRequest = SdkRemoveFromCartRequestBody(sku = sku, quantity = quantity, timestamp = now),
        ))
    }

    suspend fun clearCart(): Result<Unit> {
        val now = Clock.System.now().toString()
        return sendMessage(SdkMessageBody(
            correlationId = "clear-cart-${Clock.System.now().toEpochMilliseconds()}",
            timestamp = now,
            clearCartRequest = SdkClearCartRequestBody(timestamp = now),
        ))
    }

    suspend fun addPromotion(promotionId: String): Result<Unit> {
        val now = Clock.System.now().toString()
        return sendMessage(SdkMessageBody(
            correlationId = "add-promotion-$promotionId-${Clock.System.now().toEpochMilliseconds()}",
            timestamp = now,
            addPromotionRequest = SdkAddPromotionRequestBody(promotionId = promotionId, timestamp = now),
        ))
    }

    // GET /inapp/messages — fetch all messages; deduplication is handled client-side.
    // NOTE: Flutter SDK has a FIXME disabling the `since` query param ("wait for backend fix"),
    // so we match Flutter and omit it. Client-side deduplication via SimpleCache handles repeats.
    suspend fun fetchMessages(): Result<List<YaloFetchMessagesResponse>> {
        val tokenResult = ensureValidToken()
        if (tokenResult is Result.Error) return Result.Error(tokenResult.error)
        val (token, uid) = (tokenResult as Result.Ok).result
        return try {
            val response = httpClient.get("$apiBaseUrl/inapp/messages") {
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
        // Global timeouts: 60s request covers CDN downloads and large image uploads on slow
        // networks; 10s connect and 30s socket provide safety nets for all request types.
        install(HttpTimeout) {
            requestTimeoutMillis = 60_000
            connectTimeoutMillis = 10_000
            socketTimeoutMillis = 30_000
        }
        if (debug) {
            install(io.ktor.client.plugins.logging.Logging) {
                logger = object : io.ktor.client.plugins.logging.Logger {
                    override fun log(message: String) { println(message) }
                }
                level = io.ktor.client.plugins.logging.LogLevel.INFO
            }
        }
    }

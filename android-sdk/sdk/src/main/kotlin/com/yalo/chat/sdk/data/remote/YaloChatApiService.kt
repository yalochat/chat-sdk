// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import com.yalo.chat.sdk.data.remote.model.YaloTextMessageRequest
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.request.parameter
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.contentType
import io.ktor.http.isSuccess
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

private const val HEADER_USER_ID = "x-user-id"
private const val HEADER_CHANNEL_ID = "x-channel-id"
private const val HEADER_AUTHORIZATION = "Authorization"

// Port of flutter-sdk YaloChatClient.
// Ktor replaces Dart's http package — same headers and endpoints.
// All network errors are wrapped in Result.Error; no exceptions are thrown.
//
// KMP note: the HttpClient (with its platform engine) is provided by the caller —
// YaloChat.kt on Android passes an Android-engine client, tests pass a MockEngine client.
// When splitting to KMP: YaloChat.kt moves to androidMain and provides the Android engine;
// an iosMain counterpart provides the Darwin engine.
internal class YaloChatApiService(
    private val apiBaseUrl: String,
    private val authToken: String,
    private val userToken: String,
    private val flowKey: String,
    // Provided by the platform (YaloChat.kt on Android, tests via MockEngine).
    internal val httpClient: HttpClient,
) {
    // POST /inbound_messages — send a text message to the Yalo backend.
    suspend fun sendTextMessage(request: YaloTextMessageRequest): Result<Unit> = try {
        val response = httpClient.post("$apiBaseUrl/inbound_messages") {
            contentType(ContentType.Application.Json)
            header(HEADER_USER_ID, userToken)
            header(HEADER_CHANNEL_ID, flowKey)
            header(HEADER_AUTHORIZATION, "Bearer $authToken")
            setBody(request)
        }
        if (response.status.isSuccess()) Result.Ok(Unit)
        else Result.Error(RuntimeException("HTTP ${response.status.value}: send failed"))
    } catch (e: Exception) {
        Result.Error(e)
    }

    // GET /messages?since={timestamp} — fetch messages newer than the given Unix second timestamp.
    suspend fun fetchMessages(since: Long): Result<List<YaloFetchMessagesResponse>> = try {
        val response = httpClient.get("$apiBaseUrl/messages") {
            parameter("since", since)
            header(HEADER_USER_ID, userToken)
            header(HEADER_CHANNEL_ID, flowKey)
            header(HEADER_AUTHORIZATION, "Bearer $authToken")
        }
        if (response.status.isSuccess()) Result.Ok(response.body())
        else Result.Error(RuntimeException("HTTP ${response.status.value}: fetch failed"))
    } catch (e: Exception) {
        Result.Error(e)
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

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote

import com.yalo.chat.sdk.BuildConfig
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import com.yalo.chat.sdk.data.remote.model.YaloTextMessageRequest
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.engine.cio.CIO
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
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
// Ktor (CIO engine) replaces Dart's http package — same headers and endpoints.
// All network errors are wrapped in Result.Error; no exceptions are thrown.
//
// KMP note: CIO engine is JVM/Android only. When splitting to a KMP module the
// engine will move to androidMain and a Darwin engine added for iosMain.
class YaloChatApiService(
    private val apiBaseUrl: String,
    private val authToken: String,
    private val userToken: String,
    private val flowKey: String,
    // Exposed as internal so tests can inject a MockEngine-backed client.
    internal val httpClient: HttpClient = defaultClient(),
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

// KMP note: Logging uses println() which works on all Kotlin targets.
// When the module is split, the CIO engine + Logging installation can move to
// androidMain/iosMain and each target can use its own native logger.
private fun defaultClient() = HttpClient(CIO) {
    install(ContentNegotiation) {
        json(Json { ignoreUnknownKeys = true })
    }
    if (BuildConfig.DEBUG) {
        install(Logging) {
            logger = object : Logger {
                override fun log(message: String) { println(message) }
            }
            level = LogLevel.ALL
        }
    }
}

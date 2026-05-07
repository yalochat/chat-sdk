// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import io.ktor.client.HttpClient
import io.ktor.client.plugins.websocket.webSocket
import io.ktor.http.encodeURLParameter
import io.ktor.websocket.Frame
import io.ktor.websocket.readText
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json

// Port of flutter-sdk YaloMessageServiceWebSocket.
// Manages a single WebSocket connection with exponential back-off reconnection.
// Decoded frames are emitted on [frames]; consumers call connect(scope) to start
// the loop and disconnect() to stop it. Thread-safety: connect/disconnect are
// expected to be called from the same coroutine scope; the connection loop itself
// runs on the provided scope's dispatcher.
internal class YaloMessageServiceWebSocket(
    // Full WebSocket URL without the auth token, e.g. "wss://api.yalochat.com/websocket/v1/connect/inapp"
    private val wsUrl: String,
    private val apiService: YaloChatApiService,
    private val httpClient: HttpClient,
) {
    private val json = Json { ignoreUnknownKeys = true }
    companion object {
        private const val INITIAL_BACKOFF_MS = 1_000L
        private const val MAX_BACKOFF_MS     = 30_000L
        private const val MAX_BACKOFF_STEPS  = 5
    }

    internal val _frames = MutableSharedFlow<YaloFetchMessagesResponse>(
        extraBufferCapacity = 64,
        onBufferOverflow = BufferOverflow.DROP_OLDEST,
    )
    val frames: SharedFlow<YaloFetchMessagesResponse> = _frames.asSharedFlow()

    internal var connectionJob: Job? = null
    private var reconnectAttempt = 0

    fun connect(scope: CoroutineScope) {
        if (connectionJob?.isActive == true) return
        connectionJob = scope.launch { connectLoop() }
    }

    fun disconnect() {
        connectionJob?.cancel()
        connectionJob = null
        reconnectAttempt = 0
    }

    private suspend fun connectLoop() {
        while (currentCoroutineContext().isActive) {
            try {
                println("[YaloWS] connecting — attempt $reconnectAttempt — url: $wsUrl")
                val tokenResult = apiService.ensureValidToken()
                if (tokenResult is Result.Error) {
                    println("[YaloWS] auth failed: ${tokenResult.error}")
                    scheduleReconnect()
                    continue
                }
                val (token, _) = (tokenResult as Result.Ok).result
                println("[YaloWS] token OK — upgrading to WebSocket")

                httpClient.webSocket("$wsUrl?token=${token.encodeURLParameter()}") {
                    reconnectAttempt = 0
                    println("[YaloWS] connected")
                    for (frame in incoming) {
                        if (frame !is Frame.Text) {
                            println("[YaloWS] non-text frame: ${frame::class.simpleName}")
                            continue
                        }
                        val text = frame.readText()
                        println("[YaloWS] frame received (${text.length} chars): ${text.take(200)}")
                        val parsed = parseFrame(text)
                        if (parsed != null) {
                            println("[YaloWS] frame parsed OK — emitting")
                            _frames.emit(parsed)
                        } else {
                            println("[YaloWS] frame parse FAILED")
                        }
                    }
                    println("[YaloWS] session ended cleanly")
                }
                scheduleReconnect()
            } catch (e: kotlinx.coroutines.CancellationException) {
                throw e
            } catch (e: Exception) {
                println("[YaloWS] connection error: $e")
                scheduleReconnect()
            }
        }
    }

    private fun parseFrame(text: String): YaloFetchMessagesResponse? = try {
        json.decodeFromString(text)
    } catch (e: Exception) {
        println("[YaloWS] JSON parse error: $e")
        null
    }

    private suspend fun scheduleReconnect() {
        val delayMs = (INITIAL_BACKOFF_MS shl reconnectAttempt).coerceAtMost(MAX_BACKOFF_MS)
        reconnectAttempt = (reconnectAttempt + 1).coerceAtMost(MAX_BACKOFF_STEPS)
        delay(delayMs)
    }
}

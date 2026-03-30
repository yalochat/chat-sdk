// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import com.yalo.chat.sdk.data.remote.model.toBody
import com.google.protobuf.timestamp
import yalo.external_channel.in_app.sdk.v1.sdkMessage
import yalo.external_channel.in_app.sdk.v1.textMessageRequest
import yalo.external_channel.in_app.sdk.v1.textMessage
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.flow
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant

// Port of flutter-sdk YaloMessageRepositoryRemote.
// Polling: 1s interval, 5s lookback window, LRU deduplication cache (capacity 500).
// Network errors in the polling flow are swallowed and the loop continues — mirrors
// flutter-sdk _startPolling() which logs the error and falls through to Future.delayed.
// Only text messages are mapped for now; voice/image payloads are skipped silently.
//
// KMP note: java.text.* and java.time.* have been replaced with kotlinx-datetime.
// java.util.UUID is still used for correlationId generation — a KMP-compatible alternative
// (e.g. kotlin.uuid.Uuid, available in Kotlin 2.0 experimental) can replace it when needed.
internal class YaloMessageRepositoryRemote(
    private val apiService: YaloChatApiService,
    // Exposed as internal so tests can override the interval without waiting.
    internal val pollingIntervalMs: Long = 1_000L,
    private val lookbackSecs: Long = 5L,
) : YaloMessageRepository {

    private val cache = SimpleCache<String, Boolean>(capacity = 500)

    // Hot SharedFlow for typing events — mirrors Flutter's _typingEventsStreamController.
    // UNLIMITED buffer prevents event loss when TypingStart and TypingStop are emitted in
    // rapid succession (e.g. a poll cycle that errors immediately after a send).
    private val _events = MutableSharedFlow<ChatEvent>(extraBufferCapacity = Channel.UNLIMITED)
    override fun events(): Flow<ChatEvent> = _events.asSharedFlow()

    // Sends a text message to the Yalo backend.
    // Non-text types (image, audio) are stored locally only; the backend rejects them.
    // TypingStart is emitted eagerly before the HTTP call — this gives instant feedback
    // that the message was submitted. If the send fails, the indicator clears on the next
    // poll error cycle (~1s). This matches Flutter's sendMessage() behavior exactly.
    override suspend fun sendMessage(message: ChatMessage): Result<Unit> {
        if (message.type != MessageType.Text) {
            return Result.Error(
                UnsupportedOperationException("Only text messages can be sent to the backend")
            )
        }
        _events.tryEmit(ChatEvent.TypingStart(TYPING_STATUS_TEXT))
        val now = Clock.System.now()
        val nowIso = now.toString()
        // Build the canonical proto SdkMessage using the Kotlin DSL generated from sdk_message.proto.
        // toBody() converts it to the @Serializable HTTP adapter accepted by Ktor.
        val protoTs = timestamp {
            seconds = now.epochSeconds
            nanos = now.nanosecondsOfSecond
        }
        val protoMsg = sdkMessage {
            correlationId = java.util.UUID.randomUUID().toString()
            timestamp = protoTs
            textMessageRequest = textMessageRequest {
                content = textMessage {
                    text = message.content
                    timestamp = protoTs
                }
                timestamp = protoTs
            }
        }
        return apiService.sendTextMessage(protoMsg.toBody(nowIso))
    }

    // Single-shot fetch — returns all messages newer than the given Unix millisecond timestamp.
    // The cache is NOT applied here so callers get the full list.
    override suspend fun fetchMessages(since: Long): Result<List<ChatMessage>> =
        when (val result = apiService.fetchMessages(since)) {
            is Result.Ok -> Result.Ok(result.result.mapNotNull { it.toChatMessage(deduplicate = false) })
            is Result.Error -> Result.Error(result.error)
        }

    // Continuous polling flow — each emission is the de-duplicated batch of new messages
    // from one poll cycle. Empty batches are suppressed so downstream only sees real data.
    // Network errors are swallowed and the loop continues on the next tick, mirroring
    // flutter-sdk YaloMessageRepositoryRemote._startPolling().
    override fun pollIncomingMessages(): Flow<List<ChatMessage>> = flow {
        while (true) {
            val since = Clock.System.now().toEpochMilliseconds() - lookbackSecs * 1_000L
            when (val result = apiService.fetchMessages(since)) {
                is Result.Ok -> {
                    val batch = result.result.mapNotNull { it.toChatMessage(deduplicate = true) }
                    if (batch.isNotEmpty()) {
                        // Messages arrived — agent has replied, dismiss the typing indicator.
                        // Mirrors Flutter: TypingStop emitted before adding messages to stream.
                        _events.tryEmit(ChatEvent.TypingStop)
                        emit(batch)
                    }
                }
                is Result.Error -> {
                    // Fetch failed — clear typing indicator so it doesn't get stuck.
                    // Mirrors Flutter: TypingStop emitted in the catch block.
                    _events.tryEmit(ChatEvent.TypingStop)
                }
            }
            delay(pollingIntervalMs)
        }
    }

    private fun YaloFetchMessagesResponse.toChatMessage(deduplicate: Boolean): ChatMessage? {
        if (deduplicate && cache.get(id) != null) return null
        // Cache before the payload check so non-text messages (voice, image) are not
        // re-evaluated on every poll cycle. Without this, a message with no textMessageRequest
        // would never be cached and would be redundantly processed until it leaves the lookback window.
        if (deduplicate) cache.set(id, true)
        // Only text messages are handled for now; skip other payload types silently.
        val textContent = message.payload.textMessageRequest?.content ?: return null
        val ts = parseIso8601(date)
        // Build a collision-resistant Long primary key:
        //   upper: second-precision epoch (handles server dates with no sub-second component)
        //   lower: 0–999 from wiId hash, so messages in the same second get distinct ids.
        // For ts == 0 (malformed date) the id is just the hash offset — sorts before real messages.
        val hashOffset = ((id.hashCode() % 1000) + 1000) % 1000
        val stableId = if (ts != 0L) (ts / 1000L) * 1000L + hashOffset else hashOffset.toLong()
        return ChatMessage(
            id = stableId,
            wiId = id,
            // Proto MessageRole JSON: "MESSAGE_ROLE_USER" / "MESSAGE_ROLE_AGENT".
            // Null/unspecified (default=0, omitted by proto3 JSON) falls back to AGENT.
            role = MessageRole.fromString(textContent.role ?: ""),
            type = MessageType.Text,
            status = MessageStatus.DELIVERED,
            content = textContent.text,
            timestamp = ts,
        )
    }
}

// ── Constants ─────────────────────────────────────────────────────────────────
// Status text shown in the app bar while the agent is composing a reply.
// Extracted as a constant for testability and to ease M12 localization.
private const val TYPING_STATUS_TEXT = "Writing message..."

// ── ISO 8601 date parsing ─────────────────────────────────────────────────────
// kotlinx-datetime's Instant.parse() handles all standard ISO 8601 variants
// (with/without millis, Z suffix, ±HH:MM offsets) and is fully KMP-compatible —
// no java.text.SimpleDateFormat, ThreadLocal, or TimeZone needed.

private fun parseIso8601(date: String): Long =
    try {
        Instant.parse(date).toEpochMilliseconds()
    } catch (_: Exception) {
        // Fallback to 0 so malformed dates sort before all real messages
        // rather than jumping to "now" and breaking chronological ordering.
        0L
    }

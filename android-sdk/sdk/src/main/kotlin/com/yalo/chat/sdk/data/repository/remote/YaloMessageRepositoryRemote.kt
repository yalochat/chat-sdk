// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import com.yalo.chat.sdk.data.remote.model.YaloTextMessage
import com.yalo.chat.sdk.data.remote.model.YaloTextMessageRequest
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone

// Port of flutter-sdk YaloMessageRepositoryRemote.
// Polling: 1s interval, 5s lookback window, LRU deduplication cache (capacity 500).
// Network errors in the polling flow are re-thrown so retryWhen in the ViewModel
// can restart it after a delay, mirroring the flutter-sdk polling restart behavior.
// Phase 2 M1 only maps text messages — other types are detected in a future milestone.
class YaloMessageRepositoryRemote(
    private val apiService: YaloChatApiService,
    // Exposed as internal so tests can override the interval without waiting.
    internal val pollingIntervalMs: Long = 1_000L,
    private val lookbackSecs: Long = 5L,
) : YaloMessageRepository {

    private val cache = SimpleCache<String, Boolean>(capacity = 500)

    // Sends a text message to the Yalo backend.
    // Non-text types are unsupported until Phase 2 M3/M4 add image/audio sending.
    override suspend fun sendMessage(message: ChatMessage): Result<Unit> {
        if (message.type != MessageType.Text) {
            return Result.Error(
                UnsupportedOperationException("Only text messages are supported in Phase 2 M1")
            )
        }
        val nowSecs = System.currentTimeMillis() / 1000
        val request = YaloTextMessageRequest(
            timestamp = nowSecs,
            content = YaloTextMessage(
                timestamp = message.timestamp / 1000,
                text = message.content,
                status = message.status.value,
                role = message.role.value,
            ),
        )
        return apiService.sendTextMessage(request)
    }

    // Single-shot fetch — returns all messages newer than the given Unix second timestamp.
    // The cache is NOT applied here so callers get the full list.
    override suspend fun fetchMessages(since: Long): Result<List<ChatMessage>> =
        when (val result = apiService.fetchMessages(since)) {
            is Result.Ok -> Result.Ok(result.result.mapNotNull { it.toChatMessage(deduplicate = false) })
            is Result.Error -> Result.Error(result.error)
        }

    // Continuous polling flow — emits each new inbound ChatMessage as it arrives.
    // Uses the LRU cache so the same message (identified by wiId) is never emitted twice.
    // Network errors are re-thrown so the caller's retryWhen can restart the flow after
    // a delay — this is what gives the "automatic restart on network recovery" behavior.
    // Mirrors flutter-sdk YaloMessageRepositoryRemote._startPolling().
    override fun pollIncomingMessages(): Flow<ChatMessage> = flow {
        while (true) {
            val since = System.currentTimeMillis() / 1000 - lookbackSecs
            when (val result = apiService.fetchMessages(since)) {
                is Result.Ok -> result.result
                    .mapNotNull { it.toChatMessage(deduplicate = true) }
                    .forEach { emit(it) }
                // Re-throw so retryWhen in the ViewModel can catch and restart the flow.
                is Result.Error -> throw result.error
            }
            delay(pollingIntervalMs)
        }
    }

    private fun YaloFetchMessagesResponse.toChatMessage(deduplicate: Boolean): ChatMessage? {
        if (deduplicate && cache.get(id) != null) return null
        if (deduplicate) cache.set(id, true)
        return ChatMessage(
            wiId = id,
            role = MessageRole.fromString(message.role),
            type = MessageType.Text, // Phase 2 M1: only text detected
            status = MessageStatus.DELIVERED,
            content = message.text,
            timestamp = parseIso8601(date),
        )
    }
}

// ── ISO 8601 date parsing ─────────────────────────────────────────────────────
// SimpleDateFormat is used instead of java.time.Instant to support API 21+
// without core library desugaring.
//
// The 'X' timezone specifier is only available on API 24+, so 'Z' is used
// instead (supported from API 1). ISO 8601 offsets use ±HH:MM but 'Z' expects
// ±HHMM, so normalizeIso8601Offset strips the colon before parsing.
//
// ThreadLocal caches one SimpleDateFormat per format per thread — avoids
// per-call allocation and is safe since SimpleDateFormat is not thread-safe.

private const val UTC = "UTC"

private data class Iso8601Format(val pattern: String, val normalizeOffset: Boolean)

private val ISO_FORMATS = listOf(
    Iso8601Format("yyyy-MM-dd'T'HH:mm:ss.SSSZ", normalizeOffset = true),
    Iso8601Format("yyyy-MM-dd'T'HH:mm:ssZ",      normalizeOffset = true),
    Iso8601Format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", normalizeOffset = false),
    Iso8601Format("yyyy-MM-dd'T'HH:mm:ss'Z'",     normalizeOffset = false),
)

// ThreadLocal.withInitial() requires API 26; anonymous subclass works from API 1.
private val threadLocalFormatters: ThreadLocal<List<SimpleDateFormat>> =
    object : ThreadLocal<List<SimpleDateFormat>>() {
        override fun initialValue() = ISO_FORMATS.map { fmt ->
            SimpleDateFormat(fmt.pattern, Locale.US).apply {
                timeZone = TimeZone.getTimeZone(UTC)
            }
        }
    }

// Converts ±HH:MM (or ±HH:MM:SS) offsets to ±HHMM (or ±HHMMSS) so they are
// compatible with the 'Z' SimpleDateFormat pattern on all supported API levels.
private fun normalizeIso8601Offset(input: String): String {
    val offsetPattern = Regex("([+-]\\d{2}):(\\d{2})(?::(\\d{2}))?\$")
    return input.replace(offsetPattern) { match ->
        val (hours, minutes) = match.destructured
        val seconds = match.groupValues[3]
        if (seconds.isNotEmpty()) "$hours$minutes$seconds" else "$hours$minutes"
    }
}

private fun parseIso8601(date: String): Long {
    val formatters = threadLocalFormatters.get()!!
    for ((index, fmt) in ISO_FORMATS.withIndex()) {
        try {
            val candidate = if (fmt.normalizeOffset) normalizeIso8601Offset(date) else date
            return formatters[index].parse(candidate)?.time ?: continue
        } catch (_: Exception) {
            continue
        }
    }
    return System.currentTimeMillis()
}

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
// All network errors are wrapped in Result.Error; nothing is thrown.
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
    // Network errors are swallowed so the flow stays alive; the caller should apply
    // retryWhen for automatic restart on persistent failure.
    // Mirrors flutter-sdk YaloMessageRepositoryRemote._startPolling().
    override fun pollIncomingMessages(): Flow<ChatMessage> = flow {
        while (true) {
            val since = System.currentTimeMillis() / 1000 - lookbackSecs
            when (val result = apiService.fetchMessages(since)) {
                is Result.Ok -> result.result
                    .mapNotNull { it.toChatMessage(deduplicate = true) }
                    .forEach { emit(it) }
                is Result.Error -> Unit // swallow; caller applies retryWhen
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

// SimpleDateFormat is used instead of java.time.Instant to support API 21+
// without requiring core library desugaring.
private val ISO_FORMATS = listOf(
    "yyyy-MM-dd'T'HH:mm:ss.SSSX",
    "yyyy-MM-dd'T'HH:mm:ssX",
    "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    "yyyy-MM-dd'T'HH:mm:ss'Z'",
)

private fun parseIso8601(date: String): Long {
    for (fmt in ISO_FORMATS) {
        try {
            return SimpleDateFormat(fmt, Locale.US)
                .apply { timeZone = TimeZone.getTimeZone("UTC") }
                .parse(date)
                ?.time ?: continue
        } catch (_: Exception) {
            continue
        }
    }
    return System.currentTimeMillis()
}

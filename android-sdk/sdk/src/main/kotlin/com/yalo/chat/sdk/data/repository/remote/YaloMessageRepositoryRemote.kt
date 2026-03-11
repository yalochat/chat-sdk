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
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant

// Port of flutter-sdk YaloMessageRepositoryRemote.
// Polling: 1s interval, 5s lookback window, LRU deduplication cache (capacity 500).
// Network errors in the polling flow are swallowed and the loop continues — mirrors
// flutter-sdk _startPolling() which logs the error and falls through to Future.delayed.
// Phase 2 M1 only maps text messages — other types are detected in a future milestone.
//
// KMP note: all platform-specific imports (java.text.*, java.util.*) have been replaced
// with kotlinx-datetime so this file is ready for a commonMain source set.
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
        val nowSecs = Clock.System.now().epochSeconds
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

    // Continuous polling flow — each emission is the de-duplicated batch of new messages
    // from one poll cycle. Empty batches are suppressed so downstream only sees real data.
    // Network errors are swallowed and the loop continues on the next tick, mirroring
    // flutter-sdk YaloMessageRepositoryRemote._startPolling().
    override fun pollIncomingMessages(): Flow<List<ChatMessage>> = flow {
        while (true) {
            val since = Clock.System.now().epochSeconds - lookbackSecs
            when (val result = apiService.fetchMessages(since)) {
                is Result.Ok -> {
                    val batch = result.result.mapNotNull { it.toChatMessage(deduplicate = true) }
                    if (batch.isNotEmpty()) emit(batch)
                }
                is Result.Error -> Unit // swallow, loop continues — mirrors Flutter SDK
            }
            delay(pollingIntervalMs)
        }
    }

    private fun YaloFetchMessagesResponse.toChatMessage(deduplicate: Boolean): ChatMessage? {
        if (deduplicate && cache.get(id) != null) return null
        if (deduplicate) cache.set(id, true)
        val ts = parseIso8601(date)
        return ChatMessage(
            // Use the epoch-millis timestamp as the stable Long primary key.
            // The server id (UUID string) is stored in wiId and drives deduplication via the cache.
            id = if (ts != 0L) ts else id.hashCode().toLong(),
            wiId = id,
            role = MessageRole.fromString(message.role),
            type = MessageType.Text, // Phase 2 M1: only text detected
            status = MessageStatus.DELIVERED,
            content = message.text,
            timestamp = ts,
        )
    }
}

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

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.domain.model.ChatCommand
import com.yalo.chat.sdk.domain.model.ChatCommandCallback
import com.yalo.chat.sdk.data.remote.model.SdkImageMessageBody
import com.yalo.chat.sdk.data.remote.model.SdkImageMessageRequestBody
import com.yalo.chat.sdk.data.remote.model.SdkMessageBody
import com.yalo.chat.sdk.data.remote.model.SdkTextMessageBody
import com.yalo.chat.sdk.data.remote.model.SdkTextMessageRequestBody
import com.yalo.chat.sdk.data.remote.model.SdkVoiceMessageBody
import com.yalo.chat.sdk.data.remote.model.SdkVoiceNoteMessageRequestBody
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import com.yalo.chat.sdk.ui.chat.UnitType
import kotlin.concurrent.Volatile
import kotlin.uuid.ExperimentalUuidApi
import kotlin.uuid.Uuid
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.flow
import kotlinx.datetime.Clock

// Polling: 1s interval, LRU deduplication cache (capacity 500).
// The `since` query param tracks the last seen message timestamp so each poll only
// fetches messages newer than the previous batch. On the first poll `since = null`
// and the server returns full history. If a batch contains only invalid/missing
// dates the watermark is set to `now` so subsequent polls don't repeat the
// full-history fetch indefinitely.
// Client-side deduplication via SimpleCache provides an additional safety net.
// Network errors in the polling flow are swallowed and the loop continues.
@OptIn(ExperimentalUuidApi::class)
internal class YaloMessageRepositoryRemote(
    private val apiService: YaloChatApiService,
    // Exposed as internal so tests can override the interval without waiting.
    internal val pollingIntervalMs: Long = 1_000L,
    // Absolute path to the directory where downloaded agent media is saved.
    // Mirrors Flutter's _directory. Platform-specific path provided by YaloChat.kt.
    private val tempDir: String? = null,
) : YaloMessageRepository {

    // Registered command callbacks — mirrors flutter-sdk YaloChatClient.commands.
    // If a callback is registered for a command, it fires instead of the API call.
    // @Volatile + immutable-map replacement: readers always see a consistent snapshot
    // and ConcurrentModificationException is impossible (no shared mutable collection).
    @Volatile
    private var commands: Map<ChatCommand, ChatCommandCallback> = emptyMap()

    // Non-atomic RMW: concurrent registrations on different threads could theoretically lose one
    // update, but registerCommand is always called from single-threaded app startup, so this is safe.
    override fun registerCommand(command: ChatCommand, callback: ChatCommandCallback) {
        commands = commands + (command to callback)
    }

    override val commandsSnapshot: Map<ChatCommand, ChatCommandCallback> get() = commands

    private val cache = SimpleCache<String, Boolean>(capacity = 500)

    // Highest message id assigned during the current polling session.
    // Ensures new agent messages always sort AFTER previously-seen messages,
    // even when the server's timestamp is later than the client's clock at the
    // time of the next user send (which happens when the server takes a few
    // seconds to generate a response — its timestamp then exceeds the user's
    // subsequent message tempId, causing the wrong visual order).
    // Reset to 0 on construction; advanced during polling from observed message ids.
    // No atomic needed: pollIncomingMessages() is a single sequential coroutine.
    private var pollHighWater: Long = 0L

    // Hot SharedFlow for typing events — mirrors Flutter's _typingEventsStreamController.
    // UNLIMITED buffer prevents event loss when TypingStart and TypingStop are emitted in
    // rapid succession (e.g. a poll cycle that errors immediately after a send).
    private val _events = MutableSharedFlow<ChatEvent>(extraBufferCapacity = Channel.UNLIMITED)
    override fun events(): Flow<ChatEvent> = _events.asSharedFlow()

    // Pre-warms the in-memory dedup cache with message IDs that are already in the local DB,
    // so the first poll after a cold restart does not re-download media for known messages.
    // Called by MessageSyncService before starting the polling loop.
    override fun warmDedupCache(wiIds: Collection<String>) {
        wiIds.forEach { cache.set(it, true) }
    }

    override suspend fun sendMessage(message: ChatMessage): Result<Unit> {
        val nowIso = Clock.System.now().toString()

        return when (message.type) {
            MessageType.Text -> {
                _events.tryEmit(ChatEvent.TypingStart(TYPING_STATUS_TEXT))
                val body = SdkMessageBody(
                    correlationId = Uuid.random().toString(),
                    timestamp = nowIso,
                    textMessageRequest = SdkTextMessageRequestBody(
                        content = SdkTextMessageBody(text = message.content, timestamp = nowIso),
                        timestamp = nowIso,
                    ),
                )
                apiService.sendMessage(body)
            }

            MessageType.Image -> {
                val filePath = message.fileName
                    ?: return Result.Error(IllegalArgumentException("image message missing fileName"))
                val mimeType = message.mediaType ?: "image/jpeg"
                _events.tryEmit(ChatEvent.TypingStart(TYPING_STATUS_TEXT))
                val bytes = try {
                    PlatformFiles.readBytes(filePath)
                } catch (e: Exception) {
                    return Result.Error(e)
                }
                val filename = filePath.substringAfterLast('/')
                when (val uploadResult = apiService.uploadMedia(bytes, filename, mimeType)) {
                    is Result.Error -> Result.Error(uploadResult.error)
                    is Result.Ok -> {
                        val body = SdkMessageBody(
                            correlationId = Uuid.random().toString(),
                            timestamp = nowIso,
                            imageMessageRequest = SdkImageMessageRequestBody(
                                content = SdkImageMessageBody(
                                    timestamp = nowIso,
                                    text = message.content.takeIf { it.isNotEmpty() },
                                    mediaUrl = uploadResult.result.id,
                                    mediaType = mimeType,
                                    byteCount = bytes.size.toLong(),
                                    fileName = filename,
                                ),
                                timestamp = nowIso,
                            ),
                        )
                        apiService.sendMessage(body)
                    }
                }
            }

            MessageType.Voice -> {
                val filePath = message.fileName
                    ?: return Result.Error(IllegalArgumentException("voice message missing fileName"))
                val mimeType = message.mediaType ?: "audio/mp4"
                _events.tryEmit(ChatEvent.TypingStart(TYPING_STATUS_TEXT))
                val bytes = try {
                    PlatformFiles.readBytes(filePath)
                } catch (e: Exception) {
                    return Result.Error(e)
                }
                val filename = filePath.substringAfterLast('/')
                when (val uploadResult = apiService.uploadMedia(bytes, filename, mimeType)) {
                    is Result.Error -> Result.Error(uploadResult.error)
                    is Result.Ok -> {
                        val body = SdkMessageBody(
                            correlationId = Uuid.random().toString(),
                            timestamp = nowIso,
                            voiceNoteMessageRequest = SdkVoiceNoteMessageRequestBody(
                                content = SdkVoiceMessageBody(
                                    timestamp = nowIso,
                                    mediaUrl = uploadResult.result.id,
                                    mediaType = mimeType,
                                    byteCount = bytes.size.toLong(),
                                    fileName = filename,
                                    amplitudesPreview = message.amplitudes.map { it.toFloat() },
                                    duration = message.duration?.toDouble(),
                                ),
                                timestamp = nowIso,
                            ),
                        )
                        apiService.sendMessage(body)
                    }
                }
            }

            else -> Result.Error(UnsupportedOperationException("Message type ${message.type} is not supported"))
        }
    }

    // Single-shot fetch — returns all messages for cold-start; deduplication disabled so callers
    // get the full list. `since` is intentionally omitted here so startup always loads the full history.
    override suspend fun fetchMessages(since: Long): Result<List<ChatMessage>> =
        when (val result = apiService.fetchMessages()) {
            is Result.Ok -> Result.Ok(result.result.mapIndexedNotNull { index, it ->
                it.toChatMessage(deduplicate = false, index = index, cache = cache, apiService = apiService, tempDir = tempDir)
            })
            is Result.Error -> Result.Error(result.error)
        }

    // Continuous polling flow — each emission is the de-duplicated batch of new messages
    // from one poll cycle. Empty batches are suppressed so downstream only sees real data.
    // Network errors are swallowed and the loop continues on the next tick, mirroring
    // flutter-sdk YaloMessageRepositoryRemote._startPolling().
    //
    // Two-phase processing per cycle:
    //   Phase 1 — non-media messages (text, buttons, CTA, etc.) are translated instantly
    //             and emitted immediately so the UI updates without waiting for downloads.
    //   Phase 2 — media messages (image, video, voice) are translated one by one; each is
    //             emitted as its CDN download completes.
    //
    // `lastMessageTimestamp` is a local watermark that resets on each flow collection
    // (i.e., every stop/start cycle), matching web-sdk's unsubscribeMessages() reset.
    // First poll omits `since` (full fetch, same as cold-start fetchMessages()) so no
    // messages are skipped if polling was stopped for longer than 5 s. Dedup cache handles
    // re-filtering of already-seen messages.
    override fun pollIncomingMessages(): Flow<List<ChatMessage>> = flow {
        var lastMessageTimestamp: Long? = null
        while (true) {
            when (val result = apiService.fetchMessages(since = lastMessageTimestamp)) {
                is Result.Ok -> {
                    val raw = result.result

                    // Update the since watermark to the max date seen in this batch.
                    for (item in raw) {
                        val ts = parseIso8601(item.date)
                        val current = lastMessageTimestamp
                        if (ts > 0L && (current == null || ts > current)) lastMessageTimestamp = ts
                    }
                    // Safety net: if every date in the batch was missing/invalid advance
                    // the watermark to now so subsequent polls don't re-fetch full history.
                    if (lastMessageTimestamp == null) {
                        lastMessageTimestamp = Clock.System.now().toEpochMilliseconds()
                    }

                    // Phase 1: non-media messages — translate without IO and emit right away.
                    val nonMediaBatch = raw.mapIndexedNotNull { index, item ->
                        if (item.requiresMediaDownload()) return@mapIndexedNotNull null
                        try { item.toChatMessage(deduplicate = true, index = index, cache = cache, apiService = apiService, tempDir = tempDir) }
                        catch (e: CancellationException) { throw e }
                        catch (e: Exception) { null }
                    }.let { ensureReceiptOrder(it) }

                    if (nonMediaBatch.isNotEmpty()) {
                        _events.tryEmit(ChatEvent.TypingStop)
                        emit(nonMediaBatch)
                    }

                    // Phase 2: media messages — download one by one and emit each when ready.
                    raw.forEachIndexed { index, item ->
                        if (!item.requiresMediaDownload()) return@forEachIndexed
                        val msg = try { item.toChatMessage(deduplicate = true, index = index, cache = cache, apiService = apiService, tempDir = tempDir) }
                        catch (e: CancellationException) { throw e }
                        catch (e: Exception) { null }
                        ?: return@forEachIndexed
                        val ordered = ensureReceiptOrder(listOf(msg))
                        if (ordered.isNotEmpty()) {
                            _events.tryEmit(ChatEvent.TypingStop)
                            emit(ordered)
                        }
                    }
                }
                is Result.Error -> {
                    // Fetch failed — clear typing indicator so it doesn't get stuck.
                    _events.tryEmit(ChatEvent.TypingStop)
                }
            }
            delay(pollingIntervalMs)
        }
    }

    // Assigns stable local ids to a polled batch so that messages are ordered
    // consistently relative to user-sent messages and previous poll batches.
    //
    // Problem: stableId is derived from the SERVER timestamp (second precision), but
    // user-message tempIds use the CLIENT clock in milliseconds. When the bot responds
    // in the same second the user sent a message, the bot's stableId (second*1000+index)
    // is less than the user's tempId (millisecond), so the bot response sorts before the
    // user message in ORDER BY id ASC — visually wrong.
    //
    // Fix: clamp every polled message id to max(rawId, receiptFloor) where receiptFloor
    // is the client clock at receipt time. Receipt always happens after the user sent the
    // message, so clamped ids are always > the user's tempId. fetchMessages() (startup cold
    // load) is NOT affected — it bypasses this function.
    private fun ensureReceiptOrder(messages: List<ChatMessage>): List<ChatMessage> {
        if (messages.isEmpty()) return messages
        val receiptFloor = Clock.System.now().toEpochMilliseconds()
        var cursor = maxOf(receiptFloor, pollHighWater + 1)
        return messages.map { msg ->
            val rawId = msg.id ?: return@map msg
            val id = if (rawId >= cursor) {
                cursor = maxOf(cursor, rawId + 1)
                rawId
            } else {
                val assigned = cursor
                cursor++
                assigned
            }
            if (id > pollHighWater) pollHighWater = id
            if (id == rawId) msg else msg.copy(id = id)
        }
    }

    // ── Cart operations ────────────────────────────────────────────────────────
    // Mirrors flutter-sdk YaloMessageRepositoryRemote.addToCart/removeFromCart/clearCart/addPromotion.
    // If a ChatCommand callback is registered, it fires instead of the API call (same pattern as Flutter).

    override suspend fun addToCart(sku: String, quantity: Double, unitType: UnitType?): Result<Unit> {
        val callback = commands[ChatCommand.ADD_TO_CART]
        if (callback != null) {
            callback(mapOf(KEY_SKU to sku, KEY_QUANTITY to quantity, KEY_UNIT_TYPE to unitType))
            return Result.Ok(Unit)
        }
        return apiService.addToCart(sku, quantity, unitType.toApiString())
    }

    override suspend fun removeFromCart(sku: String, quantity: Double?, unitType: UnitType?): Result<Unit> {
        val callback = commands[ChatCommand.REMOVE_FROM_CART]
        if (callback != null) {
            callback(mapOf(KEY_SKU to sku, KEY_QUANTITY to quantity, KEY_UNIT_TYPE to unitType))
            return Result.Ok(Unit)
        }
        return apiService.removeFromCart(sku, quantity, unitType.toApiString())
    }

    override suspend fun clearCart(): Result<Unit> {
        val callback = commands[ChatCommand.CLEAR_CART]
        if (callback != null) {
            callback(null)
            return Result.Ok(Unit)
        }
        return apiService.clearCart()
    }

    override suspend fun addPromotion(promotionId: String): Result<Unit> {
        val callback = commands[ChatCommand.ADD_PROMOTION]
        if (callback != null) {
            callback(mapOf(KEY_PROMOTION_ID to promotionId))
            return Result.Ok(Unit)
        }
        return apiService.addPromotion(promotionId)
    }
}

// ── Constants ─────────────────────────────────────────────────────────────────
private const val TYPING_STATUS_TEXT = "Writing message..."

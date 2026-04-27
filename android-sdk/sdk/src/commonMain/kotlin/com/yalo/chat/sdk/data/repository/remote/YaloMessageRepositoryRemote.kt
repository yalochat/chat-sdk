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
import com.yalo.chat.sdk.domain.model.CtaButton
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.model.Product
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
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
import kotlinx.datetime.Instant

// Polling: 1s interval, LRU deduplication cache (capacity 500).
// The `since` query param is intentionally omitted — backend fix pending.
// Client-side deduplication via SimpleCache handles repeats.
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
    private val commands: MutableMap<ChatCommand, ChatCommandCallback> = mutableMapOf()

    fun registerCommand(command: ChatCommand, callback: ChatCommandCallback) {
        commands[command] = callback
    }

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

    // Single-shot fetch — returns all messages; deduplication disabled so callers get the full list.
    // NOTE: `since` param is intentionally ignored — Flutter FIXME disables it too ("wait for backend fix").
    override suspend fun fetchMessages(since: Long): Result<List<ChatMessage>> =
        when (val result = apiService.fetchMessages()) {
            is Result.Ok -> Result.Ok(result.result.mapIndexedNotNull { index, it -> it.toChatMessage(deduplicate = false, index = index) })
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
    override fun pollIncomingMessages(): Flow<List<ChatMessage>> = flow {
        while (true) {
            when (val result = apiService.fetchMessages()) {
                is Result.Ok -> {
                    val raw = result.result

                    // Phase 1: non-media messages — translate without IO and emit right away.
                    val nonMediaBatch = raw.mapIndexedNotNull { index, item ->
                        if (item.requiresMediaDownload()) return@mapIndexedNotNull null
                        try { item.toChatMessage(deduplicate = true, index = index) }
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
                        val msg = try { item.toChatMessage(deduplicate = true, index = index) }
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

    // Translates a poll response item to a ChatMessage.
    // index is the position of this item in the server response array; used as the sub-second
    // tiebreaker in stableId so messages with identical timestamps preserve server order.
    private suspend fun YaloFetchMessagesResponse.toChatMessage(deduplicate: Boolean, index: Int = 0): ChatMessage? {
        if (deduplicate && cache.get(id) != null) return null

        val ts = parseIso8601(date)
        val indexOffset = index % 1000
        val stableId = if (ts != 0L) (ts / 1000L) * 1000L + indexOffset else indexOffset.toLong()

        // Text message
        message.textMessageRequest?.content?.let { textContent ->
            if (deduplicate) cache.set(id, true)
            return ChatMessage(
                id = stableId,
                wiId = id,
                role = MessageRole.fromString(textContent.role ?: ""),
                type = MessageType.Text,
                status = MessageStatus.DELIVERED,
                content = textContent.text,
                timestamp = ts,
            )
        }

        // Image message — download from CDN and save locally.
        // Cache is set only after a successful download so a transient CDN failure
        // does not permanently blacklist the message from future poll cycles.
        message.imageMessageRequest?.content?.let { imgContent ->
            return when (val downloadResult = apiService.downloadMedia(imgContent.mediaUrl)) {
                is Result.Error -> null // skip silently — will retry on next poll cycle
                is Result.Ok -> {
                    val bytes = downloadResult.result
                    val mimeType = imgContent.mediaType.takeIf { it.isNotEmpty() } ?: "image/jpeg"
                    val ext = mimeType.substringAfter('/').substringBefore(';').trim().let {
                        if (it == "jpeg") "jpg" else it
                    }
                    val localPath = PlatformFiles.writeToDir(
                        dirPath = tempDir,
                        filename = "${Uuid.random()}.$ext",
                        bytes = bytes,
                    ) ?: return null
                    if (deduplicate) cache.set(id, true)
                    ChatMessage(
                        id = stableId,
                        wiId = id,
                        role = MessageRole.fromString(imgContent.role ?: "MESSAGE_ROLE_AGENT"),
                        type = MessageType.Image,
                        status = MessageStatus.DELIVERED,
                        content = imgContent.text ?: "",
                        fileName = localPath,
                        mediaType = mimeType,
                        byteCount = bytes.size.toLong(),
                        timestamp = ts,
                    )
                }
            }
        }

        // Video message — download from CDN and save locally.
        // Mirrors Flutter's videoMessageRequest case in _translateMessageResponse().
        // Cache is set only after a successful download (same pattern as image).
        message.videoMessageRequest?.content?.let { videoContent ->
            return when (val downloadResult = apiService.downloadMedia(videoContent.mediaUrl)) {
                is Result.Error -> null // skip silently — will retry on next poll cycle
                is Result.Ok -> {
                    val bytes = downloadResult.result
                    val mimeType = videoContent.mediaType.takeIf { it.isNotEmpty() } ?: "video/mp4"
                    val ext = mimeType.substringAfter('/').substringBefore(';').trim().let {
                        if (it.contains("mp4") || it == "mp4") "mp4" else it
                    }
                    val localPath = PlatformFiles.writeToDir(
                        dirPath = tempDir,
                        filename = "${Uuid.random()}.$ext",
                        bytes = bytes,
                    ) ?: return null
                    if (deduplicate) cache.set(id, true)
                    ChatMessage(
                        id = stableId,
                        wiId = id,
                        role = MessageRole.fromString(videoContent.role ?: "MESSAGE_ROLE_AGENT"),
                        type = MessageType.Video,
                        status = MessageStatus.DELIVERED,
                        content = videoContent.text ?: "",
                        fileName = localPath,
                        mediaType = mimeType,
                        byteCount = bytes.size.toLong(),
                        // Flutter stores duration in seconds (Double) → convert to millis for ChatMessage.
                        duration = (videoContent.duration * 1000).toLong(),
                        timestamp = ts,
                    )
                }
            }
        }

        // Voice message — download from CDN and save locally.
        // Mirrors the image/video download pattern; cache is set only after a successful download.
        // amplitudesPreview (List<Float> from proto) is mapped to List<Double> for ChatMessage.
        // duration arrives in seconds (proto double) → stored as millis in ChatMessage.
        message.voiceNoteMessageRequest?.content?.let { voiceContent ->
            return when (val downloadResult = apiService.downloadMedia(voiceContent.mediaUrl)) {
                is Result.Error -> null // skip silently — will retry on next poll cycle
                is Result.Ok -> {
                    val bytes = downloadResult.result
                    val mimeType = voiceContent.mediaType.takeIf { it.isNotEmpty() } ?: "audio/mp4"
                    val ext = mimeType.substringAfter('/').substringBefore(';').trim().let {
                        when {
                            it.contains("mp4") -> "m4a"
                            it.contains("mpeg") || it.contains("mp3") -> "mp3"
                            else -> it
                        }
                    }
                    val localPath = PlatformFiles.writeToDir(
                        dirPath = tempDir,
                        filename = "${Uuid.random()}.$ext",
                        bytes = bytes,
                    ) ?: return null
                    if (deduplicate) cache.set(id, true)
                    ChatMessage(
                        id = stableId,
                        wiId = id,
                        role = MessageRole.fromString(voiceContent.role ?: "MESSAGE_ROLE_AGENT"),
                        type = MessageType.Voice,
                        status = MessageStatus.DELIVERED,
                        fileName = localPath,
                        amplitudes = voiceContent.amplitudesPreview.map { it.toDouble() },
                        duration = (voiceContent.duration * 1000).toLong(),
                        mediaType = mimeType,
                        byteCount = bytes.size.toLong(),
                        timestamp = ts,
                    )
                }
            }
        }

        // Buttons message — body text + a list of reply labels rendered as outlined buttons.
        // Tapping a button sends the label as a text message (same as quick reply chips).
        message.buttonsMessageRequest?.content?.let { buttonsContent ->
            if (deduplicate) cache.set(id, true)
            return ChatMessage(
                id = stableId,
                wiId = id,
                role = MessageRole.AGENT,
                type = MessageType.Buttons,
                status = MessageStatus.DELIVERED,
                content = buttonsContent.body,
                header = buttonsContent.header.takeIf { !it.isNullOrEmpty() },
                footer = buttonsContent.footer.takeIf { !it.isNullOrEmpty() },
                buttons = buttonsContent.buttons,
                timestamp = ts,
            )
        }

        // CTA message — body text + buttons that each open a URL in the browser.
        message.ctaMessageRequest?.content?.let { ctaContent ->
            if (deduplicate) cache.set(id, true)
            return ChatMessage(
                id = stableId,
                wiId = id,
                role = MessageRole.AGENT,
                type = MessageType.CTA,
                status = MessageStatus.DELIVERED,
                content = ctaContent.body,
                header = ctaContent.header.takeIf { !it.isNullOrEmpty() },
                footer = ctaContent.footer.takeIf { !it.isNullOrEmpty() },
                ctaButtons = ctaContent.buttons.map { CtaButton(text = it.text, url = it.url) },
                timestamp = ts,
            )
        }

        // Product message — vertical list or horizontal carousel, determined by orientation.
        // No media download needed: products carry embedded metadata (SKU, name, price, images URLs).
        message.productMessageRequest?.let { productMsg ->
            if (deduplicate) cache.set(id, true)
            val type = if (productMsg.orientation == ORIENTATION_HORIZONTAL)
                MessageType.ProductCarousel else MessageType.Product
            return ChatMessage(
                id = stableId,
                wiId = id,
                role = MessageRole.AGENT,
                type = type,
                status = MessageStatus.DELIVERED,
                timestamp = ts,
                products = productMsg.products.map { p ->
                    Product(
                        sku = p.sku,
                        name = p.name,
                        price = p.price,
                        imagesUrl = p.imagesUrl,
                        salePrice = p.salePrice,
                        subunits = p.subunits,
                        unitStep = p.unitStep,
                        unitName = p.unitName,
                        subunitName = p.subunitName,
                        subunitStep = p.subunitStep,
                        unitsAdded = p.unitsAdded,
                        subunitsAdded = p.subunitsAdded,
                    )
                },
            )
        }

        // Unknown payload type — cache so it is not re-evaluated on every poll cycle.
        if (deduplicate) cache.set(id, true)
        return null
    }

    // ── Cart operations ────────────────────────────────────────────────────────
    // Mirrors flutter-sdk YaloMessageRepositoryRemote.addToCart/removeFromCart/clearCart/addPromotion.
    // If a ChatCommand callback is registered, it fires instead of the API call (same pattern as Flutter).

    override suspend fun addToCart(sku: String, quantity: Double): Result<Unit> {
        val callback = commands[ChatCommand.ADD_TO_CART]
        if (callback != null) {
            callback(mapOf("sku" to sku, "quantity" to quantity))
            return Result.Ok(Unit)
        }
        return apiService.addToCart(sku, quantity)
    }

    override suspend fun removeFromCart(sku: String, quantity: Double?): Result<Unit> {
        val callback = commands[ChatCommand.REMOVE_FROM_CART]
        if (callback != null) {
            callback(mapOf("sku" to sku, "quantity" to quantity))
            return Result.Ok(Unit)
        }
        return apiService.removeFromCart(sku, quantity)
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
            callback(mapOf("promotionId" to promotionId))
            return Result.Ok(Unit)
        }
        return apiService.addPromotion(promotionId)
    }
}

// ── Constants ─────────────────────────────────────────────────────────────────
private const val TYPING_STATUS_TEXT = "Writing message..."
// Proto3 JSON enum value name for horizontal orientation (carousel layout).
// Any other value (including null/ORIENTATION_VERTICAL/unknown) maps to Product (list).
private const val ORIENTATION_HORIZONTAL = "ORIENTATION_HORIZONTAL"

// True for message types that require a CDN download before they can be translated.
// Used by pollIncomingMessages() to separate the fast (text/buttons) path from the
// slow (media download) path so non-media messages are emitted without delay.
private fun YaloFetchMessagesResponse.requiresMediaDownload(): Boolean =
    message.imageMessageRequest != null ||
    message.videoMessageRequest != null ||
    message.voiceNoteMessageRequest != null

// ── ISO 8601 date parsing ─────────────────────────────────────────────────────
private fun parseIso8601(date: String): Long =
    try {
        Instant.parse(date).toEpochMilliseconds()
    } catch (_: Exception) {
        0L
    }

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
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
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.flow
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant

// Port of flutter-sdk YaloMessageRepositoryRemote.
// Polling: 1s interval, LRU deduplication cache (capacity 500).
// The `since` query param is intentionally omitted — Flutter FIXME disables it too
// ("wait for backend fix"). Client-side deduplication via SimpleCache handles repeats.
// Network errors in the polling flow are swallowed and the loop continues — mirrors
// flutter-sdk _startPolling() which logs the error and falls through to Future.delayed.
@OptIn(ExperimentalUuidApi::class)
internal class YaloMessageRepositoryRemote(
    private val apiService: YaloChatApiService,
    // Exposed as internal so tests can override the interval without waiting.
    internal val pollingIntervalMs: Long = 1_000L,
    // Absolute path to the directory where downloaded agent media is saved.
    // Mirrors Flutter's _directory. Platform-specific path provided by YaloChat.kt.
    private val tempDir: String? = null,
) : YaloMessageRepository {

    private val cache = SimpleCache<String, Boolean>(capacity = 500)

    // Highest message id assigned during the current polling session.
    // Ensures new agent messages always sort AFTER previously-seen messages,
    // even when the server's timestamp is later than the client's clock at the
    // time of the next user send (which happens when the server takes a few
    // seconds to generate a response — its timestamp then exceeds the user's
    // subsequent message tempId, causing the wrong visual order).
    // Reset to 0 on construction; seeded to Clock.System.now() on first poll.
    // No atomic needed: pollIncomingMessages() is a single sequential coroutine.
    private var pollHighWater: Long = 0L

    // Hot SharedFlow for typing events — mirrors Flutter's _typingEventsStreamController.
    // UNLIMITED buffer prevents event loss when TypingStart and TypingStop are emitted in
    // rapid succession (e.g. a poll cycle that errors immediately after a send).
    private val _events = MutableSharedFlow<ChatEvent>(extraBufferCapacity = Channel.UNLIMITED)
    override fun events(): Flow<ChatEvent> = _events.asSharedFlow()

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
            is Result.Ok -> Result.Ok(result.result.mapNotNull { it.toChatMessage(deduplicate = false) })
            is Result.Error -> Result.Error(result.error)
        }

    // Continuous polling flow — each emission is the de-duplicated batch of new messages
    // from one poll cycle. Empty batches are suppressed so downstream only sees real data.
    // Network errors are swallowed and the loop continues on the next tick, mirroring
    // flutter-sdk YaloMessageRepositoryRemote._startPolling().
    override fun pollIncomingMessages(): Flow<List<ChatMessage>> = flow {
        while (true) {
            when (val result = apiService.fetchMessages()) {
                is Result.Ok -> {
                    val raw = result.result
                    val batch = raw.mapNotNull { it.toChatMessage(deduplicate = true) }
                        .let { ensureReceiptOrder(it) }
                    // Mirror Flutter: TypingStop fires only when at least one NEW message
                    // was successfully translated. toChatMessage(deduplicate=true) returns
                    // null for already-cached items, so batch contains only new arrivals.
                    // This prevents the indicator from dismissing on cached messages
                    // (old raw.isNotEmpty() bug) AND on untranslatable unknown types.
                    if (batch.isNotEmpty()) {
                        _events.tryEmit(ChatEvent.TypingStop)
                        emit(batch)
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

    // Guarantees that every message in a polled batch has an id strictly greater
    // than all previously-polled messages and the current client clock.
    //
    // Problem: stableId is derived from the SERVER timestamp, but user-message
    // tempIds are derived from the CLIENT clock. When the server takes a few
    // seconds to generate a response its timestamp can exceed the client's clock
    // at the moment the user sends the next message. The agent response then gets
    // a stableId > that user message's tempId and sorts AFTER it in ORDER BY id ASC,
    // producing wrong visual order ("hey" appears before the reply to "hello").
    //
    // Fix: clamp each id to max(rawId, receiptFloor + batchIndex) where receiptFloor
    // is the client clock at receipt time. This mirrors Flutter's prepend-to-front
    // behaviour (newest message always at bottom) without changing the DB schema.
    // fetchMessages() (startup cold load) is NOT affected — it bypasses this function.
    private fun ensureReceiptOrder(messages: List<ChatMessage>): List<ChatMessage> {
        if (messages.isEmpty()) return messages
        val receiptFloor = Clock.System.now().toEpochMilliseconds()
        var cursor = maxOf(receiptFloor, pollHighWater + 1)
        return messages.map { msg ->
            val rawId = msg.id ?: return@map msg
            val id = if (rawId < cursor) {
                val assigned = cursor
                cursor++
                assigned
            } else {
                cursor = rawId + 1
                rawId
            }
            if (id > pollHighWater) pollHighWater = id
            if (id == rawId) msg else msg.copy(id = id)
        }
    }

    // Translates a poll response item to a ChatMessage.
    // Handles text and image payloads; skips unknown types silently.
    // For image messages, downloads from CDN and saves to tempDir.
    private suspend fun YaloFetchMessagesResponse.toChatMessage(deduplicate: Boolean): ChatMessage? {
        if (deduplicate && cache.get(id) != null) return null

        val ts = parseIso8601(date)
        val hashOffset = ((id.hashCode() % 1000) + 1000) % 1000
        val stableId = if (ts != 0L) (ts / 1000L) * 1000L + hashOffset else hashOffset.toLong()

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

        // Buttons message — body text + a list of reply labels rendered as outlined buttons.
        // Tapping a button sends the label as a text message (same as quick reply chips).
        // Port of flutter-sdk buttonsMessageRequest case in _translateMessageResponse().
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
        // Port of flutter-sdk ctaMessageRequest case in _translateMessageResponse().
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
}

// ── Constants ─────────────────────────────────────────────────────────────────
private const val TYPING_STATUS_TEXT = "Writing message..."
// Proto3 JSON enum value name for horizontal orientation (carousel layout).
// Any other value (including null/ORIENTATION_VERTICAL/unknown) maps to Product (list).
private const val ORIENTATION_HORIZONTAL = "ORIENTATION_HORIZONTAL"

// ── ISO 8601 date parsing ─────────────────────────────────────────────────────
private fun parseIso8601(date: String): Long =
    try {
        Instant.parse(date).toEpochMilliseconds()
    } catch (_: Exception) {
        0L
    }

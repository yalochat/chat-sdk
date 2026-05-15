// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.model.BUTTON_TYPE_LINK
import com.yalo.chat.sdk.data.remote.model.BUTTON_TYPE_POSTBACK
import com.yalo.chat.sdk.data.remote.model.SdkButtonDto
import com.yalo.chat.sdk.data.remote.model.YaloFetchMessagesResponse
import com.yalo.chat.sdk.domain.model.ChatButton
import com.yalo.chat.sdk.domain.model.ChatButtonType
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.CtaButton
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.model.Product
import com.yalo.chat.sdk.ui.chat.UnitType
import kotlin.uuid.ExperimentalUuidApi
import kotlin.uuid.Uuid
import kotlinx.datetime.Instant

// Shared typing-indicator text emitted by sendMessage across all transports.
internal const val TYPING_STATUS_TEXT = "Writing message..."

// Proto3 JSON enum value for horizontal carousel orientation.
internal const val ORIENTATION_HORIZONTAL = "ORIENTATION_HORIZONTAL"

// Cart command payload keys shared across all transports.
internal const val KEY_SKU = "sku"
internal const val KEY_QUANTITY = "quantity"
internal const val KEY_UNIT_TYPE = "unitType"
internal const val KEY_PROMOTION_ID = "promotionId"

// Proto3 JSON enum names for unit_type.
internal fun UnitType?.toApiString(): String? = when (this) {
    UnitType.UNIT -> "UNIT_TYPE_UNIT"
    UnitType.SUBUNIT -> "UNIT_TYPE_SUBUNIT"
    null -> null
}

// True for message types that require a CDN download before they can be rendered.
internal fun YaloFetchMessagesResponse.requiresMediaDownload(): Boolean =
    message.imageMessageRequest != null ||
    message.videoMessageRequest != null ||
    message.voiceNoteMessageRequest != null

// Parses an ISO-8601 date string to epoch millis; returns 0 on failure.
internal fun parseIso8601(date: String): Long =
    try {
        Instant.parse(date).toEpochMilliseconds()
    } catch (_: Exception) {
        0L
    }

// Translates a poll/WebSocket response item into a ChatMessage.
// `cache` is the caller's dedup cache; when `deduplicate = true` the id is checked before
// translation and written on success. Extracted from YaloMessageRepositoryRemote so both
// the long-poll and WebSocket transports share identical mapping logic.
@OptIn(ExperimentalUuidApi::class)
internal suspend fun YaloFetchMessagesResponse.toChatMessage(
    deduplicate: Boolean,
    index: Int = 0,
    cache: SimpleCache<String, Boolean>,
    apiService: YaloChatApiService,
    tempDir: String?,
): ChatMessage? {
    if (deduplicate && cache.get(id) != null) return null

    val ts = parseIso8601(date)
    val indexOffset = index % 1000
    val stableId = if (ts != 0L) (ts / 1000L) * 1000L + indexOffset else indexOffset.toLong()

    // Text message
    message.textMessageRequest?.let { request ->
        request.content?.let { textContent ->
            if (deduplicate) cache.set(id, true)
            return ChatMessage(
                id = stableId,
                wiId = id,
                role = MessageRole.fromString(textContent.role ?: ""),
                type = MessageType.Text,
                status = MessageStatus.DELIVERED,
                content = textContent.text,
                buttons = request.buttons.map { it.toDomain() },
                header = request.header?.takeIf { it.isNotEmpty() },
                footer = request.footer?.takeIf { it.isNotEmpty() },
                timestamp = ts,
            )
        }
    }

    // Image message — download from CDN and save locally.
    message.imageMessageRequest?.let { imgReq ->
        val imgContent = imgReq.content ?: return@let
        return when (val downloadResult = apiService.downloadMedia(imgContent.mediaUrl)) {
            is Result.Error -> null
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
                val imgRequest = message.imageMessageRequest!!
                ChatMessage(
                    id = stableId, wiId = id,
                    role = MessageRole.fromString(imgContent.role ?: "MESSAGE_ROLE_AGENT"),
                    type = MessageType.Image,
                    status = MessageStatus.DELIVERED,
                    content = imgContent.text ?: "",
                    fileName = localPath,
                    mediaType = mimeType,
                    byteCount = bytes.size.toLong(),
                    buttons = imgRequest.buttons.map { it.toDomain() },
                    header = imgRequest.header?.takeIf { it.isNotEmpty() },
                    footer = imgRequest.footer?.takeIf { it.isNotEmpty() },
                    timestamp = ts,
                )
            }
        }
    }

    // Video message — download from CDN and save locally.
    message.videoMessageRequest?.let { videoReq ->
        val videoContent = videoReq.content ?: return@let
        return when (val downloadResult = apiService.downloadMedia(videoContent.mediaUrl)) {
            is Result.Error -> null
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
                val videoRequest = message.videoMessageRequest!!
                ChatMessage(
                    id = stableId, wiId = id,
                    role = MessageRole.fromString(videoContent.role ?: "MESSAGE_ROLE_AGENT"),
                    type = MessageType.Video,
                    status = MessageStatus.DELIVERED,
                    content = videoContent.text ?: "",
                    fileName = localPath,
                    mediaType = mimeType,
                    byteCount = bytes.size.toLong(),
                    duration = (videoContent.duration * 1000).toLong(),
                    buttons = videoRequest.buttons.map { it.toDomain() },
                    header = videoRequest.header?.takeIf { it.isNotEmpty() },
                    footer = videoRequest.footer?.takeIf { it.isNotEmpty() },
                    timestamp = ts,
                )
            }
        }
    }

    // Voice message — download from CDN and save locally.
    message.voiceNoteMessageRequest?.content?.let { voiceContent ->
        return when (val downloadResult = apiService.downloadMedia(voiceContent.mediaUrl)) {
            is Result.Error -> null
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
                val voiceRequest = message.voiceNoteMessageRequest!!
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
                    buttons = voiceRequest.buttons.map { it.toDomain() },
                    header = voiceRequest.header?.takeIf { it.isNotEmpty() },
                    footer = voiceRequest.footer?.takeIf { it.isNotEmpty() },
                    timestamp = ts,
                )
            }
        }
    }

    // Buttons message (legacy pre-proto-2.0 format — POSTBACK-implied buttons)
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
            buttons = buttonsContent.buttons.map { ChatButton(text = it, type = ChatButtonType.POSTBACK) },
            timestamp = ts,
        )
    }

    // CTA message (legacy pre-proto-2.0 format — LINK-implied buttons)
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
            buttons = ctaContent.buttons.map { ChatButton(text = it.text, type = ChatButtonType.LINK, url = it.url) },
            timestamp = ts,
        )
    }

    // Product message (list or carousel)
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

    // Unknown payload — cache to avoid re-evaluating on every cycle.
    if (deduplicate) cache.set(id, true)
    return null
}

// Maps proto3 buttonType string to the domain enum. Proto3 JSON serializes enum values as their
// name strings (e.g. "BUTTON_TYPE_POSTBACK"). BUTTON_TYPE_REPLY = 0 is the proto3 default and
// may be omitted from JSON, in which case the DTO default "BUTTON_TYPE_REPLY" is used.
private fun SdkButtonDto.toDomain(): ChatButton {
    val type = when (buttonType) {
        BUTTON_TYPE_POSTBACK -> ChatButtonType.POSTBACK
        BUTTON_TYPE_LINK -> ChatButtonType.LINK
        else -> ChatButtonType.REPLY
    }
    return ChatButton(text = text, type = type, url = url)
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.local

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.database.ChatMessageQueries
import com.yalo.chat.sdk.database.Chat_message
import com.yalo.chat.sdk.domain.model.ChatButton
import com.yalo.chat.sdk.domain.model.ChatButtonType
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.CtaButton
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.model.Product
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.builtins.serializer
import kotlinx.serialization.json.Json

// ChatMessageQueries is injected, ioDispatcher is injectable.
// When running on iOS, pass the appropriate CoroutineDispatcher from the platform.
internal class LocalChatMessageRepository(
    private val queries: ChatMessageQueries,
    // Default to Dispatchers.Default for KMP (iOS); Android passes Dispatchers.IO explicitly.
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.Default,
) : ChatMessageRepository {

    // GET first page (no cursor) or cursor page.
    override suspend fun getMessages(cursor: Long?, limit: Int): Result<List<ChatMessage>> =
        withContext(ioDispatcher) {
            try {
                val rows = if (cursor == null) {
                    queries.selectFirstPage(limit.toLong()).executeAsList()
                } else {
                    queries.selectPageBefore(cursor, limit.toLong()).executeAsList()
                }
                Result.Ok(rows.map { it.toDomain() })
            } catch (e: Exception) {
                Result.Error(e)
            }
        }

    // INSERT OR REPLACE a single message — used by MessagesViewModel for optimistic sends.
    override suspend fun insertMessage(message: ChatMessage): Result<Unit> {
        if (message.id == null) return Result.Error(
            IllegalArgumentException("Cannot insert a message with null id")
        )
        return withContext(ioDispatcher) {
            try {
                queries.insertOrReplace(message.toRow())
                Result.Ok(Unit)
            } catch (e: Exception) {
                Result.Error(e)
            }
        }
    }

    // Batch INSERT OR REPLACE in a single transaction — used by MessageSyncService.
    override suspend fun insertMessages(messages: List<ChatMessage>): Result<Unit> {
        val nullIdMessage = messages.firstOrNull { it.id == null }
        if (nullIdMessage != null) return Result.Error(
            IllegalArgumentException("Cannot insert a message with null id (content: ${nullIdMessage.content})")
        )
        return withContext(ioDispatcher) {
            try {
                queries.transaction {
                    messages.forEach { queries.insertOrReplace(it.toRow()) }
                }
                Result.Ok(Unit)
            } catch (e: Exception) {
                Result.Error(e)
            }
        }
    }

    // UPDATE an existing message (e.g., status change after server confirmation).
    override suspend fun updateMessage(message: ChatMessage): Result<Unit> =
        withContext(ioDispatcher) {
            if (message.id == null) return@withContext Result.Error(
                IllegalArgumentException("Cannot update a message with null id")
            )
            try {
                queries.insertOrReplace(message.toRow())
                Result.Ok(Unit)
            } catch (e: Exception) {
                Result.Error(e)
            }
        }

    // Live observation: emits updated list whenever chat_message table changes.
    // Uses SQLDelight coroutines-extensions asFlow + mapToList.
    override fun observeMessages(): Flow<List<ChatMessage>> =
        queries.observeConversation()
            .asFlow()
            .mapToList(ioDispatcher)
            .map { rows -> rows.map { it.toDomain() } }

    // ── Mappers ───────────────────────────────────────────────────────────────

    private fun Chat_message.toDomain(): ChatMessage = ChatMessage(
        id = id,
        wiId = wi_id,
        role = MessageRole.fromString(role),
        type = MessageType.fromString(type),
        status = MessageStatus.fromString(status),
        content = content,
        fileName = file_name,
        amplitudes = amplitudes?.let { decodeDoubleList(it) } ?: emptyList(),
        duration = duration,
        byteCount = byte_count,
        mediaType = media_type,
        products = products?.let { decodeProductList(it) } ?: emptyList(),
        header = header_, // SQLDelight escapes 'header' (SQL keyword) → header_
        footer = footer,
        buttons = decodeButtons(buttons, cta_buttons, quick_replies),
        timestamp = timestamp,
    )

    private fun ChatMessage.toRow(): InsertOrReplaceParams = InsertOrReplaceParams(
        id = id!!, // null check already done in insertMessage/insertMessages/updateMessage
        wi_id = wiId,
        role = role.value,
        content = content,
        type = type.value,
        status = status.value,
        file_name = fileName,
        amplitudes = amplitudes.takeIf { it.isNotEmpty() }?.let { encodeDoubleList(it) },
        duration = duration,
        byte_count = byteCount,
        media_type = mediaType,
        products = products.takeIf { it.isNotEmpty() }?.let { encodeProductList(it) },
        quick_replies = null,
        header_ = header,
        footer = footer,
        buttons = buttons.takeIf { it.isNotEmpty() }?.let { encodeButtonList(it) },
        cta_buttons = null,
        timestamp = timestamp,
    )

    // ── JSON helpers ──────────────────────────────────────────────────────────

    private val doubleListSerializer = ListSerializer(Double.serializer())
    private val productListSerializer = ListSerializer(Product.serializer())
    private val stringListSerializer = ListSerializer(String.serializer())
    private val ctaButtonListSerializer = ListSerializer(CtaButton.serializer())
    private val buttonListSerializer = ListSerializer(ChatButton.serializer())

    // Reads unified List<ChatButton> from the three DB columns, handling both old and new formats.
    // New records: `buttons` stores List<ChatButton> JSON; `cta_buttons` and `quick_replies` are null.
    // Old records: `buttons` stores List<String> JSON (POSTBACK-implied), `cta_buttons` stores
    // List<CtaButton> JSON (LINK-implied), `quick_replies` stores List<String> JSON (REPLY-implied).
    private fun decodeButtons(
        buttonsJson: String?,
        ctaJson: String?,
        qrJson: String?,
    ): List<ChatButton> {
        buttonsJson?.let { json ->
            // Try new unified format (List<ChatButton> with type field).
            val asButtons = try { Json.decodeFromString(buttonListSerializer, json) } catch (_: Exception) { null }
            if (!asButtons.isNullOrEmpty()) return asButtons
            // Fall back to old List<String> format (POSTBACK-implied, no URL).
            val asStrings = try { Json.decodeFromString(stringListSerializer, json) } catch (_: Exception) { null }
            if (asStrings != null) return asStrings.map { ChatButton(text = it, type = ChatButtonType.POSTBACK) }
        }
        val result = mutableListOf<ChatButton>()
        ctaJson?.let { json ->
            try {
                result += Json.decodeFromString(ctaButtonListSerializer, json)
                    .map { ChatButton(text = it.text, type = ChatButtonType.LINK, url = it.url) }
            } catch (_: Exception) { }
        }
        qrJson?.let { json ->
            try {
                result += Json.decodeFromString(stringListSerializer, json)
                    .map { ChatButton(text = it, type = ChatButtonType.REPLY) }
            } catch (_: Exception) { }
        }
        return result
    }

    private fun decodeDoubleList(json: String): List<Double> =
        try { Json.decodeFromString(doubleListSerializer, json) } catch (_: Exception) { emptyList() }

    private fun decodeProductList(json: String): List<Product> =
        try { Json.decodeFromString(productListSerializer, json) } catch (_: Exception) { emptyList() }

    private fun encodeDoubleList(list: List<Double>): String =
        Json.encodeToString(doubleListSerializer, list)

    private fun encodeProductList(list: List<Product>): String =
        Json.encodeToString(productListSerializer, list)

    private fun encodeButtonList(list: List<ChatButton>): String =
        Json.encodeToString(buttonListSerializer, list)
}

// Struct to carry insertOrReplace parameters (avoids a long positional call site).
private data class InsertOrReplaceParams(
    val id: Long,
    val wi_id: String?,
    val role: String,
    val content: String,
    val type: String,
    val status: String,
    val file_name: String?,
    val amplitudes: String?,
    val duration: Long?,
    val byte_count: Long?,
    val media_type: String?,
    val products: String?,
    val quick_replies: String?,
    val header_: String?,
    val footer: String?,
    val buttons: String?,
    val cta_buttons: String?,
    val timestamp: Long,
)

private fun ChatMessageQueries.insertOrReplace(p: InsertOrReplaceParams) =
    insertOrReplace(
        id = p.id,
        wi_id = p.wi_id,
        role = p.role,
        content = p.content,
        type = p.type,
        status = p.status,
        file_name = p.file_name,
        amplitudes = p.amplitudes,
        duration = p.duration,
        byte_count = p.byte_count,
        media_type = p.media_type,
        products = p.products,
        quick_replies = p.quick_replies,
        header_ = p.header_,
        footer = p.footer,
        buttons = p.buttons,
        cta_buttons = p.cta_buttons,
        timestamp = p.timestamp,
    )

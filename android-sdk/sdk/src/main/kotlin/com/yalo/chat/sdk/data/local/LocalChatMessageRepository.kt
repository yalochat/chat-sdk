// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.local

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.database.ChatMessageQueries
import com.yalo.chat.sdk.database.Chat_message
import com.yalo.chat.sdk.domain.model.ChatMessage
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

// Port of flutter-sdk ChatMessageRepositoryLocal (Drift) — same schema, same query semantics.
// Free of Android-specific imports: ChatMessageQueries is injected, ioDispatcher is injectable.
// KMP note: when splitting to KMP, pass the appropriate CoroutineDispatcher from the platform.
class LocalChatMessageRepository(
    private val queries: ChatMessageQueries,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : ChatMessageRepository {

    // GET first page (no cursor) or cursor page — mirrors Flutter getChatMessagePageDesc.
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
    override suspend fun insertMessage(message: ChatMessage): Result<Unit> =
        withContext(ioDispatcher) {
            try {
                queries.insertOrReplace(message.toRow())
                Result.Ok(Unit)
            } catch (e: Exception) {
                Result.Error(e)
            }
        }

    // Batch INSERT OR REPLACE in a single transaction — used by MessageSyncService.
    // Port of Flutter insertChatMessage called in a loop inside a Drift transaction.
    override suspend fun insertMessages(messages: List<ChatMessage>): Result<Unit> =
        withContext(ioDispatcher) {
            try {
                queries.transaction {
                    messages.forEach { queries.insertOrReplace(it.toRow()) }
                }
                Result.Ok(Unit)
            } catch (e: Exception) {
                Result.Error(e)
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
    // Port of Flutter stream returned by Drift's watchX.
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
        products = products?.let { decodeProductList(it) } ?: emptyList(),
        quickReplies = quick_replies?.let { decodeStringList(it) } ?: emptyList(),
        timestamp = timestamp,
    )

    private fun ChatMessage.toRow(): InsertOrReplaceParams = InsertOrReplaceParams(
        id = id ?: error("ChatMessage.id must not be null when persisting"),
        wi_id = wiId,
        role = role.value,
        content = content,
        type = type.value,
        status = status.value,
        file_name = fileName,
        amplitudes = amplitudes.takeIf { it.isNotEmpty() }?.let { encodeDoubleList(it) },
        duration = duration,
        products = products.takeIf { it.isNotEmpty() }?.let { encodeProductList(it) },
        quick_replies = quickReplies.takeIf { it.isNotEmpty() }?.let { encodeStringList(it) },
        timestamp = timestamp,
    )

    // ── JSON helpers ──────────────────────────────────────────────────────────

    private val doubleListSerializer = ListSerializer(Double.serializer())
    private val productListSerializer = ListSerializer(Product.serializer())
    private val stringListSerializer = ListSerializer(String.serializer())

    private fun decodeDoubleList(json: String): List<Double> =
        try { Json.decodeFromString(doubleListSerializer, json) } catch (_: Exception) { emptyList() }

    private fun decodeProductList(json: String): List<Product> =
        try { Json.decodeFromString(productListSerializer, json) } catch (_: Exception) { emptyList() }

    private fun decodeStringList(json: String): List<String> =
        try { Json.decodeFromString(stringListSerializer, json) } catch (_: Exception) { emptyList() }

    private fun encodeDoubleList(list: List<Double>): String =
        Json.encodeToString(doubleListSerializer, list)

    private fun encodeProductList(list: List<Product>): String =
        Json.encodeToString(productListSerializer, list)

    private fun encodeStringList(list: List<String>): String =
        Json.encodeToString(stringListSerializer, list)
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
    val products: String?,
    val quick_replies: String?,
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
        products = p.products,
        quick_replies = p.quick_replies,
        timestamp = p.timestamp,
    )

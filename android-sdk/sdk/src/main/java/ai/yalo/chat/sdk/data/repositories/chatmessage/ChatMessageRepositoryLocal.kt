// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.data.services.chatmessage.ChatMessageDatabaseService
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageStatus
import ai.yalo.chat.sdk.domain.models.MessageType
import android.content.ContentValues
import android.database.Cursor
import android.database.SQLException
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Keeps a conversation's messages in the shared [ChatMessageDatabaseService].
 *
 * Only [SQLException] is caught. Anything else, a cancelled coroutine most of
 * all, is left to travel up.
 */
internal class ChatMessageRepositoryLocal(
    private val database: ChatMessageDatabaseService,
    private val sessionId: String,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : ChatMessageRepository {

    override suspend fun insert(message: ChatMessage): Result<ChatMessage> = withContext(dispatcher) {
        try {
            Result.success(store(message))
        } catch (error: SQLException) {
            Result.failure(error)
        }
    }

    override suspend fun messages(limit: Int): Result<List<ChatMessage>> = withContext(dispatcher) {
        try {
            Result.success(read(limit))
        } catch (error: SQLException) {
            Result.failure(error)
        }
    }

    override suspend fun clearSession(): Result<Unit> = withContext(dispatcher) {
        try {
            database.writableDatabase.delete(
                ChatMessageDatabaseService.MESSAGE_TABLE,
                "${ChatMessageDatabaseService.COLUMN_SESSION_ID} = ?",
                arrayOf(sessionId),
            )
            Result.success(Unit)
        } catch (error: SQLException) {
            Result.failure(error)
        }
    }

    private fun store(message: ChatMessage): ChatMessage {
        val alreadyStored = message.wiId?.let { wiId -> findByWiId(wiId) }
        if (alreadyStored != null) {
            return alreadyStored
        }
        val values = ContentValues().apply {
            put(ChatMessageDatabaseService.COLUMN_SESSION_ID, sessionId)
            put(ChatMessageDatabaseService.COLUMN_WI_ID, message.wiId)
            put(ChatMessageDatabaseService.COLUMN_ROLE, message.role.wireName)
            put(ChatMessageDatabaseService.COLUMN_CONTENT, message.content)
            put(ChatMessageDatabaseService.COLUMN_TYPE, message.type.wireName)
            put(ChatMessageDatabaseService.COLUMN_STATUS, message.status.wireName)
            put(ChatMessageDatabaseService.COLUMN_TIMESTAMP, message.timestamp)
            put(ChatMessageDatabaseService.COLUMN_HEADER, message.header)
            put(ChatMessageDatabaseService.COLUMN_FOOTER, message.footer)
        }
        val id = database.writableDatabase.insertOrThrow(ChatMessageDatabaseService.MESSAGE_TABLE, null, values)
        return message.copy(id = id)
    }

    private fun read(limit: Int): List<ChatMessage> =
        database.readableDatabase.query(
            ChatMessageDatabaseService.MESSAGE_TABLE,
            null,
            "${ChatMessageDatabaseService.COLUMN_SESSION_ID} = ?",
            arrayOf(sessionId),
            null,
            null,
            "${ChatMessageDatabaseService.COLUMN_TIMESTAMP} DESC, ${ChatMessageDatabaseService.COLUMN_ID} DESC",
            limit.toString(),
        ).use { cursor ->
            buildList {
                while (cursor.moveToNext()) {
                    add(cursor.toChatMessage())
                }
            }
        }

    private fun findByWiId(wiId: String): ChatMessage? =
        database.readableDatabase.query(
            ChatMessageDatabaseService.MESSAGE_TABLE,
            null,
            "${ChatMessageDatabaseService.COLUMN_SESSION_ID} = ? AND ${ChatMessageDatabaseService.COLUMN_WI_ID} = ?",
            arrayOf(sessionId, wiId),
            null,
            null,
            null,
            "1",
        ).use { cursor ->
            if (cursor.moveToFirst()) {
                cursor.toChatMessage()
            } else {
                null
            }
        }

    private fun Cursor.toChatMessage(): ChatMessage = ChatMessage(
        role = MessageRole.of(text(ChatMessageDatabaseService.COLUMN_ROLE)),
        type = MessageType.of(text(ChatMessageDatabaseService.COLUMN_TYPE)),
        timestamp = getLong(getColumnIndexOrThrow(ChatMessageDatabaseService.COLUMN_TIMESTAMP)),
        id = getLong(getColumnIndexOrThrow(ChatMessageDatabaseService.COLUMN_ID)),
        wiId = optionalText(ChatMessageDatabaseService.COLUMN_WI_ID),
        content = text(ChatMessageDatabaseService.COLUMN_CONTENT),
        status = MessageStatus.of(text(ChatMessageDatabaseService.COLUMN_STATUS)),
        header = optionalText(ChatMessageDatabaseService.COLUMN_HEADER),
        footer = optionalText(ChatMessageDatabaseService.COLUMN_FOOTER),
    )

    private fun Cursor.text(column: String): String = getString(getColumnIndexOrThrow(column))

    private fun Cursor.optionalText(column: String): String? {
        val index = getColumnIndexOrThrow(column)
        return if (isNull(index)) {
            null
        } else {
            getString(index)
        }
    }
}

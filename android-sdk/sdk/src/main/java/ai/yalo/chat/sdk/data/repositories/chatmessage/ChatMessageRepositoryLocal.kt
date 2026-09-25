// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.data.datasources.chatmessage.ChatMessageDatabaseDataSource
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
 * Keeps a conversation's messages in the shared [ChatMessageDatabaseDataSource].
 *
 * Only [SQLException] is caught. Anything else, a cancelled coroutine most of
 * all, is left to travel up.
 */
internal class ChatMessageRepositoryLocal(
    private val database: ChatMessageDatabaseDataSource,
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
                ChatMessageDatabaseDataSource.MESSAGE_TABLE,
                "${ChatMessageDatabaseDataSource.COLUMN_SESSION_ID} = ?",
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
            put(ChatMessageDatabaseDataSource.COLUMN_SESSION_ID, sessionId)
            put(ChatMessageDatabaseDataSource.COLUMN_WI_ID, message.wiId)
            put(ChatMessageDatabaseDataSource.COLUMN_ROLE, message.role.wireName)
            put(ChatMessageDatabaseDataSource.COLUMN_CONTENT, message.content)
            put(ChatMessageDatabaseDataSource.COLUMN_TYPE, message.type.wireName)
            put(ChatMessageDatabaseDataSource.COLUMN_STATUS, message.status.wireName)
            put(ChatMessageDatabaseDataSource.COLUMN_TIMESTAMP, message.timestamp)
            put(ChatMessageDatabaseDataSource.COLUMN_HEADER, message.header)
            put(ChatMessageDatabaseDataSource.COLUMN_FOOTER, message.footer)
            put(ChatMessageDatabaseDataSource.COLUMN_BUTTONS, MessageButtonsColumn.encode(message.buttons))
            put(ChatMessageDatabaseDataSource.COLUMN_VOICE, VoiceNoteColumn.encode(message.voice))
        }
        val id = database.writableDatabase.insertOrThrow(ChatMessageDatabaseDataSource.MESSAGE_TABLE, null, values)
        return message.copy(id = id)
    }

    private fun read(limit: Int): List<ChatMessage> =
        database.readableDatabase.query(
            ChatMessageDatabaseDataSource.MESSAGE_TABLE,
            null,
            "${ChatMessageDatabaseDataSource.COLUMN_SESSION_ID} = ?",
            arrayOf(sessionId),
            null,
            null,
            "${ChatMessageDatabaseDataSource.COLUMN_TIMESTAMP} DESC, ${ChatMessageDatabaseDataSource.COLUMN_ID} DESC",
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
            ChatMessageDatabaseDataSource.MESSAGE_TABLE,
            null,
            "${ChatMessageDatabaseDataSource.COLUMN_SESSION_ID} = ? AND ${ChatMessageDatabaseDataSource.COLUMN_WI_ID} = ?",
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
        role = MessageRole.of(text(ChatMessageDatabaseDataSource.COLUMN_ROLE)),
        type = MessageType.of(text(ChatMessageDatabaseDataSource.COLUMN_TYPE)),
        timestamp = getLong(getColumnIndexOrThrow(ChatMessageDatabaseDataSource.COLUMN_TIMESTAMP)),
        id = getLong(getColumnIndexOrThrow(ChatMessageDatabaseDataSource.COLUMN_ID)),
        wiId = optionalText(ChatMessageDatabaseDataSource.COLUMN_WI_ID),
        content = text(ChatMessageDatabaseDataSource.COLUMN_CONTENT),
        status = MessageStatus.of(text(ChatMessageDatabaseDataSource.COLUMN_STATUS)),
        header = optionalText(ChatMessageDatabaseDataSource.COLUMN_HEADER),
        footer = optionalText(ChatMessageDatabaseDataSource.COLUMN_FOOTER),
        buttons = MessageButtonsColumn.decode(optionalText(ChatMessageDatabaseDataSource.COLUMN_BUTTONS)),
        voice = VoiceNoteColumn.decode(optionalText(ChatMessageDatabaseDataSource.COLUMN_VOICE)),
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

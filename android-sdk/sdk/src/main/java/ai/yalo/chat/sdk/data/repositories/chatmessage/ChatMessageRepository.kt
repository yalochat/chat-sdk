// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.ChatMessage

/**
 * The messages of one conversation, bound to a single session when it is built.
 *
 * Storage failing is something the chat has to show rather than crash on, so
 * every call reports it as a failed [Result] instead of throwing.
 */
internal interface ChatMessageRepository {

    /**
     * Stores [message] and returns it with the row id it was given. Handing in
     * one that already carries a backend id again returns what is stored, so a
     * replayed message does not show up twice.
     */
    suspend fun insert(message: ChatMessage): Result<ChatMessage>

    /** Most recent first. */
    suspend fun messages(limit: Int = DEFAULT_PAGE_SIZE): Result<List<ChatMessage>>

    suspend fun clearSession(): Result<Unit>

    companion object {
        const val DEFAULT_PAGE_SIZE: Int = 50
    }
}

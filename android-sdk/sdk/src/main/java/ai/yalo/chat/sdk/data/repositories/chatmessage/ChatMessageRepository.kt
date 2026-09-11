// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.ChatMessage

/**
 * The messages of one conversation.
 *
 * Every implementation is bound to a single session when it is built, so no
 * caller can reach another conversation's messages by mistake.
 *
 * Storage failing is something the chat has to show rather than crash on,
 * so every call reports it as a failed [Result] instead of throwing.
 */
internal interface ChatMessageRepository {

    /**
     * Stores [message] and returns it with the row id it was given.
     *
     * A message that already carries a backend id is stored once. Handing in
     * the same one again returns what is already stored instead of repeating
     * it, so a resent or replayed message does not show up twice.
     */
    suspend fun insert(message: ChatMessage): Result<ChatMessage>

    /** The newest [limit] messages, most recent first. */
    suspend fun messages(limit: Int = DEFAULT_PAGE_SIZE): Result<List<ChatMessage>>

    /** Forgets every message of this conversation. */
    suspend fun clearSession(): Result<Unit>

    companion object {
        const val DEFAULT_PAGE_SIZE: Int = 50
    }
}

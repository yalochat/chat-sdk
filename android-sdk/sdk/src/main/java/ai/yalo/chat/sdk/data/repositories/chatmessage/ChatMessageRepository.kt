// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.FeedbackRating

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

    /**
     * Last stored first. Arrival rather than timestamp, like the web SDK,
     * since the server rounds its times down to the second and a reply could
     * otherwise land before the message it answers.
     */
    suspend fun messages(limit: Int = DEFAULT_PAGE_SIZE): Result<List<ChatMessage>>

    /** Stores what the person rated the message with row [id], or clears it when [feedback] is null. */
    suspend fun updateFeedback(id: Long, feedback: FeedbackRating?): Result<Unit>

    suspend fun clearSession(): Result<Unit>

    /**
     * Forgets the messages of [sessionIds], which do not have to include the
     * one this repository is bound to. Sessions with nothing stored are no
     * error, so a caller can pass ids another path may already have taken.
     */
    suspend fun deleteSessions(sessionIds: List<String>): Result<Unit>

    companion object {
        const val DEFAULT_PAGE_SIZE: Int = 50
    }
}

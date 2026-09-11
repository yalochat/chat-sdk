// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.ChatMessage

/**
 * Stands in for storage so a test can say what it does without a database.
 *
 * Set [failure] to make every call come back failed, which is how a test asks
 * what the screen does when storage is broken.
 */
internal class FakeChatMessageRepository(
    var failure: Throwable? = null,
) : ChatMessageRepository {

    private val stored = mutableListOf<ChatMessage>()

    override suspend fun insert(message: ChatMessage): Result<ChatMessage> {
        failure?.let { error -> return Result.failure(error) }
        val alreadyStored = message.wiId?.let { wiId -> stored.firstOrNull { it.wiId == wiId } }
        if (alreadyStored != null) {
            return Result.success(alreadyStored)
        }
        val withId = message.copy(id = stored.size + 1L)
        stored.add(withId)
        return Result.success(withId)
    }

    override suspend fun messages(limit: Int): Result<List<ChatMessage>> {
        failure?.let { error -> return Result.failure(error) }
        return Result.success(stored.asReversed().take(limit))
    }

    override suspend fun clearSession(): Result<Unit> {
        failure?.let { error -> return Result.failure(error) }
        stored.clear()
        return Result.success(Unit)
    }
}

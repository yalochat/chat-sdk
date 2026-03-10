// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

// Phase 1 stub — in-memory list with StateFlow for reactive observation.
// Replaced in Phase 2 by ChatMessageRepositoryLocal (SQLDelight, FDE-55).
class FakeChatMessageRepository : ChatMessageRepository {

    private val messages = mutableListOf<ChatMessage>()
    private val _flow = MutableStateFlow<List<ChatMessage>>(emptyList())

    override suspend fun getMessages(cursor: Long?, limit: Int): Result<List<ChatMessage>> {
        val page = if (cursor == null) {
            messages.takeLast(limit)
        } else {
            messages.filter { it.id != null && it.id < cursor }.takeLast(limit)
        }
        return Result.Ok(page)
    }

    override suspend fun insertMessage(message: ChatMessage): Result<Unit> {
        messages.add(message)
        _flow.value = messages.toList()
        return Result.Ok(Unit)
    }

    override suspend fun updateMessage(message: ChatMessage): Result<Unit> {
        if (message.id == null) return Result.Error(IllegalArgumentException("Cannot update a message with null id"))
        val index = messages.indexOfFirst { it.id == message.id }
        return if (index >= 0) {
            messages[index] = message
            _flow.value = messages.toList()
            Result.Ok(Unit)
        } else {
            Result.Error(NoSuchElementException("Message with id ${message.id} not found"))
        }
    }

    override fun observeMessages(): Flow<List<ChatMessage>> = _flow.asStateFlow()
}

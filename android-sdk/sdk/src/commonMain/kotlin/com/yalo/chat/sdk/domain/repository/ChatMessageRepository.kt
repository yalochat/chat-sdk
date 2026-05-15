// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatMessage
import kotlinx.coroutines.flow.Flow

interface ChatMessageRepository {
    suspend fun getMessages(cursor: Long?, limit: Int): Result<List<ChatMessage>>
    suspend fun insertMessage(message: ChatMessage): Result<Unit>
    // Batch upsert in a single DB transaction — used by MessageSyncService on each poll cycle.
    suspend fun insertMessages(messages: List<ChatMessage>): Result<Unit>
    suspend fun updateMessage(message: ChatMessage): Result<Unit>
    fun observeMessages(): Flow<List<ChatMessage>>
}

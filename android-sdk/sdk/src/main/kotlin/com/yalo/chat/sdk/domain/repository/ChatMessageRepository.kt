// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatMessage
import kotlinx.coroutines.flow.Flow

// Port of flutter-sdk/lib/src/data/repositories/chat_message_repository.dart
// Phase 1: implemented by FakeChatMessageRepository (in-memory MutableList).
// Phase 2: implemented by LocalChatMessageRepository (SQLDelight).
interface ChatMessageRepository {
    suspend fun getMessages(cursor: Long?, limit: Int): Result<List<ChatMessage>>
    suspend fun insertMessage(message: ChatMessage): Result<Unit>
    // Batch upsert in a single DB transaction — used by MessageSyncService on each poll cycle.
    suspend fun insertMessages(messages: List<ChatMessage>): Result<Unit>
    suspend fun updateMessage(message: ChatMessage): Result<Unit>
    fun observeMessages(): Flow<List<ChatMessage>>
}

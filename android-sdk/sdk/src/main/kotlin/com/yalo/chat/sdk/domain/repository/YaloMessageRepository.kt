// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatMessage
import kotlinx.coroutines.flow.Flow

// Port of flutter-sdk/lib/src/data/repositories/yalo_message_repository.dart
// Phase 1: implemented by FakeYaloMessageRepository (in-memory hardcoded messages).
// Phase 2: implemented by YaloMessageRepositoryRemote (Ktor HTTP + polling).
interface YaloMessageRepository {
    suspend fun sendMessage(message: ChatMessage): Result<Unit>
    suspend fun fetchMessages(since: Long): Result<List<ChatMessage>>

    // Phase 2: continuous polling flow — emits new inbound messages from the server.
    // FakeYaloMessageRepository returns emptyFlow() (no-op for Phase 1 tests).
    // YaloMessageRepositoryRemote uses a 1s polling loop with a 5s lookback window.
    fun pollIncomingMessages(): Flow<ChatMessage>
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import kotlinx.coroutines.flow.Flow

// Port of flutter-sdk/lib/src/data/repositories/yalo_message_repository.dart
// Phase 1: implemented by FakeYaloMessageRepository (in-memory hardcoded messages).
// Phase 2: implemented by YaloMessageRepositoryRemote (Ktor HTTP + polling).
interface YaloMessageRepository {
    suspend fun sendMessage(message: ChatMessage): Result<Unit>
    suspend fun fetchMessages(since: Long): Result<List<ChatMessage>>

    // Phase 2: continuous polling flow — each emission is the batch of new messages
    // from one poll cycle. Empty batches are suppressed; only non-empty lists are emitted.
    // FakeYaloMessageRepository returns emptyFlow() (no-op for Phase 1 tests).
    // YaloMessageRepositoryRemote polls on a 1s interval with a 5s lookback window.
    fun pollIncomingMessages(): Flow<List<ChatMessage>>

    // Typing event stream — mirrors Flutter's _typingEventsStreamController.
    // TypingStart is emitted by sendMessage(); TypingStop is emitted when the poll receives
    // messages or encounters an error. FakeYaloMessageRepository returns emptyFlow().
    fun events(): Flow<ChatEvent>
}

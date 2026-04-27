// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow

// Port of flutter-sdk/lib/src/data/repositories/yalo_message_repository.dart
// Phase 1: implemented by FakeYaloMessageRepository (in-memory hardcoded messages).
// Phase 2: implemented by YaloMessageRepositoryRemote (Ktor HTTP + polling).
interface YaloMessageRepository {
    suspend fun sendMessage(message: ChatMessage): Result<Unit>
    // NOTE: `since` is currently ignored by all implementations — the Flutter SDK has a FIXME
    // disabling the backend `since` filter ("wait for backend fix"), so Android matches that
    // behaviour. The parameter is kept to avoid a breaking interface change.
    suspend fun fetchMessages(since: Long): Result<List<ChatMessage>>

    // Phase 2: continuous polling flow — each emission is the batch of new messages
    // from one poll cycle. Empty batches are suppressed; only non-empty lists are emitted.
    // FakeYaloMessageRepository returns emptyFlow() (no-op for Phase 1 tests).
    // YaloMessageRepositoryRemote polls on a 1s interval; client-side deduplication via SimpleCache.
    fun pollIncomingMessages(): Flow<List<ChatMessage>>

    // Typing event stream — mirrors Flutter's _typingEventsStreamController.
    // TypingStart is emitted by sendMessage(); TypingStop is emitted when the poll receives
    // messages or encounters an error. FakeYaloMessageRepository returns emptyFlow().
    fun events(): Flow<ChatEvent> = emptyFlow()

    // Pre-warm the in-memory dedup cache with message IDs already persisted in the local DB.
    // Called by MessageSyncService on start() so the first poll after a cold restart does not
    // re-download media for messages that were already processed in a previous session.
    // Default is a no-op; overridden by YaloMessageRepositoryRemote.
    fun warmDedupCache(wiIds: Collection<String>) {}

    // Cart operations — mirrors flutter-sdk YaloMessageRepository.
    // Default no-op so FakeYaloMessageRepository and test stubs don't need to override them.
    // YaloMessageRepositoryRemote overrides these: if a ChatCommand callback is registered the
    // callback fires and the API call is skipped; otherwise the request is sent to the backend.
    suspend fun addToCart(sku: String, quantity: Double): Result<Unit> = Result.Ok(Unit)
    suspend fun removeFromCart(sku: String, quantity: Double?): Result<Unit> = Result.Ok(Unit)
    suspend fun clearCart(): Result<Unit> = Result.Ok(Unit)
    suspend fun addPromotion(promotionId: String): Result<Unit> = Result.Ok(Unit)
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatCommand
import com.yalo.chat.sdk.domain.model.ChatCommandCallback
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.ui.chat.UnitType
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow

interface YaloMessageRepository {
    suspend fun sendMessage(message: ChatMessage): Result<Unit>
    // `since` is unused in the single-shot startup load (full history fetch).
    // Continuous polling uses its own internal watermark via pollIncomingMessages().
    suspend fun fetchMessages(since: Long): Result<List<ChatMessage>>

    // Continuous polling flow — each emission is the batch of new messages from one poll cycle.
    // Empty batches are suppressed; only non-empty lists are emitted.
    fun pollIncomingMessages(): Flow<List<ChatMessage>>

    // Typing event stream: TypingStart is emitted by sendMessage(); TypingStop is emitted
    // when messages arrive or a fetch error occurs.
    fun events(): Flow<ChatEvent> = emptyFlow()

    // Pre-warm the in-memory dedup cache with message IDs already persisted in the local DB.
    // Called by MessageSyncService on start() so the first poll after a cold restart does not
    // re-download media for messages that were already processed in a previous session.
    // Default is a no-op; overridden by YaloMessageRepositoryRemote.
    fun warmDedupCache(wiIds: Collection<String>) {}

    // Cart operations — default no-op so fake/test repos don't need to override them.
    // If a ChatCommand callback is registered the callback fires instead of the API call.
    suspend fun addToCart(sku: String, quantity: Double, unitType: UnitType? = null): Result<Unit> = Result.Ok(Unit)
    suspend fun removeFromCart(sku: String, quantity: Double?, unitType: UnitType? = null): Result<Unit> = Result.Ok(Unit)
    suspend fun clearCart(): Result<Unit> = Result.Ok(Unit)
    suspend fun addPromotion(promotionId: String): Result<Unit> = Result.Ok(Unit)

    // Command registration — overridden by real transports; fake/test repos ignore commands.
    fun registerCommand(command: ChatCommand, callback: ChatCommandCallback) {}
    val commandsSnapshot: Map<ChatCommand, ChatCommandCallback> get() = emptyMap()

    // Lifecycle hooks for app-level pause/resume (e.g. Activity.onStop / onStart).
    // WebSocket transport disconnects on pause and reconnects on resume.
    // Long-poll transport ignores these (polling is managed by the flow collector).
    fun pause() {}
    fun resume() {}
}

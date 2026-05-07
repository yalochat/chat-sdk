// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.YaloMessageServiceWebSocket
import com.yalo.chat.sdk.data.remote.model.SdkMessageBody
import com.yalo.chat.sdk.data.remote.model.SdkTextMessageBody
import com.yalo.chat.sdk.data.remote.model.SdkTextMessageRequestBody
import com.yalo.chat.sdk.domain.model.ChatCommand
import com.yalo.chat.sdk.domain.model.ChatCommandCallback
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import com.yalo.chat.sdk.ui.chat.UnitType
import kotlin.concurrent.Volatile
import kotlin.uuid.ExperimentalUuidApi
import kotlin.uuid.Uuid
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapNotNull
import kotlinx.datetime.Clock

// Port of flutter-sdk YaloMessageRepositoryWebSocket.
// Implements YaloMessageRepository using a persistent WebSocket connection.
// Plug-in replacement for YaloMessageRepositoryRemote — MessagesViewModel and
// MessageSyncService are unaware of which transport is active.
@OptIn(ExperimentalUuidApi::class)
internal class YaloMessageRepositoryWebSocket(
    private val wsService: YaloMessageServiceWebSocket,
    private val apiService: YaloChatApiService,
    private val tempDir: String? = null,
) : YaloMessageRepository {

    private val cache = SimpleCache<String, Boolean>(capacity = 500)
    private val _events = MutableSharedFlow<ChatEvent>(extraBufferCapacity = Channel.UNLIMITED)

    @Volatile private var commands: Map<ChatCommand, ChatCommandCallback> = emptyMap()
    @Volatile private var paused = false
    private var scope: CoroutineScope? = null

    // ── Lifecycle ──────────────────────────────────────────────────────────────

    // Called by YaloChat.init() after construction to start the connection loop.
    fun start(scope: CoroutineScope) {
        this.scope = scope
        wsService.connect(scope)
    }

    override fun pause() {
        paused = true
        wsService.disconnect()
    }

    override fun resume() {
        if (!paused) return
        paused = false
        scope?.let { wsService.connect(it) }
    }

    // ── YaloMessageRepository ──────────────────────────────────────────────────

    override suspend fun fetchMessages(since: Long): Result<List<ChatMessage>> =
        when (val result = apiService.fetchMessages()) {
            is Result.Ok -> Result.Ok(result.result.mapIndexedNotNull { index, item ->
                item.toChatMessage(deduplicate = false, index = index, cache = cache, apiService = apiService, tempDir = tempDir)
            })
            is Result.Error -> Result.Error(result.error)
        }

    override suspend fun sendMessage(message: ChatMessage): Result<Unit> {
        if (message.type != MessageType.Text) {
            return Result.Error(UnsupportedOperationException("WebSocket transport only supports text sends; got ${message.type}"))
        }
        val nowIso = Clock.System.now().toString()
        _events.tryEmit(ChatEvent.TypingStart(TYPING_STATUS_TEXT))
        val body = SdkMessageBody(
            correlationId = Uuid.random().toString(),
            timestamp = nowIso,
            textMessageRequest = SdkTextMessageRequestBody(
                content = SdkTextMessageBody(text = message.content, timestamp = nowIso),
                timestamp = nowIso,
            ),
        )
        val result = apiService.sendMessage(body)
        if (result is Result.Error) _events.tryEmit(ChatEvent.TypingStop)
        return result
    }

    // Each WebSocket frame that passes dedup becomes a single-item list, mirroring
    // the polling repo's per-message emission contract.
    // Exceptions from toChatMessage (e.g. failed media download) are caught so the
    // flow never terminates — same contract as YaloMessageRepositoryRemote.pollIncomingMessages.
    override fun pollIncomingMessages(): Flow<List<ChatMessage>> =
        wsService.frames
            .mapNotNull { frame ->
                try {
                    frame.toChatMessage(
                        deduplicate = true,
                        index = 0,
                        cache = cache,
                        apiService = apiService,
                        tempDir = tempDir,
                    )
                } catch (e: CancellationException) {
                    throw e
                } catch (_: Exception) {
                    null
                }
            }
            .map { msg ->
                _events.tryEmit(ChatEvent.TypingStop)
                listOf(msg)
            }

    override fun events(): Flow<ChatEvent> = _events.asSharedFlow()

    override fun warmDedupCache(wiIds: Collection<String>) {
        wiIds.forEach { cache.set(it, true) }
    }

    // ── Command registration ───────────────────────────────────────────────────

    override fun registerCommand(command: ChatCommand, callback: ChatCommandCallback) {
        commands = commands + (command to callback)
    }

    override val commandsSnapshot: Map<ChatCommand, ChatCommandCallback> get() = commands

    // ── Cart operations ────────────────────────────────────────────────────────

    override suspend fun addToCart(sku: String, quantity: Double, unitType: UnitType?): Result<Unit> {
        val callback = commands[ChatCommand.ADD_TO_CART]
        if (callback != null) {
            callback(mapOf(KEY_SKU to sku, KEY_QUANTITY to quantity, KEY_UNIT_TYPE to unitType))
            return Result.Ok(Unit)
        }
        return apiService.addToCart(sku, quantity, unitType.toApiString())
    }

    override suspend fun removeFromCart(sku: String, quantity: Double?, unitType: UnitType?): Result<Unit> {
        val callback = commands[ChatCommand.REMOVE_FROM_CART]
        if (callback != null) {
            callback(mapOf(KEY_SKU to sku, KEY_QUANTITY to quantity, KEY_UNIT_TYPE to unitType))
            return Result.Ok(Unit)
        }
        return apiService.removeFromCart(sku, quantity, unitType.toApiString())
    }

    override suspend fun clearCart(): Result<Unit> {
        val callback = commands[ChatCommand.CLEAR_CART]
        if (callback != null) {
            callback(null)
            return Result.Ok(Unit)
        }
        return apiService.clearCart()
    }

    override suspend fun addPromotion(promotionId: String): Result<Unit> {
        val callback = commands[ChatCommand.ADD_PROMOTION]
        if (callback != null) {
            callback(mapOf(KEY_PROMOTION_ID to promotionId))
            return Result.Ok(Unit)
        }
        return apiService.addPromotion(promotionId)
    }
}

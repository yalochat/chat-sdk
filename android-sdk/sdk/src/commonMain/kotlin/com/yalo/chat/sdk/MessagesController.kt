// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.MessageSyncService
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import kotlin.math.floor

// Swift-facing counterpart to Android's MessagesViewModel.
// Callback API avoids requiring Swift callers to collect a KMP Flow directly.
// mainDispatcher defaults to Dispatchers.Main; inject a test dispatcher in unit tests.
class MessagesController internal constructor(
    private val yaloRepo: YaloMessageRepository,
    private val localRepo: ChatMessageRepository,
    private val syncService: MessageSyncService,
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main,
) {
    private var scope: CoroutineScope? = null
    private var eventsJob: Job? = null
    // Counter is only ever read/written from the main thread (same dispatcher as the scope).
    // Refreshed against the wall clock on every send so user-message tempIds always sort
    // AFTER agent messages whose ids were bumped to receiptFloor by ensureReceiptOrder.
    private var tempIdSeq: Long = 0L
    // Latest messages snapshot — kept in sync by start() so updateProductQuantity can
    // find and patch a message without an extra DB round-trip.
    private var cachedMessages: List<ChatMessage> = emptyList()

    private fun nextTempId(): Long {
        val now = Clock.System.now().toEpochMilliseconds()
        if (now > tempIdSeq) tempIdSeq = now
        return tempIdSeq++
    }

    fun start(onMessagesUpdate: (List<ChatMessage>) -> Unit) {
        if (scope != null) return
        val s = CoroutineScope(SupervisorJob() + mainDispatcher)
        scope = s
        syncService.start(s)
        s.launch {
            localRepo.observeMessages().collect { messages ->
                cachedMessages = messages
                onMessagesUpdate(messages)
            }
        }
    }

    fun stop() {
        syncService.stop()
        eventsJob?.cancel()
        eventsJob = null
        scope?.cancel()
        scope = null
    }

    fun loadMessages(onComplete: ((Boolean) -> Unit)? = null) {
        val s = scope ?: return
        s.launch {
            val ok = localRepo.getMessages(cursor = null, limit = 30) is Result.Ok
            onComplete?.invoke(ok)
        }
    }

    fun sendTextMessage(text: String) {
        if (text.isBlank()) return
        val s = scope ?: return
        val tempId = nextTempId()
        val optimistic = ChatMessage(
            id = tempId,
            role = MessageRole.USER,
            type = MessageType.Text,
            status = MessageStatus.SENT,
            content = text,
            timestamp = Clock.System.now().toEpochMilliseconds(),
        )
        s.launch {
            when (localRepo.insertMessage(optimistic)) {
                is Result.Ok -> s.launch {
                    if (yaloRepo.sendMessage(optimistic) is Result.Error) {
                        localRepo.updateMessage(optimistic.copy(status = MessageStatus.ERROR))
                    }
                }
                is Result.Error -> Unit
            }
        }
    }

    fun sendImageMessage(fileName: String, mimeType: String) {
        if (fileName.isEmpty()) return
        val s = scope ?: return
        val tempId = nextTempId()
        val message = ChatMessage(
            id = tempId,
            role = MessageRole.USER,
            type = MessageType.Image,
            status = MessageStatus.SENT,
            fileName = fileName,
            mediaType = mimeType.ifBlank { "image/jpeg" },
            timestamp = Clock.System.now().toEpochMilliseconds(),
        )
        s.launch {
            when (localRepo.insertMessage(message)) {
                is Result.Ok -> s.launch {
                    if (yaloRepo.sendMessage(message) is Result.Error) {
                        localRepo.updateMessage(message.copy(status = MessageStatus.ERROR))
                    }
                }
                is Result.Error -> Unit
            }
        }
    }

    fun sendVoiceMessage(fileName: String, amplitudes: List<Double>, durationMs: Long) {
        if (fileName.isEmpty()) return
        val s = scope ?: return
        val tempId = nextTempId()
        val message = ChatMessage(
            id = tempId,
            role = MessageRole.USER,
            type = MessageType.Voice,
            status = MessageStatus.SENT,
            fileName = fileName,
            amplitudes = amplitudes,
            duration = durationMs,
            mediaType = "audio/mp4",
            timestamp = Clock.System.now().toEpochMilliseconds(),
        )
        s.launch {
            when (localRepo.insertMessage(message)) {
                is Result.Ok -> s.launch {
                    if (yaloRepo.sendMessage(message) is Result.Error) {
                        localRepo.updateMessage(message.copy(status = MessageStatus.ERROR))
                    }
                }
                is Result.Error -> Unit
            }
        }
    }

    // Mirrors Android MessagesViewModel.subscribeToEvents().
    // Must be called after start() — requires an active scope.
    // Idempotent: re-entry after stop()/start() cycle restarts the job.
    fun startEventsObservation(onTypingStart: (String) -> Unit, onTypingStop: () -> Unit) {
        val s = scope ?: return
        if (eventsJob?.isActive == true) return
        eventsJob = s.launch {
            yaloRepo.events().collect { event ->
                when (event) {
                    is ChatEvent.TypingStart -> onTypingStart(event.statusText)
                    is ChatEvent.TypingStop -> onTypingStop()
                }
            }
        }
    }

    // Mirrors Android MessagesViewModel.updateProductQuantity().
    // isSubunit=false → update unitsAdded; isSubunit=true → update subunitsAdded with overflow.
    fun updateProductQuantity(messageId: Long, productSku: String, isSubunit: Boolean, quantity: Double) {
        val s = scope ?: return
        val msg = cachedMessages.find { it.id == messageId } ?: return
        val updatedMsg = msg.copy(
            products = msg.products.map { product ->
                if (product.sku != productSku) return@map product
                if (!isSubunit) {
                    product.copy(unitsAdded = maxOf(quantity, 0.0))
                } else if (product.subunits <= 0.0) {
                    product.copy(unitsAdded = maxOf(quantity, 0.0))
                } else {
                    val clamped = maxOf(quantity, 0.0)
                    val extraUnits = floor(clamped / product.subunits)
                    val remainingSubunits = clamped % product.subunits
                    product.copy(
                        unitsAdded = product.unitsAdded + extraUnits,
                        subunitsAdded = remainingSubunits,
                    )
                }
            }
        )
        cachedMessages = cachedMessages.map { if (it.id == messageId) updatedMsg else it }
        s.launch { localRepo.updateMessage(updatedMsg) }
    }
}

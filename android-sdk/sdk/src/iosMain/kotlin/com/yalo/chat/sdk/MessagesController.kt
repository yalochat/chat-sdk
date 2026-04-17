// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.MessageSyncService
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlin.concurrent.AtomicLong
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock

// iOS counterpart to Android's MessagesViewModel.
// Owns the coroutine scope, sync lifecycle, and optimistic send logic.
// Uses a callback API so Swift never has to collect a KMP Flow directly.
class MessagesController internal constructor(
    private val yaloRepo: YaloMessageRepository,
    private val localRepo: ChatMessageRepository,
    private val syncService: MessageSyncService,
) {
    private var scope: CoroutineScope? = null

    // Seeded from current epoch-ms — mirrors Android MessagesViewModel.tempIdSeq.
    private val tempIdSeq = AtomicLong(Clock.System.now().toEpochMilliseconds())

    // Starts the coroutine scope, polling sync, and local DB observation.
    // Idempotent — a second call while already active is a no-op.
    // Mirrors Android's SubscribeToMessages handler.
    fun start(onMessagesUpdate: (List<ChatMessage>) -> Unit) {
        if (scope != null) return
        val s = CoroutineScope(SupervisorJob() + Dispatchers.Main)
        scope = s
        syncService.start(s)
        s.launch {
            localRepo.observeMessages().collect { messages ->
                onMessagesUpdate(messages)
            }
        }
    }

    fun stop() {
        syncService.stop()
        scope?.cancel()
        scope = null
    }

    // One-shot read of current local DB state.
    // Mirrors Android's LoadMessages handler (reads LOCAL DB, not remote).
    fun loadMessages(onComplete: ((Boolean) -> Unit)? = null) {
        val s = scope ?: return
        s.launch {
            val ok = localRepo.getMessages(cursor = null, limit = 30) is Result.Ok
            onComplete?.invoke(ok)
        }
    }

    // Optimistic text send — mirrors Android MessagesViewModel.sendTextMessage().
    // Inserts a local optimistic bubble immediately, then sends to the remote asynchronously.
    // On remote error, updates the message status to ERROR.
    fun sendTextMessage(text: String) {
        if (text.isBlank()) return
        val s = scope ?: return
        val tempId = tempIdSeq.getAndIncrement()
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
}

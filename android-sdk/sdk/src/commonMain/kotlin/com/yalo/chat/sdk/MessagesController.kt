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
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock

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
    // Counter is only ever read/written from the main thread (same dispatcher as the scope).
    private var tempIdSeq: Long = Clock.System.now().toEpochMilliseconds()

    fun start(onMessagesUpdate: (List<ChatMessage>) -> Unit) {
        if (scope != null) return
        val s = CoroutineScope(SupervisorJob() + mainDispatcher)
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
        val tempId = tempIdSeq++
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
        val tempId = tempIdSeq++
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
        val tempId = tempIdSeq++
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
}

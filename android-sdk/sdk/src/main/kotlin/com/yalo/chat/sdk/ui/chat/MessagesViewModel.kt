// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.MessageSyncService
import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.ImageData
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import java.util.concurrent.atomic.AtomicLong
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

// Port of flutter-sdk/lib/src/ui/chat/view_models/messages/messages_bloc.dart
// Phase 2 M2: subscribeToMessages() now only observes the local store.
// Remote polling is handled by MessageSyncService (FDE-56), which writes incoming
// server messages to SQLDelight so the observeMessages() flow picks them up.
internal class MessagesViewModel(
    private val yaloMessageRepository: YaloMessageRepository,
    private val chatMessageRepository: ChatMessageRepository,
    // null in tests — sync is driven externally (or not at all) in unit tests.
    private val syncService: MessageSyncService? = null,
) : ViewModel() {

    private val _state = MutableStateFlow(MessagesState())
    val state: StateFlow<MessagesState> = _state.asStateFlow()

    // Keeps the active subscription job so SubscribeToMessages is idempotent.
    private var subscriptionJob: Job? = null

    // Incrementing counter seeded from current epoch-ms so optimistic temp IDs:
    //  1. Never collide across sessions (different session → different starting time)
    //  2. Sort at the bottom in ORDER BY id ASC (most recent, correct chat position)
    // Server message IDs are also epoch-ms based, so optimistic and server messages
    // interleave correctly by send time.
    private val tempIdSeq = AtomicLong(System.currentTimeMillis())

    fun handleEvent(event: MessagesEvent) {
        when (event) {
            is MessagesEvent.LoadMessages -> loadMessages()
            is MessagesEvent.SubscribeToMessages -> subscribeToMessages()
            is MessagesEvent.SendTextMessage -> sendTextMessage(event.text)
            is MessagesEvent.SendImageMessage -> sendImageMessage(event.imageData)
            is MessagesEvent.SendVoiceMessage -> sendVoiceMessage(event.audioData)
            is MessagesEvent.UpdateUserMessage -> _state.update { it.copy(userMessage = event.value) }
            is MessagesEvent.ClearMessages -> {
                syncService?.stop()
                // Cancel and reset subscriptionJob so SubscribeToMessages restarts polling
                // correctly if the host app re-enters ChatScreen without destroying the ViewModel.
                subscriptionJob?.cancel()
                subscriptionJob = null
                _state.value = MessagesState()
            }
            is MessagesEvent.ClearQuickReplies -> _state.update { it.copy(quickReplies = emptyList()) }
        }
    }

    private fun loadMessages() {
        viewModelScope.launch {
            _state.update { it.copy(isLoading = true) }
            when (val result = chatMessageRepository.getMessages(cursor = null, limit = _state.value.pageInfo.pageSize)) {
                is Result.Ok -> _state.update {
                    it.copy(
                        messages = result.result,
                        quickReplies = result.result.extractQuickReplies(),
                        chatStatus = ChatStatus.Success,
                        isLoading = false,
                    )
                }
                is Result.Error -> _state.update {
                    it.copy(
                        chatStatus = ChatStatus.Failure,
                        isLoading = false,
                    )
                }
            }
        }
    }

    private fun subscribeToMessages() {
        // Return early if already collecting — makes this call idempotent.
        if (subscriptionJob?.isActive == true) return
        // Start remote polling lazily so it only runs while the chat UI is active.
        // Polling is scoped to viewModelScope and stops automatically when the ViewModel is cleared.
        syncService?.start(viewModelScope)
        // Observe local store — MessageSyncService writes remote messages here,
        // so the UI always reads from a single source of truth (SQLDelight / fake repo).
        subscriptionJob = viewModelScope.launch {
            chatMessageRepository.observeMessages().collect { messages ->
                _state.update {
                    it.copy(
                        messages = messages,
                        quickReplies = messages.extractQuickReplies(),
                    )
                }
            }
        }
    }

    private fun sendTextMessage(text: String) {
        if (text.isBlank()) return
        viewModelScope.launch {
            val tempId = tempIdSeq.getAndIncrement()
            val optimistic = ChatMessage(
                id = tempId,
                role = MessageRole.USER,
                type = MessageType.Text,
                status = MessageStatus.SENT,
                content = text,
            )
            when (chatMessageRepository.insertMessage(optimistic)) {
                is Result.Ok -> {
                    _state.update { it.copy(userMessage = "") }
                    // Send to remote and update the optimistic message on failure.
                    launch {
                        if (yaloMessageRepository.sendMessage(optimistic) is Result.Error) {
                            chatMessageRepository.updateMessage(
                                optimistic.copy(status = MessageStatus.ERROR)
                            )
                        }
                    }
                }
                is Result.Error -> _state.update { it.copy(chatStatus = ChatStatus.Failure) }
            }
        }
    }

    // FDE-63: Inserts a voice message locally after recording completes.
    // Voice messages are not sent to the remote API in Phase 2 — same pattern as images.
    // amplitudesPreview is persisted so the waveform renders on replay.
    private fun sendVoiceMessage(audioData: AudioData) {
        if (audioData.fileName.isEmpty()) return
        viewModelScope.launch {
            val tempId = tempIdSeq.getAndIncrement()
            val message = ChatMessage(
                id = tempId,
                role = MessageRole.USER,
                type = MessageType.Voice,
                status = MessageStatus.SENT,
                fileName = audioData.fileName,
                amplitudes = audioData.amplitudesPreview,
                duration = audioData.durationMs,
            )
            if (chatMessageRepository.insertMessage(message) is Result.Error) {
                _state.update { it.copy(chatStatus = ChatStatus.Failure) }
            }
        }
    }


    // Inserts an image message locally. Images are not sent to the remote API in Phase 2 —
    // the backend does not yet accept image payloads (YaloMessageRepository.sendMessage()
    // returns Result.Error for non-text types). Local-only insertion keeps the message
    // visible in the chat with status SENT.
    private fun sendImageMessage(imageData: ImageData) {
        if (imageData.path == null) return
        viewModelScope.launch {
            val tempId = tempIdSeq.getAndIncrement()
            val message = ChatMessage(
                id = tempId,
                role = MessageRole.USER,
                type = MessageType.Image,
                status = MessageStatus.SENT,
                fileName = imageData.path,
            )
            if (chatMessageRepository.insertMessage(message) is Result.Error) {
                _state.update { it.copy(chatStatus = ChatStatus.Failure) }
            }
        }
    }
}

// Derives quick replies from the most recent QuickReply message in the list,
// mirroring the Flutter SDK behaviour where the last agent quick-reply message
// drives the overlay buttons above ChatInput.
private fun List<ChatMessage>.extractQuickReplies(): List<String> =
    lastOrNull { it.type == MessageType.QuickReply && it.role == MessageRole.AGENT }?.quickReplies.orEmpty()

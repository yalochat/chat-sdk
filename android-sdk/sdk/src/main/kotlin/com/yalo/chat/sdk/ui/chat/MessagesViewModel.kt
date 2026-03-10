// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

// Port of flutter-sdk/lib/src/ui/chat/view_models/messages/messages_bloc.dart
class MessagesViewModel(
    private val yaloMessageRepository: YaloMessageRepository,
    private val chatMessageRepository: ChatMessageRepository,
) : ViewModel() {

    private val _state = MutableStateFlow(MessagesState())
    val state: StateFlow<MessagesState> = _state.asStateFlow()

    // Keeps the active subscription job so SubscribeToMessages is idempotent.
    private var subscriptionJob: Job? = null

    fun handleEvent(event: MessagesEvent) {
        when (event) {
            is MessagesEvent.LoadMessages -> loadMessages()
            is MessagesEvent.SubscribeToMessages -> subscribeToMessages()
            is MessagesEvent.SendTextMessage -> sendTextMessage(event.text)
            is MessagesEvent.UpdateUserMessage -> _state.update { it.copy(userMessage = event.value) }
            is MessagesEvent.ClearMessages -> _state.value = MessagesState()
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
        // Cancel any existing subscription before starting a new one so this
        // call is idempotent (safe to call from LaunchedEffect multiple times).
        subscriptionJob?.cancel()
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
            val tempId = System.currentTimeMillis()
            val optimistic = ChatMessage(
                id = tempId,
                role = MessageRole.USER,
                type = MessageType.Text,
                status = MessageStatus.SENT,
                content = text,
            )
            _state.update { it.copy(userMessage = "") }
            chatMessageRepository.insertMessage(optimistic)
            when (yaloMessageRepository.sendMessage(optimistic)) {
                is Result.Ok -> Unit
                // Send failure: mark the individual message as ERROR.
                // chatStatus is not changed to Failure here — a send error is message-level,
                // not a fatal chat-level failure (mirrors Flutter SDK MessagesBloc behavior).
                is Result.Error -> chatMessageRepository.updateMessage(
                    optimistic.copy(status = MessageStatus.ERROR)
                )
            }
        }
    }
}

// Derives quick replies from the most recent QuickReply message in the list,
// mirroring the Flutter SDK behaviour where the last agent quick-reply message
// drives the overlay buttons above ChatInput.
private fun List<ChatMessage>.extractQuickReplies(): List<String> =
    lastOrNull { it.type == MessageType.QuickReply && it.role == MessageRole.AGENT }?.quickReplies.orEmpty()

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
import java.util.concurrent.atomic.AtomicLong
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.supervisorScope
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

    // Decrementing counter for optimistic temp IDs — always negative so they
    // never collide with real server IDs (which are positive).
    private val tempIdSeq = AtomicLong(-1L)

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
        // Return early if already collecting — makes this call idempotent without
        // the brief window where two collectors could be active after cancel+launch.
        if (subscriptionJob?.isActive == true) return
        subscriptionJob = viewModelScope.launch {
            // supervisorScope isolates the two child coroutines: an unexpected failure in
            // one (e.g., an unhandled throw from a Flow collect) does not cancel the other.
            supervisorScope {
                // 1. Observe local store — drives all UI updates.
                launch {
                    chatMessageRepository.observeMessages().collect { messages ->
                        _state.update {
                            it.copy(
                                messages = messages,
                                quickReplies = messages.extractQuickReplies(),
                            )
                        }
                    }
                }
                // 2. Poll remote for new inbound messages; insert into local store so
                //    the observer above picks them up automatically.
                //    Errors are swallowed inside pollIncomingMessages(), mirroring
                //    flutter-sdk YaloMessageRepositoryRemote._startPolling().
                launch {
                    yaloMessageRepository.pollIncomingMessages()
                        .collect { message ->
                            // Mirror Flutter _handleMessagesSubscription: on insert error the
                            // message is dropped and the chat is marked as failed to receive.
                            when (chatMessageRepository.insertMessage(message)) {
                                is Result.Ok -> Unit
                                is Result.Error -> _state.update { it.copy(chatStatus = ChatStatus.Failure) }
                            }
                        }
                }
            }
        }
    }

    private fun sendTextMessage(text: String) {
        if (text.isBlank()) return
        viewModelScope.launch {
            val tempId = tempIdSeq.getAndDecrement()
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
                    // Fire-and-forget — mirrors Flutter SDK MessagesBloc._handleSendTextMessage
                    // which calls _yaloMessageRepository.sendMessage() without awaiting.
                    launch { yaloMessageRepository.sendMessage(optimistic) }
                }
                is Result.Error -> _state.update { it.copy(chatStatus = ChatStatus.Failure) }
            }
        }
    }
}

// Derives quick replies from the most recent QuickReply message in the list,
// mirroring the Flutter SDK behaviour where the last agent quick-reply message
// drives the overlay buttons above ChatInput.
private fun List<ChatMessage>.extractQuickReplies(): List<String> =
    lastOrNull { it.type == MessageType.QuickReply && it.role == MessageRole.AGENT }?.quickReplies.orEmpty()

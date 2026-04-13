// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.MessageSyncService
import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ChatEvent
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

// subscribeToMessages() only observes the local store — remote polling is delegated to
// MessageSyncService, which writes incoming server messages to SQLDelight so the
// observeMessages() flow is the single source of truth for the UI.
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

    // Keeps the active events job so SubscribeToEvents is idempotent.
    private var eventsJob: Job? = null

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
            is MessagesEvent.SubscribeToEvents -> subscribeToEvents()
            is MessagesEvent.SendTextMessage -> sendTextMessage(event.text)
            is MessagesEvent.SendImageMessage -> sendImageMessage(event.imageData)
            is MessagesEvent.SendVoiceMessage -> sendVoiceMessage(event.audioData)
            is MessagesEvent.UpdateUserMessage -> _state.update { it.copy(userMessage = event.value) }
            is MessagesEvent.ChatToggleMessageExpand -> toggleMessageExpand(event.messageId)
            is MessagesEvent.ChatUpdateProductQuantity -> updateProductQuantity(
                event.messageId, event.productSku, event.unitType, event.quantity
            )
            is MessagesEvent.ClearMessages -> {
                syncService?.stop()
                // Cancel and reset both jobs so SubscribeToMessages / SubscribeToEvents restart
                // correctly if the host app re-enters ChatScreen without destroying the ViewModel.
                subscriptionJob?.cancel()
                subscriptionJob = null
                eventsJob?.cancel()
                eventsJob = null
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

    // Mirrors Flutter's _handleEventsSubscription: collects ChatEvent from the repository
    // and maps TypingStart/TypingStop to isSystemTypingMessage + chatStatusText in state.
    private fun subscribeToEvents() {
        if (eventsJob?.isActive == true) return
        eventsJob = viewModelScope.launch {
            yaloMessageRepository.events().collect { event ->
                when (event) {
                    is ChatEvent.TypingStart -> _state.update {
                        it.copy(isSystemTypingMessage = true, chatStatusText = event.statusText)
                    }
                    is ChatEvent.TypingStop -> _state.update {
                        it.copy(isSystemTypingMessage = false, chatStatusText = "")
                    }
                }
            }
        }
    }

    // Mirrors Flutter's ChatToggleMessageExpand handler.
    // Toggles expand in-memory; expand is never persisted to DB.
    private fun toggleMessageExpand(messageId: Long) {
        _state.update { state ->
            state.copy(
                messages = state.messages.map { msg ->
                    if (msg.id == messageId) msg.copy(expand = !msg.expand) else msg
                }
            )
        }
    }

    // Mirrors Flutter's ChatUpdateProductQuantity handler.
    // Updates unitsAdded or subunitsAdded on the matching product inside the matching message,
    // then persists the updated message to the local DB (mirrors Flutter's replaceChatMessage
    // call — products are stored as JSON in the products column so quantities survive
    // subsequent observeMessages emissions).
    private fun updateProductQuantity(
        messageId: Long,
        productSku: String,
        unitType: UnitType,
        quantity: Double,
    ) {
        var updatedMessage: ChatMessage? = null
        _state.update { state ->
            val newMessages = state.messages.map { msg ->
                if (msg.id != messageId) return@map msg
                msg.copy(
                    products = msg.products.map { product ->
                        if (product.sku != productSku) return@map product
                        when (unitType) {
                            UnitType.UNIT -> product.copy(unitsAdded = quantity)
                            UnitType.SUBUNIT -> product.copy(subunitsAdded = quantity)
                        }
                    }
                ).also { updatedMessage = it }
            }
            state.copy(messages = newMessages)
        }
        updatedMessage?.let { msg ->
            viewModelScope.launch {
                chatMessageRepository.updateMessage(msg)
                // observeMessages() will re-emit with the persisted quantities — no
                // extra state update needed here.
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
                _state.update { currentState ->
                    // Preserve in-memory expand flags: DB never stores `expand` (it always
                    // reads back as false), so re-mapping the observed list by id keeps
                    // expanded/collapsed state alive across subsequent emissions.
                    val expandById = currentState.messages.associate { it.id to it.expand }
                    val mergedMessages = messages.map { msg ->
                        if (expandById[msg.id] == true) msg.copy(expand = true) else msg
                    }
                    // Only overwrite quickReplies when a NEW QuickReply message arrived.
                    // Detection is by wiId (server-assigned ID) so that re-sends of
                    // the same content after ClearQuickReplies are correctly shown again.
                    // Comparing list contents (previous approach) would treat a re-sent
                    // QuickReply with identical options as "no change" and leave the chip
                    // row empty. Without this guard entirely, ClearQuickReplies is undone
                    // the moment any subsequent message is inserted (e.g. a user text send
                    // triggers observeMessages, which would find the old QuickReply message
                    // and restore its replies).
                    val latestQrWiId = mergedMessages
                        .lastOrNull { it.type == MessageType.QuickReply && it.role == MessageRole.AGENT }
                        ?.wiId
                    val quickReplies = if (latestQrWiId != null && latestQrWiId != currentState.lastQuickReplyMessageWiId) {
                        mergedMessages.extractQuickReplies()
                    } else {
                        currentState.quickReplies
                    }
                    currentState.copy(
                        messages = mergedMessages,
                        quickReplies = quickReplies,
                        lastQuickReplyMessageWiId = latestQrWiId ?: currentState.lastQuickReplyMessageWiId,
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
                mediaType = "audio/mp4",
            )
            when (chatMessageRepository.insertMessage(message)) {
                is Result.Ok -> launch {
                    if (yaloMessageRepository.sendMessage(message) is Result.Error) {
                        chatMessageRepository.updateMessage(
                            message.copy(status = MessageStatus.ERROR)
                        )
                    }
                }
                is Result.Error -> _state.update { it.copy(chatStatus = ChatStatus.Failure) }
            }
        }
    }

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
                mediaType = imageData.mimeType,
            )
            when (chatMessageRepository.insertMessage(message)) {
                is Result.Ok -> launch {
                    if (yaloMessageRepository.sendMessage(message) is Result.Error) {
                        chatMessageRepository.updateMessage(
                            message.copy(status = MessageStatus.ERROR)
                        )
                    }
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

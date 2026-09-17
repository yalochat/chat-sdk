// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.viewmodels

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.config.ChatDependencies
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepository
import ai.yalo.chat.sdk.data.repositories.yalomessage.YaloMessageRepository
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.createSavedStateHandle
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.seconds

/**
 * Everything the chat screen shows at a given moment.
 *
 * [status] is the line under the channel name, for things like "typing...".
 * Nothing produces it yet, so the header leaves it out until the message
 * repository starts reporting it.
 */
internal data class ChatUiState(
    val title: String,
    val draft: String = "",
    val status: String? = null,
    val messages: List<ChatMessage> = emptyList(),
    val isWaitingForReply: Boolean = false,
)

/**
 * Holds the chat screen state and turns what the user does into stored
 * messages.
 *
 * Sending writes through [chatMessageRepository] and then reads the
 * conversation back, so what the screen shows is what storage actually holds
 * rather than a separate copy that can drift from it. Only once the message is
 * stored does it go to the channel through [yaloMessageRepository], so a
 * message the app has shown is one it can send again rather than one it has
 * lost.
 *
 * The draft goes through [SavedStateHandle], so a half typed message survives
 * both a rotation and the process being killed in the background.
 */
internal class ChatViewModel(
    title: String,
    private val chatMessageRepository: ChatMessageRepository,
    private val yaloMessageRepository: YaloMessageRepository,
    private val savedState: SavedStateHandle,
    hostMessages: Flow<String> = emptyFlow(),
    private val now: () -> Long = System::currentTimeMillis,
) : ViewModel() {

    var uiState: ChatUiState by mutableStateOf(
        ChatUiState(title = title, draft = savedState.get<String>(DRAFT_KEY).orEmpty()),
    )
        private set

    private var replyDeadline: Job? = null

    init {
        yaloMessageRepository.connect()
        refreshMessages()
        viewModelScope.launch {
            yaloMessageRepository.messages().collect { message -> receive(message) }
        }
        viewModelScope.launch {
            hostMessages.collect { text -> send(text) }
        }
    }

    fun onDraftChange(value: String) {
        savedState[DRAFT_KEY] = value
        uiState = uiState.copy(draft = value)
    }

    fun onSend() {
        val text = uiState.draft.trim()
        if (text.isEmpty()) {
            return
        }
        onDraftChange("")
        viewModelScope.launch {
            send(text)
        }
    }

    /**
     * Stores [text] as the person's own message, whether they typed it or the
     * host asked for it on their behalf. Both arrive the same way, so a host
     * message is as much part of the conversation as a typed one.
     */
    private suspend fun send(text: String) {
        val content = text.trim()
        if (content.isEmpty()) {
            return
        }
        chatMessageRepository.insert(
            ChatMessage(
                role = MessageRole.User,
                type = MessageType.Text,
                timestamp = now(),
                content = content,
            ),
        ).onSuccess { stored ->
            refreshMessages()
            // Nothing is coming back for a message the channel never took, so
            // the loader is only shown once it has been taken.
            yaloMessageRepository.send(stored).onSuccess {
                waitForReply()
            }
        }
    }

    /**
     * Stores what the channel said and shows it.
     *
     * It is stored before it is shown, for the same reason a sent message is:
     * the screen shows what storage holds, so a reply survives the app being
     * closed. A message the channel repeats is stored once, because it carries
     * the id storage recognises it by.
     */
    private suspend fun receive(message: ChatMessage) {
        chatMessageRepository.insert(message).onSuccess {
            stopWaitingForReply()
            refreshMessages()
        }
    }

    /**
     * Shows the loader until a reply turns up, and gives up after
     * [REPLY_TIMEOUT] so it cannot spin forever against a channel that went
     * quiet.
     *
     * Sending again starts the wait over rather than leaving the first send's
     * deadline in charge. A reply arriving ends it as well, which leaves the
     * timeout as the fallback rather than the only way out.
     */
    private fun waitForReply() {
        replyDeadline?.cancel()
        uiState = uiState.copy(isWaitingForReply = true)
        replyDeadline = viewModelScope.launch {
            delay(REPLY_TIMEOUT)
            uiState = uiState.copy(isWaitingForReply = false)
        }
    }

    private fun stopWaitingForReply() {
        replyDeadline?.cancel()
        replyDeadline = null
        uiState = uiState.copy(isWaitingForReply = false)
    }

    override fun onCleared() {
        yaloMessageRepository.close()
    }

    private fun refreshMessages() {
        viewModelScope.launch {
            chatMessageRepository.messages().onSuccess { stored ->
                uiState = uiState.copy(messages = stored)
            }
        }
    }

    companion object {

        private const val DRAFT_KEY = "yalo-chat-draft"

        /** How long the loader waits before deciding no reply is coming. */
        private val REPLY_TIMEOUT = 45.seconds

        fun factory(
            context: Context,
            client: YaloChatClient,
        ): ViewModelProvider.Factory = viewModelFactory {
            initializer {
                val dependencies = ChatDependencies(context, client.config)
                ChatViewModel(
                    title = client.config.channelName,
                    chatMessageRepository = dependencies.chatMessages,
                    yaloMessageRepository = dependencies.yaloMessages,
                    savedState = createSavedStateHandle(),
                    hostMessages = client.outgoingTextMessages,
                )
            }
        }
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.viewmodels

import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.config.ChatDependencies
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepository
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
 * Sending writes through [chatMessages] and then reads the conversation back,
 * so what the screen shows is what storage actually holds rather than a
 * separate copy that can drift from it.
 *
 * The draft goes through [SavedStateHandle], so a half typed message survives
 * both a rotation and the process being killed in the background.
 */
internal class ChatViewModel(
    title: String,
    private val chatMessages: ChatMessageRepository,
    private val savedState: SavedStateHandle,
    private val now: () -> Long = System::currentTimeMillis,
) : ViewModel() {

    var uiState: ChatUiState by mutableStateOf(
        ChatUiState(title = title, draft = savedState.get<String>(DRAFT_KEY).orEmpty()),
    )
        private set

    private var replyDeadline: Job? = null

    init {
        refreshMessages()
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
            chatMessages.insert(
                ChatMessage(
                    role = MessageRole.User,
                    type = MessageType.Text,
                    timestamp = now(),
                    content = text,
                ),
            ).onSuccess {
                refreshMessages()
                waitForReply()
            }
        }
    }

    /**
     * Shows the loader until a reply turns up, and gives up after
     * [REPLY_TIMEOUT] so it cannot spin forever against a channel that went
     * quiet.
     *
     * Sending again starts the wait over rather than leaving the first send's
     * deadline in charge. Once assistant messages arrive they clear this too,
     * and the timeout becomes the fallback rather than the only way out.
     */
    private fun waitForReply() {
        replyDeadline?.cancel()
        uiState = uiState.copy(isWaitingForReply = true)
        replyDeadline = viewModelScope.launch {
            delay(REPLY_TIMEOUT)
            uiState = uiState.copy(isWaitingForReply = false)
        }
    }

    private fun refreshMessages() {
        viewModelScope.launch {
            chatMessages.messages().onSuccess { stored ->
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
            config: YaloChatClientConfig,
        ): ViewModelProvider.Factory = viewModelFactory {
            initializer {
                ChatViewModel(
                    title = config.channelName,
                    chatMessages = ChatDependencies(context, config).chatMessages,
                    savedState = createSavedStateHandle(),
                )
            }
        }
    }
}

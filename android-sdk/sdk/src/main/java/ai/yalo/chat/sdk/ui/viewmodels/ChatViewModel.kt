// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.viewmodels

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.config.ChatDependencies
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepository
import ai.yalo.chat.sdk.data.repositories.yalomessage.YaloMessageRepository
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.domain.models.quickReplies
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
 *
 * [quickReplies] are the answers the conversation is offering now, and
 * [quickRepliesMessageId] is the message that offered them. Both are here
 * whatever the chat does with them, because where they are drawn is a matter of
 * configuration and which ones are live is not.
 */
internal data class ChatUiState(
    val title: String,
    val draft: String = "",
    val status: String? = null,
    val messages: List<ChatMessage> = emptyList(),
    val isWaitingForReply: Boolean = false,
    val quickReplies: List<MessageButton> = emptyList(),
    val quickRepliesMessageId: Long? = null,
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
    private val openContext: Map<String, String> = emptyMap(),
    private val now: () -> Long = System::currentTimeMillis,
) : ViewModel() {

    var uiState: ChatUiState by mutableStateOf(
        ChatUiState(title = title, draft = savedState.get<String>(DRAFT_KEY).orEmpty()),
    )
        private set

    private var replyDeadline: Job? = null

    init {
        yaloMessageRepository.connect()
        viewModelScope.launch {
            // Only a conversation read back as empty is opened: storage failing
            // says nothing about whether the person has been here before, and
            // greeting them again in the middle of a conversation is worse than
            // not greeting them at all.
            loadMessages().onSuccess { stored ->
                if (stored.isEmpty()) {
                    openConversation()
                }
            }
        }
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

    /** Says a quick reply back to the channel, as if the person had typed it. */
    fun onQuickReply(text: String) {
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

    /** Stores what the channel said and shows it. */
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
     * deadline in charge. A reply arriving ends it as well.
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

    /** The chat is on screen again, so the line to the channel goes back up. */
    fun onScreenShown() {
        yaloMessageRepository.resume()
    }

    /**
     * The chat has left the screen, so the line is dropped.
     *
     * Behind an app the person has put away the system takes the socket, and
     * opening another one gets nowhere and costs battery. Whatever was written
     * meanwhile is kept and goes out when they come back.
     */
    fun onScreenHidden() {
        yaloMessageRepository.pause()
    }

    override fun onCleared() {
        yaloMessageRepository.close()
    }

    /**
     * Says the chat has been opened, and what it was opened from, so the
     * channel can speak before the person does.
     *
     * The loader goes up the same way it does for a sent message, because from
     * here on the chat is waiting on the channel either way.
     */
    private suspend fun openConversation() {
        yaloMessageRepository.requestGuidanceCard(openContext).onSuccess {
            waitForReply()
        }
    }

    private fun refreshMessages() {
        viewModelScope.launch {
            loadMessages()
        }
    }

    private suspend fun loadMessages(): Result<List<ChatMessage>> =
        chatMessageRepository.messages().onSuccess { stored ->
            val offering: ChatMessage? = offeringQuickReplies(stored)
            uiState = uiState.copy(
                messages = stored,
                quickReplies = offering?.quickReplies.orEmpty(),
                quickRepliesMessageId = offering?.id,
            )
        }

    /**
     * The message whose quick replies are still worth offering, if any.
     *
     * Only what the channel has said since the person last spoke counts:
     * answering moves the conversation on, so the offer before it is over. The
     * newest message comes first, which is why the search stops rather than
     * starts at the person.
     */
    private fun offeringQuickReplies(messages: List<ChatMessage>): ChatMessage? = messages
        .takeWhile { message -> message.role != MessageRole.User }
        .firstOrNull { message -> message.quickReplies.isNotEmpty() }

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
                    openContext = client.config.openContext,
                )
            }
        }
    }
}

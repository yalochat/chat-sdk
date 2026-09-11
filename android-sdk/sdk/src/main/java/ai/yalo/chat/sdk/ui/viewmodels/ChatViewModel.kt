// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.viewmodels

import ai.yalo.chat.sdk.YaloChatClientConfig
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.createSavedStateHandle
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory

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
)

/**
 * Holds the chat screen state and turns what the user does into state changes.
 *
 * Sending is not wired to anything yet, so it only clears the draft. Once the
 * message repository exists it gets injected here and [onSend] hands the text
 * to it. Messages, connection status and typing indicators arrive the same way,
 * from the repository, not from this class.
 *
 * The draft goes through [SavedStateHandle], so a half typed message survives
 * both a rotation and the process being killed in the background.
 */
internal class ChatViewModel(
    title: String,
    private val savedState: SavedStateHandle,
) : ViewModel() {

    var uiState: ChatUiState by mutableStateOf(
        ChatUiState(title = title, draft = savedState.get<String>(DRAFT_KEY).orEmpty()),
    )
        private set

    fun onDraftChange(value: String) {
        savedState[DRAFT_KEY] = value
        uiState = uiState.copy(draft = value)
    }

    fun onSend() {
        if (uiState.draft.isBlank()) {
            return
        }
        onDraftChange("")
    }

    companion object {

        private const val DRAFT_KEY = "yalo-chat-draft"

        fun factory(config: YaloChatClientConfig): ViewModelProvider.Factory = viewModelFactory {
            initializer {
                ChatViewModel(
                    title = config.channelName,
                    savedState = createSavedStateHandle(),
                )
            }
        }
    }
}

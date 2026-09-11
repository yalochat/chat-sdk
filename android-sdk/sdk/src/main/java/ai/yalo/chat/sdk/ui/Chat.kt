// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.ui.theme.ChatTheme
import ai.yalo.chat.sdk.ui.theme.ProvideChatTheme
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import ai.yalo.chat.sdk.ui.viewmodels.ChatViewModel
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel

/**
 * Renders the chat inside whatever space the caller gives it.
 *
 * The chat does not apply window insets of its own, so it can be placed in a
 * `Scaffold`, a bottom sheet or any other host. Pass the padding the host hands
 * you through [modifier], for example
 * `Modifier.padding(innerPadding).consumeWindowInsets(innerPadding).imePadding()`.
 *
 * [theme] follows the host `MaterialTheme` unless you pass one in.
 *
 * [avatar] draws whatever you want beside the channel name, an image loaded
 * with your own library or none at all. [onBack] adds a back button to the
 * header, which is absent unless you give one.
 */
@Composable
public fun Chat(
    client: YaloChatClient,
    modifier: Modifier = Modifier,
    theme: ChatTheme = ChatTheme.default(),
    avatar: (@Composable () -> Unit)? = null,
    onBack: (() -> Unit)? = null,
) {
    val viewModel: ChatViewModel = viewModel(
        key = client.config.channelId,
        factory = ChatViewModel.factory(client.config),
    )
    ProvideChatTheme(theme) {
        ChatLayout(
            title = viewModel.uiState.title,
            text = viewModel.uiState.draft,
            onTextChange = viewModel::onDraftChange,
            onSend = viewModel::onSend,
            modifier = modifier,
            status = viewModel.uiState.status,
            avatar = avatar,
            onBack = onBack,
        )
    }
}

@Composable
internal fun ChatLayout(
    title: String,
    text: String,
    onTextChange: (String) -> Unit,
    onSend: () -> Unit,
    modifier: Modifier = Modifier,
    status: String? = null,
    avatar: (@Composable () -> Unit)? = null,
    onBack: (() -> Unit)? = null,
) {
    Surface(
        modifier = modifier.fillMaxSize(),
        color = currentChatTheme.background,
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            ChatHeader(
                title = title,
                status = status,
                avatar = avatar,
                onBack = onBack,
            )
            ChatMessageList(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
            )
            ChatFooter(
                text = text,
                onTextChange = onTextChange,
                onSend = onSend,
            )
        }
    }
}

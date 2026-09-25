// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.QuickReplyType
import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.data.repositories.voice.VoicePlayback
import ai.yalo.chat.sdk.data.repositories.voice.VoiceRecording
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.ui.theme.ChatTheme
import ai.yalo.chat.sdk.ui.theme.ProvideChatTheme
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import ai.yalo.chat.sdk.ui.viewmodels.ChatViewModel
import android.Manifest
import android.content.pm.PackageManager
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import androidx.lifecycle.compose.LifecycleStartEffect
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
 * Quick replies follow `quickReplyType` in the client config: a bar above the
 * message input, or chips under the message that offered them.
 *
 * [avatar] draws whatever you want beside the channel name, an image loaded
 * with your own library or none at all. [onBack] adds a back button to the
 * header, which is absent unless you give one.
 *
 * Voice messages need the `RECORD_AUDIO` permission, which your app declares in
 * its own manifest. The chat asks the person for it the first time they tap the
 * microphone. Set `hideVoiceButton` in the client config to leave voice
 * messages out, and the permission with them.
 */
@Composable
public fun Chat(
    client: YaloChatClient,
    modifier: Modifier = Modifier,
    theme: ChatTheme = ChatTheme.default(),
    avatar: (@Composable () -> Unit)? = null,
    onBack: (() -> Unit)? = null,
) {
    val context = LocalContext.current
    val viewModel: ChatViewModel = viewModel(
        key = client.config.sessionId,
        factory = ChatViewModel.factory(context, client),
    )
    // The line to the channel is worth holding only while the chat is on screen.
    LifecycleStartEffect(viewModel) {
        viewModel.onScreenShown()
        onStopOrDispose { viewModel.onScreenHidden() }
    }
    val startRecording = rememberMicrophoneRequest { viewModel.onStartRecording() }
    // Read where the waveform is drawn rather than here, so a recording moving
    // sixteen times a second does not redraw the conversation behind it.
    val recording: () -> VoiceRecording? = remember(viewModel) { { viewModel.recording } }
    val playback: () -> VoicePlayback? = remember(viewModel) { { viewModel.playback } }
    ProvideChatTheme(theme) {
        ChatLayout(
            title = viewModel.uiState.title,
            text = viewModel.uiState.draft,
            onTextChange = viewModel::onDraftChange,
            onSend = viewModel::onSend,
            modifier = modifier,
            status = viewModel.uiState.status,
            messages = viewModel.uiState.messages,
            isWaitingForReply = viewModel.uiState.isWaitingForReply,
            quickReplyType = client.config.quickReplyType,
            quickReplies = viewModel.uiState.quickReplies,
            quickRepliesMessageId = viewModel.uiState.quickRepliesMessageId,
            onQuickReply = viewModel::onQuickReply,
            avatar = avatar,
            onBack = onBack,
            hideVoiceButton = client.config.hideVoiceButton,
            recording = recording,
            onStartRecording = startRecording,
            onCancelRecording = viewModel::onCancelRecording,
            playback = playback,
            onVoiceMessageToggled = viewModel::onVoiceMessageToggled,
        )
    }
}

/**
 * Asks for the microphone if it has not been granted yet, and calls [onGranted]
 * as soon as it has been.
 *
 * The permission belongs to the app rather than to the SDK, so an app that has
 * not declared `RECORD_AUDIO` gets a refusal straight back and nothing starts,
 * which is the same thing that happens when the person says no.
 */
@Composable
private fun rememberMicrophoneRequest(onGranted: () -> Unit): () -> Unit {
    val context = LocalContext.current
    val granted by rememberUpdatedState(onGranted)
    val request = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) { allowed ->
        if (allowed) {
            granted()
        }
    }
    return remember(context, request) {
        {
            val allowed = ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO)
            if (allowed == PackageManager.PERMISSION_GRANTED) {
                granted()
            } else {
                request.launch(Manifest.permission.RECORD_AUDIO)
            }
        }
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
    messages: List<ChatMessage> = emptyList(),
    isWaitingForReply: Boolean = false,
    quickReplyType: QuickReplyType = QuickReplyType.Modal,
    quickReplies: List<MessageButton> = emptyList(),
    quickRepliesMessageId: Long? = null,
    onQuickReply: (String) -> Unit = {},
    avatar: (@Composable () -> Unit)? = null,
    onBack: (() -> Unit)? = null,
    hideVoiceButton: Boolean = false,
    recording: () -> VoiceRecording? = { null },
    onStartRecording: () -> Unit = {},
    onCancelRecording: () -> Unit = {},
    playback: () -> VoicePlayback? = { null },
    onVoiceMessageToggled: (ChatMessage) -> Unit = {},
) {
    val inline = quickReplyType == QuickReplyType.Inline
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
                messages = messages,
                isWaitingForReply = isWaitingForReply,
                quickRepliesMessageId = quickRepliesMessageId.takeIf { inline },
                onQuickReply = onQuickReply,
                playback = playback,
                onVoiceMessageToggled = onVoiceMessageToggled,
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
            )
            if (!inline) {
                ChatQuickReplies(replies = quickReplies, onReplyClick = onQuickReply)
            }
            ChatFooter(
                text = text,
                onTextChange = onTextChange,
                onSend = onSend,
                hideVoiceButton = hideVoiceButton,
                recording = recording,
                onStartRecording = onStartRecording,
                onCancelRecording = onCancelRecording,
            )
        }
    }
}

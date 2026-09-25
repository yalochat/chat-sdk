// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.data.repositories.voice.VoiceRecording
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import ai.yalo.chat.sdk.ui.voice.VoiceRecordingBar
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp

internal const val CHAT_FOOTER_TAG: String = "yalo-chat-footer"
internal const val CHAT_INPUT_TAG: String = "yalo-chat-input"
internal const val CHAT_SEND_BUTTON_TAG: String = "yalo-chat-send-button"

/**
 * The message input and the one button beside it.
 *
 * The button is whatever there is to do next: the microphone while there is
 * nothing to send, and send once there is something, whether that is typed text
 * or a recording. With [hideVoiceButton] on there is no microphone at all, so
 * the button is always send and is simply disabled while nothing has been
 * typed.
 *
 * [recording] is a lambda so that a recording moving sixteen times a second
 * redraws the waveform rather than the footer. Whether one is running at all is
 * derived from it, which is the only thing here that changes what is drawn.
 */
@Composable
internal fun ChatFooter(
    text: String,
    onTextChange: (String) -> Unit,
    onSend: () -> Unit,
    modifier: Modifier = Modifier,
    hideVoiceButton: Boolean = false,
    recording: () -> VoiceRecording? = { null },
    onStartRecording: () -> Unit = {},
    onCancelRecording: () -> Unit = {},
) {
    val isRecording: Boolean by remember(recording) {
        derivedStateOf { recording() != null }
    }
    val elapsedMillis: () -> Long = remember(recording) {
        { recording()?.elapsedMillis ?: 0L }
    }
    val amplitudes: () -> List<Float> = remember(recording) {
        { recording()?.amplitudes.orEmpty() }
    }
    val canSend = isRecording || text.isNotBlank()
    val showsSend = canSend || hideVoiceButton
    val theme = currentChatTheme
    Surface(
        modifier = modifier
            .fillMaxWidth()
            .testTag(CHAT_FOOTER_TAG),
        color = theme.footerBackground,
        contentColor = theme.onFooterBackground,
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            if (isRecording) {
                VoiceRecordingBar(
                    elapsedMillis = elapsedMillis,
                    amplitudes = amplitudes,
                    onCancel = onCancelRecording,
                    modifier = Modifier.weight(1f),
                )
            } else {
                OutlinedTextField(
                    value = text,
                    onValueChange = onTextChange,
                    modifier = Modifier
                        .weight(1f)
                        .testTag(CHAT_INPUT_TAG),
                    placeholder = {
                        Text(text = stringResource(R.string.yalo_chat_input_placeholder))
                    },
                    maxLines = 4,
                    shape = theme.inputShape,
                    keyboardOptions = KeyboardOptions(imeAction = ImeAction.Send),
                    keyboardActions = KeyboardActions(
                        onSend = {
                            if (canSend) {
                                onSend()
                            }
                        },
                    ),
                )
            }
            FilledIconButton(
                onClick = {
                    if (showsSend) {
                        onSend()
                    } else {
                        onStartRecording()
                    }
                },
                modifier = Modifier
                    .padding(bottom = 4.dp)
                    .testTag(CHAT_SEND_BUTTON_TAG),
                enabled = canSend || !showsSend,
            ) {
                // The button offers to record until there is something to send,
                // then turns into the send button.
                AnimatedContent(
                    targetState = showsSend,
                    transitionSpec = {
                        (fadeIn() + scaleIn()) togetherWith (fadeOut() + scaleOut())
                    },
                    label = "yalo-chat-send-button-icon",
                ) { sending ->
                    if (sending) {
                        Icon(
                            painter = painterResource(R.drawable.yalo_chat_ic_send),
                            contentDescription = stringResource(R.string.yalo_chat_send_button_description),
                        )
                    } else {
                        Icon(
                            painter = painterResource(R.drawable.yalo_chat_ic_mic),
                            contentDescription = stringResource(R.string.yalo_chat_mic_button_description),
                        )
                    }
                }
            }
        }
    }
}

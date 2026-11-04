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
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.input.TextFieldLineLimits
import androidx.compose.foundation.text.input.TextFieldState
import androidx.compose.foundation.text.input.rememberTextFieldState
import androidx.compose.foundation.text.input.setTextAndPlaceCursorAtEnd
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.takeOrElse
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp

internal const val CHAT_FOOTER_TAG: String = "yalo-chat-footer"
internal const val CHAT_INPUT_TAG: String = "yalo-chat-input"
internal const val CHAT_SEND_BUTTON_TAG: String = "yalo-chat-send-button"
internal const val CHAT_ATTACHMENT_BUTTON_TAG: String = "yalo-chat-attachment-button"
internal const val CHAT_INPUT_BOX_TAG: String = "yalo-chat-input-box"

/** The same hairline an outlined text field draws, so the input keeps its shape. */
private val INPUT_BORDER_WIDTH = 1.dp

/** How many lines the input grows to before what is typed scrolls inside it. */
internal const val INPUT_MAX_LINES: Int = 4

private val SCROLLBAR_WIDTH = 3.dp
private val SCROLLBAR_END_INSET = 4.dp
private val SCROLLBAR_VERTICAL_INSET = 10.dp
private val SCROLLBAR_MIN_THUMB = 16.dp

/**
 * The message input and the buttons around it.
 *
 * The button after the input is whatever there is to do next: the microphone
 * while there is nothing to send, and send once there is something, whether
 * that is typed text or a recording. With [hideVoiceButton] on there is no
 * microphone at all, so the button is always send and is simply disabled while
 * nothing has been typed.
 *
 * The plus picks a picture to send. It sits inside the outline with the place
 * text is typed, so the two read as one input, and is left out with
 * [hideAttachmentButton] on. It goes while a recording is running, because
 * there is no input to put a picture beside.
 *
 * The input grows with what is typed up to [INPUT_MAX_LINES] lines. Past that
 * the text scrolls inside it, and a thin thumb on its trailing edge shows where
 * in the text the person is, the way the web SDK's input does.
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
    hideAttachmentButton: Boolean = false,
    onPickImage: () -> Unit = {},
    recording: () -> VoiceRecording? = { null },
    onStartRecording: () -> Unit = {},
    onCancelRecording: () -> Unit = {},
    inputScrollState: ScrollState = rememberScrollState(),
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
    val fieldState = rememberSyncedTextFieldState(text, onTextChange)
    val scrollState = inputScrollState
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
                // The outline is drawn around the field and the plus together
                // rather than by the field, so the two read as one input. The
                // field keeps an outline of its own that is transparent until
                // somebody asks for the two to be told apart.
                Row(
                    modifier = Modifier
                        .weight(1f)
                        .background(color = theme.inputBackground, shape = theme.inputShape)
                        .border(
                            width = INPUT_BORDER_WIDTH,
                            color = theme.inputBorderColor,
                            shape = theme.inputShape,
                        )
                        .testTag(CHAT_INPUT_BOX_TAG),
                    verticalAlignment = Alignment.Bottom,
                ) {
                    OutlinedTextField(
                        state = fieldState,
                        modifier = Modifier
                            .weight(1f)
                            .verticalScrollbar(
                                scrollState = scrollState,
                                color = theme.inputScrollbarColor.takeOrElse {
                                    theme.inputBorderColor
                                },
                            )
                            .testTag(CHAT_INPUT_TAG),
                        placeholder = {
                            Text(text = stringResource(R.string.yalo_chat_input_placeholder))
                        },
                        lineLimits = TextFieldLineLimits.MultiLine(
                            minHeightInLines = 1,
                            maxHeightInLines = INPUT_MAX_LINES,
                        ),
                        scrollState = scrollState,
                        shape = theme.inputShape,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = theme.inputFieldBorderColor,
                            unfocusedBorderColor = theme.inputFieldBorderColor,
                            disabledBorderColor = theme.inputFieldBorderColor,
                            errorBorderColor = theme.inputFieldBorderColor,
                        ),
                        keyboardOptions = KeyboardOptions(imeAction = ImeAction.Send),
                        onKeyboardAction = {
                            if (canSend) {
                                onSend()
                            }
                        },
                    )
                    if (!hideAttachmentButton) {
                        IconButton(
                            onClick = onPickImage,
                            modifier = Modifier
                                .padding(bottom = 4.dp, end = 4.dp)
                                .testTag(CHAT_ATTACHMENT_BUTTON_TAG),
                        ) {
                            Icon(
                                painter = painterResource(R.drawable.yalo_chat_ic_add),
                                contentDescription = stringResource(
                                    R.string.yalo_chat_attachment_button_description,
                                ),
                            )
                        }
                    }
                }
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
                colors = IconButtonDefaults.filledIconButtonColors(
                    containerColor = theme.sendButtonBackground,
                    contentColor = theme.onSendButtonBackground,
                ),
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

/**
 * The field's own state, kept in step with the [text] the caller holds.
 *
 * What is typed goes out through [onTextChange]. A [text] the caller changes
 * on its own, such as the draft cleared after a send, is put back in the field
 * with the cursor at its end. A [text] that is only the echo of something the
 * field already reported is left alone, so a caller a beat behind cannot undo
 * what was typed since.
 */
@Composable
private fun rememberSyncedTextFieldState(
    text: String,
    onTextChange: (String) -> Unit,
): TextFieldState {
    val state = rememberTextFieldState(initialText = text)
    val lastReported = remember { arrayOf(text) }
    val currentText by rememberUpdatedState(text)
    val currentOnTextChange by rememberUpdatedState(onTextChange)
    LaunchedEffect(state) {
        snapshotFlow { state.text.toString() }.collect { value ->
            if (value != currentText) {
                lastReported[0] = value
                currentOnTextChange(value)
            }
        }
    }
    LaunchedEffect(text) {
        if (text != lastReported[0] && text != state.text.toString()) {
            state.setTextAndPlaceCursorAtEnd(text)
        }
        lastReported[0] = text
    }
    return state
}

/**
 * A thin thumb on the trailing edge showing which part of a scrolled text is in
 * view. Nothing is drawn while everything fits.
 */
private fun Modifier.verticalScrollbar(scrollState: ScrollState, color: Color): Modifier =
    drawWithContent {
        drawContent()
        val maxScroll = scrollState.maxValue
        if (maxScroll <= 0 || maxScroll == Int.MAX_VALUE) return@drawWithContent
        val trackTop = SCROLLBAR_VERTICAL_INSET.toPx()
        val trackHeight = size.height - trackTop * 2
        if (trackHeight <= 0f) return@drawWithContent
        val visibleFraction = size.height / (size.height + maxScroll)
        val thumbHeight = (trackHeight * visibleFraction)
            .coerceIn(SCROLLBAR_MIN_THUMB.toPx().coerceAtMost(trackHeight), trackHeight)
        val thumbTop = trackTop +
            (trackHeight - thumbHeight) * (scrollState.value.toFloat() / maxScroll)
        val width = SCROLLBAR_WIDTH.toPx()
        val endInset = SCROLLBAR_END_INSET.toPx()
        val thumbLeft = if (layoutDirection == LayoutDirection.Rtl) {
            endInset
        } else {
            size.width - endInset - width
        }
        drawRoundRect(
            color = color,
            topLeft = Offset(thumbLeft, thumbTop),
            size = Size(width, thumbHeight),
            cornerRadius = CornerRadius(width / 2),
        )
    }

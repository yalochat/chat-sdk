// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.voice

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

internal const val CHAT_RECORDING_BAR_TAG: String = "yalo-chat-recording-bar"
internal const val CHAT_RECORDING_TIMER_TAG: String = "yalo-chat-recording-timer"
internal const val CHAT_CANCEL_RECORDING_TAG: String = "yalo-chat-cancel-recording"

/** Tall enough for a waveform to say something, short enough to sit in the input. */
private val WAVEFORM_HEIGHT = 24.dp

/** Room for two digits either side of the colon, so the waveform does not shift. */
private val TIMER_WIDTH = 44.dp

/** The same hairline an outlined text field draws, so the input keeps its shape. */
private val INPUT_BORDER_WIDTH = 1.dp

/**
 * What the message input turns into while a voice note is being recorded.
 *
 * How long it has been running sits on the left and the waveform fills the rest,
 * so the two things somebody watches while speaking are the two things there.
 * The cross throws the recording away. Sending it is the footer's own button,
 * which is where sending always is.
 *
 * [elapsedMillis] and [amplitudes] are lambdas rather than values because they
 * change many times a second, and only the timer and the waveform have any
 * business being redrawn that often.
 */
@Composable
internal fun VoiceRecordingBar(
    elapsedMillis: () -> Long,
    amplitudes: () -> List<Float>,
    onCancel: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val theme = currentChatTheme
    Surface(
        modifier = modifier.testTag(CHAT_RECORDING_BAR_TAG),
        shape = theme.inputShape,
        color = theme.footerBackground,
        contentColor = theme.onFooterBackground,
        border = BorderStroke(INPUT_BORDER_WIDTH, theme.inputBorderColor),
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            ElapsedTime(elapsedMillis = elapsedMillis)
            VoiceWaveform(
                amplitudes = amplitudes,
                modifier = Modifier
                    .weight(1f)
                    .height(WAVEFORM_HEIGHT),
            )
            IconButton(
                onClick = onCancel,
                modifier = Modifier
                    .size(32.dp)
                    .testTag(CHAT_CANCEL_RECORDING_TAG),
            ) {
                Icon(
                    painter = painterResource(R.drawable.yalo_chat_ic_close),
                    contentDescription = stringResource(R.string.yalo_chat_cancel_recording_description),
                )
            }
        }
    }
}

/**
 * How long the recording has been running.
 *
 * On its own so that reading the clock redraws the number and nothing else.
 */
@Composable
private fun ElapsedTime(elapsedMillis: () -> Long) {
    Text(
        text = formatDuration(elapsedMillis()),
        modifier = Modifier
            .width(TIMER_WIDTH)
            .testTag(CHAT_RECORDING_TIMER_TAG),
        style = MaterialTheme.typography.bodyMedium,
        textAlign = TextAlign.Start,
    )
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.voice

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.data.repositories.voice.VoicePlayback
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.ui.messages.UnsupportedMessageBody
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp

internal const val CHAT_VOICE_MESSAGE_TAG: String = "yalo-chat-voice-message"
internal const val CHAT_VOICE_PLAY_BUTTON_TAG: String = "yalo-chat-voice-play-button"

/** Wide enough for a waveform to be worth reading, narrow enough to stay a bubble. */
private val WAVEFORM_WIDTH = 140.dp

private val WAVEFORM_HEIGHT = 24.dp

/**
 * A voice note in the conversation: play or pause it, the shape of it, and how
 * long it runs.
 *
 * The number on the right is how far in playback has got while the note is
 * being listened to, and how long the whole note is the rest of the time, so a
 * note nobody has played still says what it costs to listen to.
 *
 * [playback] is a lambda because it moves ten times a second while a note
 * plays. Everything that reads it is inside this row, so the conversation
 * around it is left alone.
 */
@Composable
internal fun VoiceMessageBody(
    message: ChatMessage,
    playback: () -> VoicePlayback?,
    onToggle: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val note = message.voice
    if (note == null) {
        // The channel named a voice message but sent nothing to play, which is
        // a hole in the conversation rather than something to draw silence for.
        UnsupportedMessageBody(modifier = modifier)
        return
    }
    val current = playback()?.takeIf { playing -> playing.messageId == message.id }
    val isPlaying = current?.isPlaying == true
    // A note the channel sent says how long it is before it has been loaded, so
    // its own length is what the bar is measured against until then.
    val length = current?.durationMillis?.takeIf { it > 0 } ?: note.durationMillis
    Row(
        modifier = modifier.testTag(CHAT_VOICE_MESSAGE_TAG),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        IconButton(
            onClick = onToggle,
            modifier = Modifier
                .size(36.dp)
                .testTag(CHAT_VOICE_PLAY_BUTTON_TAG),
        ) {
            Icon(
                painter = painterResource(
                    if (isPlaying) R.drawable.yalo_chat_ic_pause else R.drawable.yalo_chat_ic_play,
                ),
                contentDescription = stringResource(
                    if (isPlaying) {
                        R.string.yalo_chat_pause_voice_message_description
                    } else {
                        R.string.yalo_chat_play_voice_message_description
                    },
                ),
            )
        }
        VoiceWaveform(
            amplitudes = { note.amplitudes },
            modifier = Modifier
                .width(WAVEFORM_WIDTH)
                .height(WAVEFORM_HEIGHT),
            progress = { playedShare(playback(), message.id, length) },
        )
        Text(
            text = formatDuration(current?.positionMillis?.takeIf { isPlaying } ?: length),
            style = MaterialTheme.typography.labelMedium,
        )
    }
}

/**
 * How much of the note of [messageId] has been listened to, from zero to one.
 *
 * Another note playing, or none at all, leaves this note untouched rather than
 * borrowing the other one's position.
 */
internal fun playedShare(playback: VoicePlayback?, messageId: Long?, durationMillis: Long): Float {
    if (playback == null || playback.messageId != messageId || durationMillis <= 0) {
        return 0f
    }
    return (playback.positionMillis.toFloat() / durationMillis).coerceIn(0f, 1f)
}

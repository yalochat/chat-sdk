// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.domain.model.ChatMessage

// Port of flutter-sdk/lib/src/ui/chat/widgets/message_list/user_voice_message.dart
//
// Renders inside MessageItem for MessageType.Voice messages.
// Shows a play/pause button and a waveform preview of the recorded amplitudes.
// onPlay / onStop are dispatched to AudioViewModel by MessageItem's caller (MessageList / ChatScreen).
@Composable
internal fun AudioMessageItem(
    message: ChatMessage,
    playingMessage: ChatMessage?,
    onPlay: (ChatMessage) -> Unit,
    onStop: () -> Unit,
) {
    val isPlaying = playingMessage?.id != null && playingMessage.id == message.id
    Row(verticalAlignment = Alignment.CenterVertically) {
        IconButton(
            onClick = { if (isPlaying) onStop() else onPlay(message) },
        ) {
            Icon(
                imageVector = if (isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow,
                contentDescription = if (isPlaying) "Pause voice message" else "Play voice message",
            )
        }
        Waveform(
            amplitudes = message.amplitudes,
            modifier = Modifier
                .width(120.dp)
                .height(40.dp),
        )
    }
}

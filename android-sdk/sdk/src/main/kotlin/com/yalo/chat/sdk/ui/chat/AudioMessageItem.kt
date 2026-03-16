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

// Renders a voice message bubble: play/pause button + waveform preview of the recorded amplitudes.
// onPlay / onStop are owned by AudioViewModel; callers (MessageList / ChatScreen) thread them down.
@Composable
internal fun AudioMessageItem(
    message: ChatMessage,
    playingMessage: ChatMessage?,
    onPlay: (ChatMessage) -> Unit,
    onStop: () -> Unit,
) {
    // Match on local id first (user-sent messages); fall back to wiId for server messages
    // that may not yet have a local SQLite id assigned.
    val isPlaying = playingMessage != null && (
        (message.id != null && playingMessage.id == message.id) ||
        (message.wiId != null && playingMessage.wiId == message.wiId)
    )
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

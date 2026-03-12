// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.domain.model.AudioData

// Port of flutter-sdk/lib/src/ui/chat/widgets/chat_input/waveform_recorder.dart
//
// Replaces ChatInput while the user is recording a voice message.
// Layout: [Cancel] [Timer] [Waveform] [Send]
//   onCancel — discards the recording (dispatches CancelRecording; temp file is deleted)
//   onSend   — stops recording and inserts the voice message (dispatches StopRecording)
@Composable
internal fun WaveformRecorder(
    audioData: AudioData,
    onCancel: () -> Unit,
    onSend: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        IconButton(onClick = onCancel) {
            Icon(
                imageVector = Icons.Filled.Close,
                contentDescription = "Cancel recording",
            )
        }
        val totalSeconds = (audioData.durationMs / 1000).toInt()
        val minutes = totalSeconds / 60
        val seconds = totalSeconds % 60
        Text(
            text = "%02d:%02d".format(minutes, seconds),
            style = MaterialTheme.typography.bodyMedium,
        )
        Spacer(modifier = Modifier.width(8.dp))
        Waveform(
            amplitudes = audioData.amplitudes,
            modifier = Modifier
                .weight(1f)
                .height(40.dp),
        )
        IconButton(onClick = onSend) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.Send,
                contentDescription = "Send voice message",
            )
        }
    }
}

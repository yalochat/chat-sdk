// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.ui.chat.AudioViewModel.Companion.AMPLITUDE_DATA_POINTS
import com.yalo.chat.sdk.ui.chat.AudioViewModel.Companion.DEFAULT_AMPLITUDE

// Port of flutter-sdk/lib/src/ui/chat/view_models/audio/audio_state.dart
// AudioStatus mirrors Flutter's AudioStatus enum as a sealed class.
sealed class AudioStatus {
    data object Initial : AudioStatus()
    data object RecordingAudio : AudioStatus()
    data object PlayingAudio : AudioStatus()
    data object AudioPaused : AudioStatus()
    data object ErrorRecordingAudio : AudioStatus()
    data object ErrorStoppingRecording : AudioStatus()
    data object ErrorPlayingAudio : AudioStatus()
    data object ErrorStoppingAudio : AudioStatus()
}

data class AudioState(
    val audioData: AudioData = AudioData(
        amplitudes = List(AMPLITUDE_DATA_POINTS) { DEFAULT_AMPLITUDE },
        amplitudesPreview = List(AMPLITUDE_DATA_POINTS) { DEFAULT_AMPLITUDE },
    ),
    // Index drives the sliding-waveform animation, decremented on each amplitude tick.
    val amplitudeIndex: Int = AMPLITUDE_DATA_POINTS - 1,
    val isRecording: Boolean = false,
    val playingMessage: ChatMessage? = null,
    val audioStatus: AudioStatus = AudioStatus.Initial,
)

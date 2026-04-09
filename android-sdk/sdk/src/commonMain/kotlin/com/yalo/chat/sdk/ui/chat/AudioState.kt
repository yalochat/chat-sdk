// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ChatMessage

// Number of amplitude bars in the waveform visualisation.
internal const val AMPLITUDE_DATA_POINTS = 48
// Baseline dBFS amplitude shown before any recording begins (-30 dBFS ≈ very quiet).
internal const val DEFAULT_AMPLITUDE = -30.0

sealed class AudioStatus {
    data object Initial : AudioStatus()
    data object RecordingAudio : AudioStatus()
    data object PlayingAudio : AudioStatus()
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
    val playingMessage: ChatMessage? = null,
    val audioStatus: AudioStatus = AudioStatus.Initial,
)

// Derived convenience — avoids a redundant boolean field that could disagree with audioStatus.
val AudioState.isRecording: Boolean get() = audioStatus is AudioStatus.RecordingAudio

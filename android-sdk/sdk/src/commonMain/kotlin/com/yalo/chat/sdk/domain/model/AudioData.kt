// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of flutter-sdk/lib/src/domain/models/audio/audio_data.dart
// durationMs matches Flutter's duration field (milliseconds).
// amplitudesPreview is the compressed 48-point preview used for waveform display
// (called amplitudesFilePreview in Flutter).
data class AudioData(
    val fileName: String = "",
    val amplitudes: List<Double> = emptyList(),
    val amplitudesPreview: List<Double> = emptyList(),
    val durationMs: Long = 0L,
)

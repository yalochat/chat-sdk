// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// amplitudesPreview is the compressed 48-point preview used for waveform display.
data class AudioData(
    val fileName: String = "",
    val amplitudes: List<Double> = emptyList(),
    val amplitudesPreview: List<Double> = emptyList(),
    val durationMs: Long = 0L,
)

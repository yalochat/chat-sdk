// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.usecase

import kotlin.math.max

// Port of flutter-sdk/lib/src/domain/use_cases/audio/audio_processing_use_case.dart
//
// Receives a new amplitude point and re-compresses the waveform preview into a
// fixed-size window (amplitudeDataPoints bins). As recording grows beyond the bin
// count, older bins are merged by keeping the maximum value so no waveform data
// is lost — only compressed.
internal class AudioProcessingUseCase {

    // Port of AudioProcessingUseCase.compressWaveformForPreview():
    //   newPoint      — latest DBFS amplitude sample
    //   totalSamples  — total number of samples recorded so far (including newPoint)
    //   preview       — current compressed preview list (length == amplitudeDataPoints)
    // Returns a new preview list with newPoint incorporated.
    fun compressWaveformForPreview(
        newPoint: Double,
        totalSamples: Int,
        preview: List<Double>,
    ): List<Double> {
        val result = preview.toMutableList()
        val totalBins = preview.size
        if (totalSamples <= totalBins) {
            // Still filling the window — place sample directly into its slot.
            result[totalSamples - 1] = newPoint
        } else {
            // Window full — shift left and compress: the bin at targetBin absorbs
            // the maximum of itself and its right neighbour before everything shifts.
            val targetBin = totalSamples % totalBins
            for (i in targetBin until result.size - 1) {
                result[i] = if (i == targetBin) max(result[i], result[i + 1]) else result[i + 1]
            }
            result[result.size - 1] = newPoint
        }
        return result
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.AudioData
import kotlinx.coroutines.flow.Flow

// Port of flutter-sdk/lib/src/data/repositories/audio/audio_repository.dart
// Phase 2 M4: implemented by AudioRepositoryLocal (MediaRecorder / MediaPlayer).
interface AudioRepository {

    companion object {
        // Polling interval for amplitudeFlow() — shared with AudioViewModel so that the
        // duration counter incremented per tick stays in sync with the actual tick rate.
        const val RECORD_TICK_MS = 25L
    }
    // Start recording — returns the output file path on success.
    suspend fun startRecording(): Result<String>

    // Stop recording — returns AudioData with fileName and durationMs.
    suspend fun stopRecording(): Result<AudioData>

    // FDE-61: amplitude stream polled every RECORD_TICK_MS during active recording (DBFS values,
    // matching Flutter). Only emits while recording — callers should subscribe after StartRecording.
    // buffer(Channel.UNLIMITED) is intentional: duration is tracked by counting emitted samples,
    // so no samples must be dropped (conflate() would undercount duration).
    fun amplitudeFlow(): Flow<Double>

    // Play audio at the given local file path.
    suspend fun play(fileName: String): Result<Unit>

    // Stop current playback.
    suspend fun stop(): Result<Unit>

    // Emits Unit each time playback completes naturally (not on stop()).
    fun onPlaybackCompleted(): Flow<Unit>

    // Release MediaRecorder and MediaPlayer resources.
    // Called from AudioViewModel.onCleared() to prevent resource leaks.
    fun release()
}

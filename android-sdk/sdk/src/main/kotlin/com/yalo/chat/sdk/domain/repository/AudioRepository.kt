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
    // FDE-60: start recording — returns the output file path on success.
    suspend fun startRecording(): Result<String>

    // FDE-60: stop recording — returns AudioData with fileName and durationMs.
    suspend fun stopRecording(): Result<AudioData>

    // FDE-61: amplitude stream polled every 25ms during recording (DBFS values, matching Flutter).
    // Emits -160.0 when not recording (safe to collect at any time).
    fun amplitudeFlow(): Flow<Double>

    // FDE-62: play audio at the given local file path.
    suspend fun play(fileName: String): Result<Unit>

    // FDE-62: pause/stop current playback.
    suspend fun stop(): Result<Unit>

    // FDE-62: emits Unit each time playback completes naturally (not on stop()).
    fun onPlaybackCompleted(): Flow<Unit>

    // FDE-60 / FDE-62: release MediaRecorder and MediaPlayer resources.
    // Called from AudioViewModel.onCleared() and on lifecycle ON_STOP.
    fun release()
}

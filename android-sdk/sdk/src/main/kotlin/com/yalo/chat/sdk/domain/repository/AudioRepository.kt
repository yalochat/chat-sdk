// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.AudioData
import kotlinx.coroutines.flow.Flow

// Port of flutter-sdk/lib/src/data/repositories/audio/audio_repository.dart
// Phase 1: implemented by FakeAudioRepository (no-ops).
// Phase 2: implemented by AudioRepositoryLocal (MediaRecorder / MediaPlayer).
interface AudioRepository {
    suspend fun startRecording(): Result<String>        // returns file path
    suspend fun stopRecording(): Result<AudioData>
    suspend fun play(fileName: String): Result<Unit>
    suspend fun stop(): Result<Unit>
    fun amplitudeFlow(): Flow<Int>                      // ~25ms intervals during recording
}

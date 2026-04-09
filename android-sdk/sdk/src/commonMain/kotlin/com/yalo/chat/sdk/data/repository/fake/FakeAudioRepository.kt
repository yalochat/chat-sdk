// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.repository.AudioRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.flow

// Test double for AudioRepository.
// amplitudeValues: sequence emitted by amplitudeFlow() — defaults to three -30.0 samples.
// recordingError / playbackError: if set, the corresponding operation returns Result.Error.
// recordedAudioData: returned by stopRecording() on success.
class FakeAudioRepository(
    private val amplitudeValues: List<Double> = listOf(-30.0, -30.0, -30.0),
    private val recordingError: Exception? = null,
    private val playbackError: Exception? = null,
    private val recordedAudioData: AudioData = AudioData(fileName = "fake_audio.m4a", durationMs = 1000L),
) : AudioRepository {

    var released = false
        private set

    private val _playbackCompleted = MutableSharedFlow<Unit>(extraBufferCapacity = 1)

    // Trigger playback completion from tests.
    suspend fun emitPlaybackCompleted() = _playbackCompleted.emit(Unit)

    override suspend fun startRecording(): Result<String> =
        if (recordingError != null) Result.Error(recordingError)
        else Result.Ok(recordedAudioData.fileName)

    override suspend fun stopRecording(): Result<AudioData> =
        if (recordingError != null) Result.Error(recordingError)
        else Result.Ok(recordedAudioData)

    override fun amplitudeFlow(): Flow<Double> = flow {
        for (value in amplitudeValues) emit(value)
    }

    override suspend fun play(fileName: String): Result<Unit> =
        if (playbackError != null) Result.Error(playbackError)
        else Result.Ok(Unit)

    override suspend fun stop(): Result<Unit> = Result.Ok(Unit)

    override fun onPlaybackCompleted(): Flow<Unit> = _playbackCompleted.asSharedFlow()

    override fun release() {
        released = true
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.repository.AudioRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow

// Phase 1 stub — all operations no-op. amplitudeFlow() completes immediately.
// Replaced in Phase 2 by AudioRepositoryLocal (MediaRecorder/MediaPlayer, FDE-60).
class FakeAudioRepository : AudioRepository {

    override suspend fun startRecording(): Result<String> =
        Result.Ok("fake_audio.mp4")

    override suspend fun stopRecording(): Result<AudioData> =
        Result.Ok(AudioData(fileName = "fake_audio.mp4", durationMs = 0L))

    override suspend fun play(fileName: String): Result<Unit> =
        Result.Ok(Unit)

    override suspend fun stop(): Result<Unit> =
        Result.Ok(Unit)

    override fun amplitudeFlow(): Flow<Int> = emptyFlow()
}

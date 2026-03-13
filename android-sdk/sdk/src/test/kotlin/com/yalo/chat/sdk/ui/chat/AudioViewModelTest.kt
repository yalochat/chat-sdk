// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.repository.fake.FakeAudioRepository
import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.AudioRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class AudioViewModelTest {

    private val dispatcher = UnconfinedTestDispatcher()

    @BeforeTest
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterTest
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun voiceMessage(fileName: String = "audio.m4a") = ChatMessage(
        type = MessageType.Voice,
        role = MessageRole.USER,
        fileName = fileName,
        timestamp = 0L,
    )

    private fun viewModel(repo: AudioRepository = FakeAudioRepository()) =
        AudioViewModel(repo)

    // ── Initial state ─────────────────────────────────────────────────────────

    @Test
    fun `initial state is not recording with Initial status`() {
        val vm = viewModel()
        assertIs<AudioStatus.Initial>(vm.state.value.audioStatus)
        assertTrue(!vm.state.value.isRecording)
        assertNull(vm.state.value.playingMessage)
        assertEquals(AudioViewModel.AMPLITUDE_DATA_POINTS, vm.state.value.audioData.amplitudes.size)
        assertEquals(AudioViewModel.AMPLITUDE_DATA_POINTS, vm.state.value.audioData.amplitudesPreview.size)
    }

    // ── StartRecording ────────────────────────────────────────────────────────

    @Test
    fun `StartRecording transitions to RecordingAudio status`() = runTest {
        val vm = viewModel()

        vm.handleEvent(AudioEvent.StartRecording)
        advanceUntilIdle()

        assertIs<AudioStatus.RecordingAudio>(vm.state.value.audioStatus)
        assertTrue(vm.state.value.isRecording)
    }

    @Test
    fun `StartRecording resets amplitudes to AMPLITUDE_DATA_POINTS default values`() = runTest {
        val vm = viewModel()

        vm.handleEvent(AudioEvent.StartRecording)
        advanceUntilIdle()

        assertEquals(AudioViewModel.AMPLITUDE_DATA_POINTS, vm.state.value.audioData.amplitudes.size)
        assertTrue(vm.state.value.audioData.amplitudes.all { it == AudioViewModel.DEFAULT_AMPLITUDE })
    }

    @Test
    fun `StartRecording failure sets ErrorRecordingAudio status`() = runTest {
        val vm = viewModel(FakeAudioRepository(recordingError = RuntimeException("mic not found")))

        vm.handleEvent(AudioEvent.StartRecording)
        advanceUntilIdle()

        assertIs<AudioStatus.ErrorRecordingAudio>(vm.state.value.audioStatus)
        assertTrue(!vm.state.value.isRecording)
    }

    // ── Amplitude streaming ───────────────────────────────────────────────────

    @Test
    fun `amplitude samples advance the live amplitudes list`() = runTest {
        val samples = listOf(-10.0, -15.0, -20.0)
        val vm = viewModel(FakeAudioRepository(amplitudeValues = samples))

        vm.handleEvent(AudioEvent.StartRecording)
        advanceUntilIdle()

        assertEquals(-20.0, vm.state.value.audioData.amplitudes.last())
    }

    @Test
    fun `amplitude streaming increments duration by RECORD_TICK_MS per sample`() = runTest {
        val samples = listOf(-10.0, -15.0, -20.0)
        val vm = viewModel(FakeAudioRepository(amplitudeValues = samples))

        vm.handleEvent(AudioEvent.StartRecording)
        advanceUntilIdle()

        assertEquals(samples.size * AudioRepository.RECORD_TICK_MS, vm.state.value.audioData.durationMs)
    }

    // ── StopRecording ─────────────────────────────────────────────────────────

    @Test
    fun `StopRecording transitions to Initial status`() = runTest {
        val vm = viewModel()

        vm.handleEvent(AudioEvent.StartRecording)
        vm.handleEvent(AudioEvent.StopRecording)
        advanceUntilIdle()

        assertIs<AudioStatus.Initial>(vm.state.value.audioStatus)
        assertTrue(!vm.state.value.isRecording)
    }

    @Test
    fun `StopRecording carries duration from repository result`() = runTest {
        val audioData = AudioData(fileName = "fake.m4a", durationMs = 3000L)
        val vm = viewModel(FakeAudioRepository(recordedAudioData = audioData))

        vm.handleEvent(AudioEvent.StartRecording)
        vm.handleEvent(AudioEvent.StopRecording)
        advanceUntilIdle()

        assertEquals(3000L, vm.state.value.audioData.durationMs)
    }

    @Test
    fun `StopRecording failure sets ErrorStoppingRecording status`() = runTest {
        val repo = object : AudioRepository {
            override suspend fun startRecording(): Result<String> = Result.Ok("fake.m4a")
            override suspend fun stopRecording(): Result<AudioData> =
                Result.Error(RuntimeException("stop failed"))
            override fun amplitudeFlow(): Flow<Double> = emptyFlow()
            override suspend fun play(fileName: String): Result<Unit> = Result.Ok(Unit)
            override suspend fun stop(): Result<Unit> = Result.Ok(Unit)
            override fun onPlaybackCompleted(): Flow<Unit> = emptyFlow()
            override fun release() {}
        }
        val vm = AudioViewModel(repo)

        vm.handleEvent(AudioEvent.StartRecording)
        vm.handleEvent(AudioEvent.StopRecording)
        advanceUntilIdle()

        assertIs<AudioStatus.ErrorStoppingRecording>(vm.state.value.audioStatus)
        // isRecording must be false even on error so ChatScreen stops showing WaveformRecorder.
        assertTrue(!vm.state.value.isRecording)
    }

    // ── CancelRecording ───────────────────────────────────────────────────────

    @Test
    fun `CancelRecording transitions to Initial status with empty audioData`() = runTest {
        val vm = viewModel(FakeAudioRepository(
            recordedAudioData = AudioData(fileName = "fake.m4a", durationMs = 1000L),
        ))

        vm.handleEvent(AudioEvent.StartRecording)
        advanceUntilIdle()
        assertIs<AudioStatus.RecordingAudio>(vm.state.value.audioStatus)

        vm.handleEvent(AudioEvent.CancelRecording)
        advanceUntilIdle()

        assertIs<AudioStatus.Initial>(vm.state.value.audioStatus)
        assertTrue(!vm.state.value.isRecording)
        // fileName must be empty so SendVoiceMessage guard rejects it.
        assertTrue(vm.state.value.audioData.fileName.isEmpty())
    }

    @Test
    fun `CancelRecording resets amplitudes to defaults`() = runTest {
        val samples = listOf(-10.0, -15.0, -20.0)
        val vm = viewModel(FakeAudioRepository(amplitudeValues = samples))

        vm.handleEvent(AudioEvent.StartRecording)
        advanceUntilIdle()

        vm.handleEvent(AudioEvent.CancelRecording)
        advanceUntilIdle()

        assertTrue(vm.state.value.audioData.amplitudes.all { it == AudioViewModel.DEFAULT_AMPLITUDE })
    }

    // ── Play ──────────────────────────────────────────────────────────────────

    @Test
    fun `Play sets playingMessage and status to PlayingAudio`() = runTest {
        val message = voiceMessage()
        val vm = viewModel()

        vm.handleEvent(AudioEvent.Play(message))
        advanceUntilIdle()

        assertEquals(message, vm.state.value.playingMessage)
        assertIs<AudioStatus.PlayingAudio>(vm.state.value.audioStatus)
    }

    @Test
    fun `Play with non-Voice message type is a no-op`() = runTest {
        val message = ChatMessage(
            type = MessageType.Text,
            role = MessageRole.USER,
            content = "hello",
            timestamp = 0L,
        )
        val vm = viewModel()

        vm.handleEvent(AudioEvent.Play(message))
        advanceUntilIdle()

        assertNull(vm.state.value.playingMessage)
        assertIs<AudioStatus.Initial>(vm.state.value.audioStatus)
    }

    @Test
    fun `Play with null fileName is a no-op`() = runTest {
        val message = ChatMessage(
            type = MessageType.Voice,
            role = MessageRole.USER,
            fileName = null,
            timestamp = 0L,
        )
        val vm = viewModel()

        vm.handleEvent(AudioEvent.Play(message))
        advanceUntilIdle()

        assertNull(vm.state.value.playingMessage)
    }

    @Test
    fun `Play failure sets ErrorPlayingAudio status`() = runTest {
        val message = voiceMessage()
        val vm = viewModel(FakeAudioRepository(playbackError = RuntimeException("codec error")))

        vm.handleEvent(AudioEvent.Play(message))
        advanceUntilIdle()

        assertNull(vm.state.value.playingMessage)
        assertIs<AudioStatus.ErrorPlayingAudio>(vm.state.value.audioStatus)
    }

    // ── Stop ──────────────────────────────────────────────────────────────────

    @Test
    fun `Stop clears playingMessage and resets status to Initial`() = runTest {
        val message = voiceMessage()
        val vm = viewModel()

        vm.handleEvent(AudioEvent.Play(message))
        advanceUntilIdle()
        assertNotNull(vm.state.value.playingMessage)

        vm.handleEvent(AudioEvent.Stop)
        advanceUntilIdle()

        assertNull(vm.state.value.playingMessage)
        assertIs<AudioStatus.Initial>(vm.state.value.audioStatus)
    }

    // ── SubscribeToPlaybackCompletion ─────────────────────────────────────────

    @Test
    fun `SubscribeToPlaybackCompletion clears playingMessage when playback ends`() = runTest {
        val message = voiceMessage()
        val repo = FakeAudioRepository()
        val vm = AudioViewModel(repo)

        vm.handleEvent(AudioEvent.SubscribeToPlaybackCompletion)
        vm.handleEvent(AudioEvent.Play(message))
        advanceUntilIdle()
        assertNotNull(vm.state.value.playingMessage)

        repo.emitPlaybackCompleted()
        advanceUntilIdle()

        assertNull(vm.state.value.playingMessage)
        assertIs<AudioStatus.Initial>(vm.state.value.audioStatus)
    }

    // ── release ───────────────────────────────────────────────────────────────

    @Test
    fun `repository release is called when ViewModel is cleared`() {
        val repo = FakeAudioRepository()
        val vm = AudioViewModel(repo)

        // onCleared() is protected — invoke via reflection to simulate lifecycle clear
        // rather than calling repo.release() directly (which would make the test vacuous).
        val method = androidx.lifecycle.ViewModel::class.java.getDeclaredMethod("onCleared")
        method.isAccessible = true
        method.invoke(vm)

        assertTrue(repo.released)
    }
}

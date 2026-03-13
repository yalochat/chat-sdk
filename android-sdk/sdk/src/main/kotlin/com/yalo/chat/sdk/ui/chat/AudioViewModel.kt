// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.AudioRepository
import com.yalo.chat.sdk.domain.usecase.AudioProcessingUseCase
import java.io.File
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.withContext
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

// Port of flutter-sdk/lib/src/ui/chat/view_models/audio/audio_bloc.dart
// Manages recording, amplitude streaming, and playback lifecycle.
// AudioViewModel is separate from MessagesViewModel, mirroring the Flutter separation
// between AudioBloc and MessagesBloc.
internal class AudioViewModel(
    private val audioRepository: AudioRepository,
    private val audioProcessingUseCase: AudioProcessingUseCase = AudioProcessingUseCase(),
) : ViewModel() {

    companion object {
        // Tick rate is defined by AudioRepository — mirrored here for the duration counter.
        val RECORD_TICK_MS get() = AudioRepository.RECORD_TICK_MS
        const val AMPLITUDE_DATA_POINTS = 48
        const val DEFAULT_AMPLITUDE = -30.0
    }

    private val _state = MutableStateFlow(AudioState())
    val state: StateFlow<AudioState> = _state.asStateFlow()

    private var amplitudeJob: Job? = null
    private var completionJob: Job? = null

    fun handleEvent(event: AudioEvent) {
        when (event) {
            is AudioEvent.SubscribeToPlaybackCompletion -> subscribeToPlaybackCompletion()
            is AudioEvent.StartRecording -> startRecording()
            is AudioEvent.StopRecording -> stopRecording()
            is AudioEvent.CancelRecording -> cancelRecording()
            is AudioEvent.Play -> playAudio(event.message)
            is AudioEvent.Stop -> stopAudio()
        }
    }

    // ── FDE-62: playback completion subscription ──────────────────────────────

    // Port of AudioBloc._handleAudioCompletedSubscribe.
    // Idempotent — a second call cancels the previous job and re-subscribes.
    private fun subscribeToPlaybackCompletion() {
        completionJob?.cancel()
        completionJob = viewModelScope.launch {
            audioRepository.onPlaybackCompleted().collect {
                _state.update { s ->
                    s.copy(playingMessage = null, audioStatus = AudioStatus.Initial)
                }
            }
        }
    }

    // ── FDE-60: recording ─────────────────────────────────────────────────────

    // Port of AudioBloc._handleStartRecording.
    private fun startRecording() {
        viewModelScope.launch {
            when (val result = audioRepository.startRecording()) {
                is Result.Ok -> {
                    _state.update { s ->
                        s.copy(
                            audioStatus = AudioStatus.RecordingAudio,
                            audioData = AudioData(
                                fileName = result.result,
                                amplitudes = List(AMPLITUDE_DATA_POINTS) { DEFAULT_AMPLITUDE },
                                amplitudesPreview = List(AMPLITUDE_DATA_POINTS) { DEFAULT_AMPLITUDE },
                                durationMs = 0L,
                            ),
                            amplitudeIndex = AMPLITUDE_DATA_POINTS - 1,
                        )
                    }
                    subscribeToAmplitudes()
                }
                is Result.Error -> _state.update { s ->
                    s.copy(audioStatus = AudioStatus.ErrorRecordingAudio)
                }
            }
        }
    }

    // Port of AudioBloc._handleStopRecording.
    private fun stopRecording() {
        amplitudeJob?.cancel()
        amplitudeJob = null
        viewModelScope.launch {
            when (val result = audioRepository.stopRecording()) {
                is Result.Ok -> _state.update { s ->
                    s.copy(
                        audioStatus = AudioStatus.Initial,
                        // Carry duration from the repository result; amplitudes stay for SendVoiceMessage.
                        audioData = s.audioData.copy(durationMs = result.result.durationMs),
                    )
                }
                is Result.Error -> _state.update { s ->
                    s.copy(audioStatus = AudioStatus.ErrorStoppingRecording)
                }
            }
        }
    }

    // Discards the current recording: stops the recorder, deletes the temp file, and
    // resets state without triggering SendVoiceMessage (empty fileName acts as the guard).
    private fun cancelRecording() {
        amplitudeJob?.cancel()
        amplitudeJob = null
        val fileToDelete = _state.value.audioData.fileName
        // Reset UI state synchronously so ChatScreen immediately stops showing WaveformRecorder.
        _state.update { s ->
            s.copy(
                audioStatus = AudioStatus.Initial,
                audioData = AudioData(
                    amplitudes = List(AMPLITUDE_DATA_POINTS) { DEFAULT_AMPLITUDE },
                    amplitudesPreview = List(AMPLITUDE_DATA_POINTS) { DEFAULT_AMPLITUDE },
                ),
                amplitudeIndex = AMPLITUDE_DATA_POINTS - 1,
            )
        }
        // Async cleanup: stop the recorder and delete the temp file on IO.
        viewModelScope.launch {
            audioRepository.stopRecording() // result discarded
            if (fileToDelete.isNotEmpty()) {
                withContext(Dispatchers.IO) { File(fileToDelete).delete() }
            }
        }
    }

    // ── FDE-61: amplitude streaming ───────────────────────────────────────────

    // Port of AudioBloc._onAmplitudeSubscribe.
    // Runs while recording; each tick advances the sliding waveform window.
    private fun subscribeToAmplitudes() {
        amplitudeJob?.cancel()
        amplitudeJob = viewModelScope.launch {
            var totalSamples = 0
            audioRepository.amplitudeFlow().collect { amplitude ->
                totalSamples++
                val current = _state.value
                val maxPoints = current.audioData.amplitudes.size

                val updatedPreview = audioProcessingUseCase.compressWaveformForPreview(
                    newPoint = amplitude,
                    totalSamples = totalSamples,
                    preview = current.audioData.amplitudesPreview,
                )

                _state.update { s ->
                    s.copy(
                        audioData = s.audioData.copy(
                            amplitudes = s.audioData.amplitudes.drop(1) + amplitude,
                            amplitudesPreview = updatedPreview,
                            durationMs = s.audioData.durationMs + RECORD_TICK_MS,
                        ),
                        // Slide the waveform animation index.
                        amplitudeIndex = (s.amplitudeIndex - 1 + maxPoints) % maxPoints,
                    )
                }
            }
        }
    }

    // ── FDE-62: playback ──────────────────────────────────────────────────────

    // Port of AudioBloc._handlePlayAudio.
    private fun playAudio(message: ChatMessage) {
        if (message.type != MessageType.Voice || message.fileName.isNullOrEmpty()) return

        viewModelScope.launch {
            // Stop any currently playing message first.
            if (_state.value.playingMessage != null) {
                when (audioRepository.stop()) {
                    is Result.Ok -> _state.update { s ->
                        s.copy(playingMessage = null, audioStatus = AudioStatus.AudioPaused)
                    }
                    is Result.Error -> {
                        _state.update { s -> s.copy(audioStatus = AudioStatus.ErrorStoppingAudio) }
                        return@launch
                    }
                }
            }

            when (audioRepository.play(message.fileName)) {
                is Result.Ok -> _state.update { s ->
                    s.copy(
                        playingMessage = message,
                        audioStatus = AudioStatus.PlayingAudio,
                    )
                }
                is Result.Error -> _state.update { s ->
                    s.copy(audioStatus = AudioStatus.ErrorPlayingAudio)
                }
            }
        }
    }

    // Port of AudioBloc._handleStopAudio.
    private fun stopAudio() {
        viewModelScope.launch {
            when (audioRepository.stop()) {
                is Result.Ok -> _state.update { s ->
                    s.copy(playingMessage = null, audioStatus = AudioStatus.Initial)
                }
                is Result.Error -> _state.update { s ->
                    s.copy(audioStatus = AudioStatus.ErrorStoppingAudio)
                }
            }
        }
    }

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    override fun onCleared() {
        super.onCleared()
        audioRepository.release()
    }
}

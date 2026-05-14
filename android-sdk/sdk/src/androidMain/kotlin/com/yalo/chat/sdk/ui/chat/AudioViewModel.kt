// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.AudioRepository
import com.yalo.chat.sdk.domain.audio.WaveformCompressor
import java.io.File
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.withContext
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

// Manages recording, amplitude streaming, and playback lifecycle.
// Kept separate from MessagesViewModel so recording state (waveform, duration) is
// isolated from message list state — the same separation the Flutter SDK uses.
internal class AudioViewModel(
    private val audioRepository: AudioRepository,
    private val waveformCompressor: WaveformCompressor = WaveformCompressor(
        binCount = AMPLITUDE_DATA_POINTS,
        defaultValue = DEFAULT_AMPLITUDE,
    ),
) : ViewModel() {

    companion object {
        // Tick rate is defined by AudioRepository — mirrored here for the duration counter.
        val RECORD_TICK_MS get() = AudioRepository.RECORD_TICK_MS
    }

    private val _state = MutableStateFlow(AudioState())
    val state: StateFlow<AudioState> = _state.asStateFlow()

    private var amplitudeJob: Job? = null
    private var completionJob: Job? = null
    // Atomic flag to close the race window between rapid StartRecording taps.
    // The coroutine sets audioStatus = RecordingAudio only after startRecording() returns,
    // so the state-based guard alone cannot prevent two concurrent launches.
    private val isStartingRecording = AtomicBoolean(false)

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

    // ── Playback completion subscription ──────────────────────────────────────

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

    // ── Recording ─────────────────────────────────────────────────────────────

    private fun startRecording() {
        // Atomic compareAndSet closes the race window: two rapid taps both call this before
        // the coroutine has a chance to update audioStatus to RecordingAudio. The flag is
        // reset in a finally block so a failure still allows a retry.
        if (!isStartingRecording.compareAndSet(false, true)) return
        if (_state.value.audioStatus is AudioStatus.RecordingAudio) {
            isStartingRecording.set(false)
            return
        }
        viewModelScope.launch {
            try {
                when (val result = audioRepository.startRecording()) {
                    is Result.Ok -> {
                        waveformCompressor.reset()
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
            } finally {
                isStartingRecording.set(false)
            }
        }
    }

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

    // ── Amplitude streaming ───────────────────────────────────────────────────

    // Runs while recording; each tick advances the sliding waveform window.
    private fun subscribeToAmplitudes() {
        amplitudeJob?.cancel()
        amplitudeJob = viewModelScope.launch {
            audioRepository.amplitudeFlow().collect { amplitude ->
                val maxPoints = _state.value.audioData.amplitudes.size
                waveformCompressor.pushSample(amplitude)
                val updatedPreview = waveformCompressor.snapshot()
                _state.update { s ->
                    s.copy(
                        audioData = s.audioData.copy(
                            amplitudes = s.audioData.amplitudes.drop(1) + amplitude,
                            amplitudesPreview = updatedPreview,
                            durationMs = s.audioData.durationMs + RECORD_TICK_MS,
                        ),
                        amplitudeIndex = (s.amplitudeIndex - 1 + maxPoints) % maxPoints,
                    )
                }
            }
        }
    }

    // ── Playback ──────────────────────────────────────────────────────────────

    private fun playAudio(message: ChatMessage) {
        if (message.type != MessageType.Voice || message.fileName.isNullOrEmpty()) return

        viewModelScope.launch {
            // Stop any currently playing message first.
            if (_state.value.playingMessage != null) {
                when (audioRepository.stop()) {
                    is Result.Ok -> _state.update { s ->
                        // stop() fully releases MediaPlayer — reset to Initial, not Paused.
                        s.copy(playingMessage = null, audioStatus = AudioStatus.Initial)
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

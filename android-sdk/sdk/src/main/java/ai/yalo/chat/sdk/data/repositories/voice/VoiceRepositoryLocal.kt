// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.voice

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.data.datasources.voice.VoicePlayerDataSource
import ai.yalo.chat.sdk.data.datasources.voice.VoiceRecorderDataSource
import ai.yalo.chat.sdk.domain.audio.WaveformCompressor
import ai.yalo.chat.sdk.domain.models.VoiceNote
import ai.yalo.chat.sdk.log.YaloLog
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.File
import java.io.IOException
import kotlin.time.Duration.Companion.milliseconds

/**
 * Drives the device microphone and speaker, and says what they are doing in
 * terms the chat can draw.
 *
 * Two waveforms come out of one recording. The window in [recording] is the
 * last few seconds and is what moves while somebody speaks. The one on the
 * finished [VoiceNote] is the whole recording squeezed into the same number of
 * bars by [WaveformCompressor], so a note is drawn the same length whether it
 * ran for three seconds or three minutes.
 *
 * Recordings are kept in [recordingsDir] rather than in the cache, because for
 * a note the person recorded it is the only copy that can be played back: the
 * backend is told the id of the upload, which is not something to download
 * from.
 */
internal class VoiceRepositoryLocal(
    private val recorder: VoiceRecorderDataSource,
    private val player: VoicePlayerDataSource,
    private val recordingsDir: File,
    private val scope: CoroutineScope,
    private val now: () -> Long = System::currentTimeMillis,
    logLevel: LogLevel = LogLevel.Warn,
) : VoiceRepository {

    private val log = YaloLog(LOG_NAME, logLevel)

    private val _recording = MutableStateFlow<VoiceRecording?>(null)
    override val recording: StateFlow<VoiceRecording?> = _recording.asStateFlow()

    private val _playback = MutableStateFlow<VoicePlayback?>(null)
    override val playback: StateFlow<VoicePlayback?> = _playback.asStateFlow()

    private val waveform = WaveformCompressor(PREVIEW_BARS)

    private var target: File? = null
    private var startedAt: Long = 0
    private var sampling: Job? = null
    private var tracking: Job? = null

    override fun startRecording(): Result<Unit> {
        if (target != null) {
            return Result.failure(IllegalStateException("A recording is already running"))
        }
        stopPlayback()
        val file = File(recordingsDir, "$RECORDING_PREFIX${now()}.${recorder.fileExtension}")
        return recorder.start(file).onSuccess {
            target = file
            startedAt = now()
            waveform.reset()
            _recording.value = VoiceRecording(
                elapsedMillis = 0,
                amplitudes = List(LIVE_BARS) { 0f },
            )
            sampling = scope.launch { sample() }
        }
    }

    override suspend fun stopRecording(): Result<VoiceNote> {
        val file = target ?: return Result.failure(IllegalStateException("Nothing is recording"))
        val elapsed = now() - startedAt
        stopSampling()
        val stopped = recorder.stop()
        if (stopped.isFailure) {
            file.delete()
            return Result.failure(stopped.exceptionOrNull() ?: IOException(NOTHING_RECORDED))
        }
        if (file.length() <= 0) {
            file.delete()
            return Result.failure(IOException(NOTHING_RECORDED))
        }
        log.info { "recorded ${elapsed}ms into ${file.name}" }
        return Result.success(
            VoiceNote(
                durationMillis = elapsed,
                amplitudes = waveform.snapshot(),
                mediaType = recorder.mediaType,
                fileName = file.name,
                byteCount = file.length(),
                localPath = file.absolutePath,
            ),
        )
    }

    override suspend fun cancelRecording() {
        val file = target ?: return
        stopSampling()
        recorder.cancel()
        file.delete()
        log.info { "the recording was thrown away" }
    }

    override fun play(messageId: Long, file: File): Result<Unit> {
        val loaded = _playback.value
        if (loaded?.messageId == messageId) {
            player.play()
            _playback.value = loaded.copy(isPlaying = true)
            startTracking()
            return Result.success(Unit)
        }
        stopPlayback()
        return player.load(file) { finish(messageId) }.onSuccess {
            player.play()
            _playback.value = VoicePlayback(
                messageId = messageId,
                positionMillis = 0,
                durationMillis = player.duration(),
                isPlaying = true,
            )
            startTracking()
        }
    }

    override fun pausePlayback() {
        val loaded = _playback.value ?: return
        tracking?.cancel()
        tracking = null
        player.pause()
        _playback.value = loaded.copy(positionMillis = player.position(), isPlaying = false)
    }

    override fun release() {
        sampling?.cancel()
        sampling = null
        tracking?.cancel()
        tracking = null
        recorder.cancel()
        target?.delete()
        target = null
        _recording.value = null
        player.release()
        _playback.value = null
    }

    /**
     * Reads how loud the microphone is at the rate the waveform is drawn at,
     * folding every reading into both waveforms.
     */
    private suspend fun sample() {
        // Cancelling the job lands on the delay, which is what ends this.
        while (true) {
            delay(SAMPLE_INTERVAL_MILLIS.milliseconds)
            val window = _recording.value?.amplitudes ?: break
            val level = recorder.amplitude()
            waveform.push(level)
            _recording.value = VoiceRecording(
                elapsedMillis = now() - startedAt,
                amplitudes = window.drop(1) + level,
            )
        }
    }

    /** Follows the playhead, so the waveform fills as the note is listened to. */
    private fun startTracking() {
        tracking?.cancel()
        tracking = scope.launch {
            while (true) {
                delay(PROGRESS_INTERVAL_MILLIS.milliseconds)
                val loaded = _playback.value ?: break
                _playback.value = loaded.copy(positionMillis = player.position())
            }
        }
    }

    /**
     * The note has been heard to the end. It is left loaded and rewound, so
     * pressing play again starts it over rather than downloading it again.
     */
    private fun finish(messageId: Long) {
        tracking?.cancel()
        tracking = null
        val loaded = _playback.value
        if (loaded?.messageId != messageId) {
            return
        }
        _playback.value = loaded.copy(positionMillis = 0, isPlaying = false)
    }

    private fun stopPlayback() {
        tracking?.cancel()
        tracking = null
        if (_playback.value == null) {
            return
        }
        player.release()
        _playback.value = null
    }

    private suspend fun stopSampling() {
        sampling?.cancelAndJoin()
        sampling = null
        target = null
        _recording.value = null
    }

    private companion object {

        private const val LOG_NAME = "Voice"
        private const val NOTHING_RECORDED = "The recording was too short to keep"
        private const val RECORDING_PREFIX = "voice-"

        /** Bars in the window the footer draws while somebody is speaking. */
        const val LIVE_BARS = 40

        /** Bars in the waveform sent with the message, the same number the web SDK sends. */
        const val PREVIEW_BARS = 40

        const val SAMPLE_INTERVAL_MILLIS = 60L
        const val PROGRESS_INTERVAL_MILLIS = 100L
    }
}

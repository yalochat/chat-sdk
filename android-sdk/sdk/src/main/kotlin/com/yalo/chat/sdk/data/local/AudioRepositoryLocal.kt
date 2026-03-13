// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.local

import android.content.Context
import android.media.MediaMetadataRetriever
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.os.Build
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.repository.AudioRepository
import java.io.File
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.buffer
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.withContext
import kotlin.math.log10

// Port of flutter-sdk AudioRepositoryLocal / AudioServiceFile using Android platform APIs.
// MediaRecorder replaces the Flutter `record` plugin.
// MediaPlayer replaces the Flutter `audioplayers` plugin.
// FDE-60: recording, FDE-61: amplitude flow, FDE-62: playback.
internal class AudioRepositoryLocal(
    private val context: Context,
) : AudioRepository {

    // Guarded by the coroutine dispatcher — recorder/player mutated from suspend functions,
    // @Volatile ensures cross-thread visibility for the completion listener assignment of player.
    private var recorder: MediaRecorder? = null
    private var currentFile: File? = null
    @Volatile private var player: MediaPlayer? = null
    @Volatile private var isRecording = false

    // FDE-62: shared flow that emits when MediaPlayer.setOnCompletionListener fires.
    // extraBufferCapacity = 1 ensures the emission is not dropped if no collector is active yet.
    private val _playbackCompleted = MutableSharedFlow<Unit>(extraBufferCapacity = 1)

    // ── FDE-60: Recording ─────────────────────────────────────────────────────

    override suspend fun startRecording(): Result<String> = withContext(Dispatchers.IO) {
        var localRecorder: MediaRecorder? = null
        try {
            val file = File(context.cacheDir, "audio_${System.currentTimeMillis()}.m4a")

            @Suppress("DEPRECATION")
            localRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(context)
            } else {
                MediaRecorder()
            }

            localRecorder.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setOutputFile(file.absolutePath)
                // Defensive FDE-60: on hardware error release the exact instance that errored
                // and clear state. The listener fires asynchronously during active recording,
                // so recorder is already assigned — using the callback's erroredRecorder
                // parameter is clearer and avoids any ambiguity.
                setOnErrorListener { erroredRecorder, _, _ ->
                    isRecording = false
                    erroredRecorder.release()
                    recorder = null
                }
                prepare()
                start()
            }

            recorder = localRecorder
            currentFile = file
            isRecording = true
            Result.Ok(file.absolutePath)
        } catch (e: Exception) {
            // Release localRecorder directly — recorder property may not be assigned yet
            // if the exception was thrown by prepare() or start().
            localRecorder?.release()
            recorder = null
            isRecording = false
            Result.Error(e)
        }
    }

    override suspend fun stopRecording(): Result<AudioData> = withContext(Dispatchers.IO) {
        try {
            val rec = recorder
                ?: return@withContext Result.Error(IllegalStateException("No active recording"))
            val file = currentFile
            rec.stop()
            rec.release()
            recorder = null
            currentFile = null
            isRecording = false

            // Read duration from the recorded file's metadata.
            // MediaMetadataRetriever is closed in finally to avoid a native resource leak
            // if setDataSource or extractMetadata throws.
            val durationMs = if (file != null) {
                runCatching {
                    val retriever = MediaMetadataRetriever()
                    try {
                        retriever.setDataSource(file.absolutePath)
                        retriever.extractMetadata(
                            MediaMetadataRetriever.METADATA_KEY_DURATION
                        )?.toLongOrNull() ?: 0L
                    } finally {
                        retriever.release()
                    }
                }.getOrDefault(0L)
            } else 0L

            Result.Ok(AudioData(fileName = file?.absolutePath ?: "", durationMs = durationMs))
        } catch (e: Exception) {
            recorder?.release()
            recorder = null
            isRecording = false
            Result.Error(e)
        }
    }

    // ── FDE-61: Amplitude flow ────────────────────────────────────────────────

    // Cold Flow that polls MediaRecorder.maxAmplitude every 25ms while recording.
    // Converts raw 0..32767 values to DBFS to match Flutter's amplitude representation.
    // buffer(UNLIMITED) is intentional — duration is tracked by counting emitted samples in
    // AudioViewModel, so no samples must be dropped. conflate() would undercount duration.
    override fun amplitudeFlow(): Flow<Double> = flow {
        while (isRecording) {
            val raw = recorder?.maxAmplitude ?: 0
            // Convert 0..32767 → DBFS (matches Flutter AudioRepositoryLocal mapping).
            val dbfs = if (raw > 0) 20.0 * log10(raw / 32767.0) else -160.0
            emit(dbfs)
            kotlinx.coroutines.delay(AudioRepository.RECORD_TICK_MS)
        }
    }.buffer(Channel.UNLIMITED)

    // ── FDE-62: Playback ──────────────────────────────────────────────────────

    // Note: prepare() is called on Dispatchers.IO (blocking file I/O) to avoid ANR risk.
    // MediaPlayer is constructed on IO; AOSP MediaPlayer falls back to the main Looper for
    // callback delivery when no current-thread Looper exists, so completion/error listeners
    // are delivered on Main regardless of which thread creates the player.
    override suspend fun play(fileName: String): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            // Release any existing player before starting a new one.
            player?.stop()
            player?.release()
            player = null

            val mediaPlayer = MediaPlayer().apply {
                setDataSource(fileName)
                setOnCompletionListener { mp ->
                    _playbackCompleted.tryEmit(Unit)
                    mp.release()
                    player = null
                }
                setOnErrorListener { mp, _, _ ->
                    mp.release()
                    player = null
                    true
                }
                prepare() // blocking — safe on Dispatchers.IO
                start()
            }
            player = mediaPlayer
            Result.Ok(Unit)
        } catch (e: Exception) {
            player?.release()
            player = null
            Result.Error(e)
        }
    }

    // Stops and releases the current player. Using stop()+release() rather than pause()
    // fully cleans up the MediaPlayer resource — the next play() always creates a fresh one.
    override suspend fun stop(): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            player?.stop()
            player?.release()
            player = null
            Result.Ok(Unit)
        } catch (e: Exception) {
            Result.Error(e)
        }
    }

    override fun onPlaybackCompleted(): Flow<Unit> = _playbackCompleted.asSharedFlow()

    // ── Defensive resource release ────────────────────────────────────────────

    // Called from AudioViewModel.onCleared().
    // Catches any IllegalStateException from stopping an already-stopped recorder/player.
    override fun release() {
        try { recorder?.stop() } catch (_: Exception) {}
        recorder?.release()
        recorder = null
        currentFile = null
        isRecording = false

        try { player?.stop() } catch (_: Exception) {}
        player?.release()
        player = null
    }
}

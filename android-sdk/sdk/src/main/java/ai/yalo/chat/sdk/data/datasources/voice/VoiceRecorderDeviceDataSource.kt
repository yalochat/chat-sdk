// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.voice

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.log.YaloLog
import android.content.Context
import android.media.MediaRecorder
import android.os.Build
import java.io.File
import java.io.IOException

/**
 * Records through the platform `MediaRecorder`.
 *
 * AAC in an MP4 container, which every Android the SDK supports can both record
 * and play, and which the rest of the product already plays. Opus would match
 * the web SDK's own recordings more closely, but the platform cannot write it
 * below API 29 and the SDK goes back to 24.
 *
 * One recorder is built per recording and released at the end of it. Keeping
 * one around holds the microphone open, which stops anything else on the device
 * from using it.
 */
internal class VoiceRecorderDeviceDataSource(
    private val context: Context,
    logLevel: LogLevel = LogLevel.Warn,
    private val recorders: (Context) -> MediaRecorder = ::platformRecorder,
) : VoiceRecorderDataSource {

    private val log = YaloLog(LOG_NAME, logLevel)

    private var recorder: MediaRecorder? = null

    override val mediaType: String = MEDIA_TYPE

    override val fileExtension: String = FILE_EXTENSION

    override fun start(target: File): Result<Unit> {
        if (recorder != null) {
            log.warn { "already recording" }
            return Result.failure(IllegalStateException("A recording is already running"))
        }
        target.parentFile?.mkdirs()
        val started = recorders(context).apply {
            setAudioSource(MediaRecorder.AudioSource.MIC)
            setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            setAudioEncodingBitRate(BIT_RATE)
            setAudioSamplingRate(SAMPLE_RATE)
            setOutputFile(target.absolutePath)
        }
        return try {
            started.prepare()
            started.start()
            recorder = started
            log.info { "recording to ${target.name}" }
            Result.success(Unit)
        } catch (error: IOException) {
            release(started)
            log.warn(error) { CANNOT_RECORD }
            Result.failure(error)
        } catch (error: IllegalStateException) {
            release(started)
            log.warn(error) { CANNOT_RECORD }
            Result.failure(error)
        } catch (error: RuntimeException) {
            // What the platform throws when the microphone is refused or taken,
            // which is an ordinary thing to happen rather than a bug.
            release(started)
            log.warn(error) { CANNOT_RECORD }
            Result.failure(error)
        }
    }

    override fun amplitude(): Float {
        val reading = try {
            recorder?.maxAmplitude ?: return 0f
        } catch (error: IllegalStateException) {
            log.debug { "the recorder had nothing to say about how loud it is" }
            return 0f
        }
        return (reading.toFloat() / MAX_AMPLITUDE).coerceIn(0f, 1f)
    }

    override fun stop(): Result<Unit> {
        val running = recorder ?: return Result.failure(IllegalStateException("Nothing is recording"))
        recorder = null
        return try {
            running.stop()
            Result.success(Unit)
        } catch (error: RuntimeException) {
            // Stopping throws when the recording was too short to hold a single
            // frame, and the file it leaves behind is unplayable.
            log.warn(error) { "the recording was not finished" }
            Result.failure(error)
        } finally {
            release(running)
        }
    }

    override fun cancel() {
        val running = recorder ?: return
        recorder = null
        try {
            running.stop()
        } catch (error: RuntimeException) {
            log.debug { "nothing worth keeping had been recorded" }
        } finally {
            release(running)
        }
    }

    private fun release(recorder: MediaRecorder) {
        try {
            recorder.release()
        } catch (error: RuntimeException) {
            log.debug { "the recorder was already gone" }
        }
    }

    private companion object {

        private const val LOG_NAME = "VoiceRecorder"
        private const val CANNOT_RECORD = "The microphone is not available"

        const val MEDIA_TYPE = "audio/mp4"
        const val FILE_EXTENSION = "m4a"

        const val BIT_RATE = 64_000
        const val SAMPLE_RATE = 44_100

        /** The loudest `MediaRecorder` can report, which is a signed 16 bit peak. */
        const val MAX_AMPLITUDE = 32_767f
    }
}

/** The platform recorder, built the way the running Android wants it built. */
private fun platformRecorder(context: Context): MediaRecorder =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        MediaRecorder(context)
    } else {
        @Suppress("DEPRECATION")
        MediaRecorder()
    }

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.voice

import java.io.File

/**
 * Stands in for the microphone so a test can say what it hears.
 *
 * [levels] are handed out one per reading and the last one repeats, which is
 * how a test writes a recording that gets louder and then holds.
 */
internal class FakeVoiceRecorderDataSource : VoiceRecorderDataSource {

    override val mediaType: String = "audio/mp4"
    override val fileExtension: String = "m4a"

    /** Set to make starting the microphone come back failed. */
    var startFailure: Throwable? = null

    /** Set to make finishing the recording come back failed. */
    var stopFailure: Throwable? = null

    /** What the file holds once the recording is finished. */
    var recorded: ByteArray = ByteArray(16)

    var levels: List<Float> = listOf(0.5f)

    var started: File? = null
        private set

    var cancelCount: Int = 0
        private set

    private var reading = 0

    override fun start(target: File): Result<Unit> {
        startFailure?.let { error -> return Result.failure(error) }
        started = target
        reading = 0
        target.parentFile?.mkdirs()
        target.writeBytes(ByteArray(0))
        return Result.success(Unit)
    }

    override fun amplitude(): Float {
        val level = levels[minOf(reading, levels.lastIndex)]
        reading++
        return level
    }

    override fun stop(): Result<Unit> {
        stopFailure?.let { error -> return Result.failure(error) }
        started?.writeBytes(recorded)
        return Result.success(Unit)
    }

    override fun cancel() {
        cancelCount++
    }
}

/**
 * Stands in for the speaker so a test can say where playback has got to.
 *
 * [finish] plays the loaded note to its end, which is how a test asks what the
 * chat does when a note is over.
 */
internal class FakeVoicePlayerDataSource : VoicePlayerDataSource {

    /** Set to make loading a note come back failed. */
    var loadFailure: Throwable? = null

    var loaded: File? = null
        private set

    var isPlaying: Boolean = false
        private set

    var positionMillis: Long = 0

    var durationMillis: Long = 3_000

    var releaseCount: Int = 0
        private set

    private var finished: (() -> Unit)? = null

    override fun load(file: File, onFinished: () -> Unit): Result<Unit> {
        loadFailure?.let { error -> return Result.failure(error) }
        loaded = file
        finished = onFinished
        positionMillis = 0
        return Result.success(Unit)
    }

    override fun play() {
        isPlaying = true
    }

    override fun pause() {
        isPlaying = false
    }

    override fun position(): Long = positionMillis

    override fun duration(): Long = durationMillis

    override fun release() {
        releaseCount++
        isPlaying = false
        loaded = null
    }

    /** Plays the loaded note to its end, the way the device would report it. */
    fun finish() {
        isPlaying = false
        finished?.invoke()
    }
}

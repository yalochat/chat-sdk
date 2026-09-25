// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.voice

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.log.YaloLog
import android.media.AudioAttributes
import android.media.MediaPlayer
import java.io.File
import java.io.IOException

/**
 * Plays through the platform `MediaPlayer`.
 *
 * The audio is declared as speech so the device treats a voice note the way it
 * treats a call rather than the way it treats music, which is what routes it to
 * the earpiece and ducks whatever else is playing.
 */
internal class VoicePlayerDeviceDataSource(
    logLevel: LogLevel = LogLevel.Warn,
    private val players: () -> MediaPlayer = ::MediaPlayer,
) : VoicePlayerDataSource {

    private val log = YaloLog(LOG_NAME, logLevel)

    private var player: MediaPlayer? = null

    override fun load(file: File, onFinished: () -> Unit): Result<Unit> {
        release()
        val loaded = players()
        return try {
            loaded.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build(),
            )
            loaded.setDataSource(file.absolutePath)
            loaded.prepare()
            loaded.setOnCompletionListener { onFinished() }
            player = loaded
            log.info { "playing ${file.name}" }
            Result.success(Unit)
        } catch (error: IOException) {
            loaded.release()
            log.warn(error) { CANNOT_PLAY }
            Result.failure(error)
        } catch (error: IllegalStateException) {
            loaded.release()
            log.warn(error) { CANNOT_PLAY }
            Result.failure(error)
        } catch (error: IllegalArgumentException) {
            loaded.release()
            log.warn(error) { CANNOT_PLAY }
            Result.failure(error)
        }
    }

    override fun play() {
        val loaded = player ?: return
        try {
            loaded.start()
        } catch (error: IllegalStateException) {
            log.warn(error) { CANNOT_PLAY }
        }
    }

    override fun pause() {
        val loaded = player ?: return
        try {
            if (loaded.isPlaying) {
                loaded.pause()
            }
        } catch (error: IllegalStateException) {
            log.debug { "there was nothing to pause" }
        }
    }

    override fun position(): Long = reading { player -> player.currentPosition.toLong() }

    override fun duration(): Long = reading { player -> player.duration.toLong() }

    override fun release() {
        val loaded = player ?: return
        player = null
        try {
            loaded.release()
        } catch (error: RuntimeException) {
            log.debug { "the player was already gone" }
        }
    }

    // Both readings throw once the player has been let go of, which is a race
    // a ticking progress bar loses often enough to be worth expecting.
    private fun reading(read: (MediaPlayer) -> Long): Long {
        val loaded = player ?: return 0
        return try {
            read(loaded).coerceAtLeast(0)
        } catch (error: IllegalStateException) {
            0
        }
    }

    private companion object {

        private const val LOG_NAME = "VoicePlayer"
        private const val CANNOT_PLAY = "The voice note cannot be played"
    }
}

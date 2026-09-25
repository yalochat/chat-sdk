// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.voice

import java.io.File

/**
 * Plays one voice note at a time through the device.
 *
 * A file can be truncated, be in a format the device will not decode, or have
 * gone missing since it was stored, so [load] reports that as a failed [Result]
 * rather than throwing it at the chat.
 */
internal interface VoicePlayerDataSource {

    /**
     * Loads [file], ready to play from the start. Whatever was loaded before is
     * let go of. [onFinished] is called when playback reaches the end, never
     * when it is paused or replaced.
     */
    fun load(file: File, onFinished: () -> Unit): Result<Unit>

    /** Plays from wherever the loaded audio is. Nothing loaded, nothing happens. */
    fun play()

    fun pause()

    /** How far into the loaded audio playback has got, in milliseconds. */
    fun position(): Long

    /** How long the loaded audio runs, in milliseconds, or zero when none is. */
    fun duration(): Long

    /** Lets go of the device, whether or not anything was loaded. */
    fun release()
}

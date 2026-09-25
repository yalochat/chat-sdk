// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.voice

import java.io.File

/**
 * The device microphone, as much of it as a voice note needs.
 *
 * The microphone can be busy, missing or refused, none of which the chat may
 * crash on, so [start] and [stop] report that as a failed [Result].
 */
internal interface VoiceRecorderDataSource {

    /** What the recording is written as, so an upload can say what it is sending. */
    val mediaType: String

    /** The file extension that goes with [mediaType], without the dot. */
    val fileExtension: String

    /** Begins writing a recording to [target], replacing whatever was there. */
    fun start(target: File): Result<Unit>

    /**
     * The loudest sound heard since this was last asked, from zero to one.
     *
     * Reading it is what moves the window along, so it is asked at the rate the
     * waveform is drawn at rather than whenever something is curious.
     */
    fun amplitude(): Float

    /** Finishes the recording and leaves the file in place. */
    fun stop(): Result<Unit>

    /** Gives up on the recording. The file is left for the caller to delete. */
    fun cancel()
}

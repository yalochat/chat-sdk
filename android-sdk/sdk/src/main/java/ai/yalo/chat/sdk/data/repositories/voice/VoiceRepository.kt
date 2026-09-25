// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.voice

import ai.yalo.chat.sdk.domain.models.VoiceNote
import kotlinx.coroutines.flow.StateFlow
import java.io.File

/**
 * A recording being made, as the footer draws it.
 *
 * [amplitudes] is a window on the last few seconds rather than the whole
 * recording, so the waveform moves while somebody speaks. What is sent with the
 * message is a different shape, covering all of it.
 */
internal data class VoiceRecording(
    val elapsedMillis: Long,
    val amplitudes: List<Float>,
)

/** A voice note being listened to, and how far in it is. */
internal data class VoicePlayback(
    val messageId: Long,
    val positionMillis: Long,
    val durationMillis: Long,
    val isPlaying: Boolean,
)

/**
 * The microphone and the speaker, as one thing.
 *
 * They are kept together because only one of them can be in use: starting a
 * recording stops whatever was playing, and there is no state in which both
 * make sense. Two repositories would have to agree on that between them.
 */
internal interface VoiceRepository {

    /** The recording under way, or null when the microphone is idle. */
    val recording: StateFlow<VoiceRecording?>

    /** The note being listened to, or null when nothing is loaded. */
    val playback: StateFlow<VoicePlayback?>

    /** Begins recording, stopping any playback first. */
    fun startRecording(): Result<Unit>

    /**
     * Finishes the recording and hands back the note, ready to be stored and
     * sent. A recording too short to hold anything comes back failed, and
     * nothing is left on disk.
     */
    suspend fun stopRecording(): Result<VoiceNote>

    /** Gives up on the recording and deletes it. */
    suspend fun cancelRecording()

    /**
     * Plays [file] as the note of [messageId], carrying on from where it was
     * paused when that is the note already loaded.
     */
    fun play(messageId: Long, file: File): Result<Unit>

    fun pausePlayback()

    /** Lets go of the microphone and the speaker for good. */
    fun release()
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.voice

import ai.yalo.chat.sdk.domain.models.VoiceNote
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.io.File

/**
 * Stands in for the microphone and the speaker so a test can say what they do
 * without a device.
 *
 * [note] is what a stopped recording hands back, and setting it to null is how
 * a test asks what the chat does when nothing was recorded.
 */
internal class FakeVoiceRepository : VoiceRepository {

    private val _recording = MutableStateFlow<VoiceRecording?>(null)
    override val recording: StateFlow<VoiceRecording?> = _recording.asStateFlow()

    private val _playback = MutableStateFlow<VoicePlayback?>(null)
    override val playback: StateFlow<VoicePlayback?> = _playback.asStateFlow()

    /** What [stopRecording] hands back when it succeeds. */
    var note: VoiceNote? = VoiceNote(durationMillis = 1_500, amplitudes = listOf(0.5f))

    /** Set to make starting the microphone come back failed. */
    var startFailure: Throwable? = null

    var startCount: Int = 0
        private set

    var cancelCount: Int = 0
        private set

    var pauseCount: Int = 0
        private set

    var isReleased: Boolean = false
        private set

    /** Every note that was played, as the message it belongs to and its file. */
    val played: MutableList<Pair<Long, File>> = mutableListOf()

    override fun startRecording(): Result<Unit> {
        startFailure?.let { error -> return Result.failure(error) }
        startCount++
        _recording.value = VoiceRecording(elapsedMillis = 0, amplitudes = listOf(0f))
        return Result.success(Unit)
    }

    override suspend fun stopRecording(): Result<VoiceNote> {
        _recording.value = null
        val recorded = note ?: return Result.failure(IllegalStateException("Nothing was recorded"))
        return Result.success(recorded)
    }

    override suspend fun cancelRecording() {
        cancelCount++
        _recording.value = null
    }

    override fun play(messageId: Long, file: File): Result<Unit> {
        played.add(messageId to file)
        _playback.value = VoicePlayback(
            messageId = messageId,
            positionMillis = 0,
            durationMillis = 1_500,
            isPlaying = true,
        )
        return Result.success(Unit)
    }

    override fun pausePlayback() {
        pauseCount++
        _playback.value = _playback.value?.copy(isPlaying = false)
    }

    override fun release() {
        isReleased = true
        _recording.value = null
        _playback.value = null
    }

    /** Says the microphone is picking something up, the way the device would. */
    fun reportRecording(value: VoiceRecording?) {
        _recording.value = value
    }
}

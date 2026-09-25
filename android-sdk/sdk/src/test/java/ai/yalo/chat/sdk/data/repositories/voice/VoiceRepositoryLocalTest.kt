// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.voice

import ai.yalo.chat.sdk.data.datasources.voice.FakeVoicePlayerDataSource
import ai.yalo.chat.sdk.data.datasources.voice.FakeVoiceRecorderDataSource
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.io.File
import java.io.IOException

@OptIn(ExperimentalCoroutinesApi::class)
class VoiceRepositoryLocalTest {

    @get:Rule
    val folder = TemporaryFolder()

    private val recorder = FakeVoiceRecorderDataSource()
    private val player = FakeVoicePlayerDataSource()

    @Test
    fun saysHowLongTheRecordingHasBeenRunningAndWhatItIsHearing() = runTest {
        val clock = FakeClock()
        val repository = voiceRepository(scope = this, now = clock)
        recorder.levels = listOf(0.4f, 0.8f)

        repository.startRecording()
        clock.millis = 1_000
        advanceTimeBy(200)

        val recording = repository.recording.value
        assertEquals(1_000L, recording?.elapsedMillis)
        assertTrue(recording?.amplitudes.orEmpty().contains(0.8f))
        repository.release()
    }

    @Test
    fun handsBackWhatWasRecordedWhenItIsStopped() = runTest {
        val repository = voiceRepository(scope = this, now = FakeClock(millis = 5_000))
        recorder.recorded = ByteArray(128)

        repository.startRecording()
        val note = repository.stopRecording().getOrThrow()

        assertEquals("audio/mp4", note.mediaType)
        assertEquals(128L, note.byteCount)
        assertTrue(note.fileName.endsWith(".m4a"))
        assertNotNull(note.localPath)
        assertNull(repository.recording.value)
    }

    @Test
    fun measuresTheNoteAgainstTheClockRatherThanTheLastReading() = runTest {
        val clock = FakeClock()
        val repository = voiceRepository(scope = this, now = clock)

        repository.startRecording()
        clock.millis = 3_500
        val note = repository.stopRecording().getOrThrow()

        assertEquals(3_500L, note.durationMillis)
    }

    @Test
    fun reportsARecordingTheMicrophoneWouldNotStart() = runTest {
        val repository = voiceRepository(scope = this)
        recorder.startFailure = IOException("The microphone is busy")

        assertTrue(repository.startRecording().isFailure)
        assertNull(repository.recording.value)
    }

    @Test
    fun keepsNothingWhenTheRecordingWasTooShortToHold() = runTest {
        val repository = voiceRepository(scope = this)
        recorder.stopFailure = IllegalStateException("Nothing was written")

        repository.startRecording()
        val stopped = repository.stopRecording()

        assertTrue(stopped.isFailure)
        assertFalse(recorder.started?.exists() == true)
    }

    @Test
    fun keepsNothingWhenTheRecordingCameOutEmpty() = runTest {
        val repository = voiceRepository(scope = this)
        recorder.recorded = ByteArray(0)

        repository.startRecording()
        val stopped = repository.stopRecording()

        assertTrue(stopped.isFailure)
        assertFalse(recorder.started?.exists() == true)
    }

    @Test
    fun deletesTheRecordingWhenItIsThrownAway() = runTest {
        val repository = voiceRepository(scope = this)

        repository.startRecording()
        val file = recorder.started
        repository.cancelRecording()

        assertEquals(1, recorder.cancelCount)
        assertFalse(file?.exists() == true)
        assertNull(repository.recording.value)
    }

    @Test
    fun doesNothingWhenThereIsNoRecordingToThrowAway() = runTest {
        val repository = voiceRepository(scope = this)

        repository.cancelRecording()

        assertEquals(0, recorder.cancelCount)
    }

    @Test
    fun refusesASecondRecordingWhileOneIsRunning() = runTest {
        val repository = voiceRepository(scope = this)

        repository.startRecording()

        assertTrue(repository.startRecording().isFailure)
        repository.release()
    }

    @Test
    fun refusesToStopWhenNothingIsRecording() = runTest {
        val repository = voiceRepository(scope = this)

        assertTrue(repository.stopRecording().isFailure)
    }

    @Test
    fun followsThePlayheadWhileANoteIsBeingListenedTo() = runTest {
        val repository = voiceRepository(scope = this)
        val note = folder.newFile("note.m4a")

        repository.play(messageId = 7, file = note)
        player.positionMillis = 1_200
        advanceTimeBy(200)

        assertEquals(
            VoicePlayback(messageId = 7, positionMillis = 1_200, durationMillis = 3_000, isPlaying = true),
            repository.playback.value,
        )
        repository.release()
    }

    @Test
    fun carriesOnFromWhereANotePausedRatherThanLoadingItAgain() = runTest {
        val repository = voiceRepository(scope = this)
        val note = folder.newFile("note.m4a")

        repository.play(messageId = 7, file = note)
        repository.pausePlayback()
        repository.play(messageId = 7, file = note)

        assertEquals(0, player.releaseCount)
        assertTrue(player.isPlaying)
        repository.release()
    }

    @Test
    fun letsGoOfANoteWhenAnotherOneIsPlayed() = runTest {
        val repository = voiceRepository(scope = this)

        repository.play(messageId = 7, file = folder.newFile("first.m4a"))
        repository.play(messageId = 8, file = folder.newFile("second.m4a"))

        assertEquals(8L, repository.playback.value?.messageId)
        assertEquals(1, player.releaseCount)
        repository.release()
    }

    @Test
    fun rewindsANoteThatHasBeenHeardToTheEnd() = runTest {
        val repository = voiceRepository(scope = this)

        repository.play(messageId = 7, file = folder.newFile("note.m4a"))
        player.finish()

        assertEquals(
            VoicePlayback(messageId = 7, positionMillis = 0, durationMillis = 3_000, isPlaying = false),
            repository.playback.value,
        )
    }

    @Test
    fun reportsANoteTheDeviceWillNotPlay() = runTest {
        val repository = voiceRepository(scope = this)
        player.loadFailure = IOException("Not audio")

        val played = repository.play(messageId = 7, file = folder.newFile("note.m4a"))

        assertTrue(played.isFailure)
        assertNull(repository.playback.value)
    }

    @Test
    fun doesNothingWhenThereIsNothingToPause() = runTest {
        val repository = voiceRepository(scope = this)

        repository.pausePlayback()

        assertNull(repository.playback.value)
    }

    @Test
    fun stopsWhateverIsPlayingWhenARecordingStarts() = runTest {
        val repository = voiceRepository(scope = this)

        repository.play(messageId = 7, file = folder.newFile("note.m4a"))
        repository.startRecording()

        assertNull(repository.playback.value)
        assertEquals(1, player.releaseCount)
        repository.release()
    }

    @Test
    fun letsGoOfEverythingWhenItIsReleased() = runTest {
        val repository = voiceRepository(scope = this)

        repository.startRecording()
        val file = recorder.started
        repository.release()

        assertNull(repository.recording.value)
        assertNull(repository.playback.value)
        assertEquals(1, recorder.cancelCount)
        assertFalse(file?.exists() == true)
    }

    private fun voiceRepository(
        scope: TestScope,
        now: FakeClock = FakeClock(),
    ): VoiceRepositoryLocal = VoiceRepositoryLocal(
        recorder = recorder,
        player = player,
        recordingsDir = File(folder.root, "voice"),
        scope = scope,
        now = now::invoke,
    )

    /** A clock a test moves by hand, so elapsed time is not a matter of timing. */
    private class FakeClock(var millis: Long = 0) {
        operator fun invoke(): Long = millis
    }
}

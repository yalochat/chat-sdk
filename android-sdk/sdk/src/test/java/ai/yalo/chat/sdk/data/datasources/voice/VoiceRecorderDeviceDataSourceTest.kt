// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.voice

import android.media.MediaRecorder
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import java.io.File
import java.io.IOException

@RunWith(RobolectricTestRunner::class)
class VoiceRecorderDeviceDataSourceTest {

    @get:Rule
    val folder = TemporaryFolder()

    private val recorder = VoiceRecorderDeviceDataSource(RuntimeEnvironment.getApplication())

    @Test
    fun recordsSomethingEveryClientOfTheProductCanPlay() {
        assertEquals("audio/mp4", recorder.mediaType)
        assertEquals("m4a", recorder.fileExtension)
    }

    @Test
    fun makesRoomForTheRecordingItWasPointedAt() {
        val target = File(folder.root, "notes/voice-1.m4a")

        assertTrue(recorder.start(target).isSuccess)

        assertTrue(target.parentFile?.exists() == true)
        recorder.cancel()
    }

    @Test
    fun refusesASecondRecordingWhileOneIsRunning() {
        recorder.start(File(folder.root, "voice-1.m4a"))

        assertTrue(recorder.start(File(folder.root, "voice-2.m4a")).isFailure)
        recorder.cancel()
    }

    @Test
    fun saysHowLoudTheRoomIsBetweenNothingAndEverything() {
        recorder.start(File(folder.root, "voice-1.m4a"))

        assertTrue(recorder.amplitude() in 0f..1f)
        recorder.cancel()
    }

    @Test
    fun hearsNothingWhileNothingIsBeingRecorded() {
        assertEquals(0f, recorder.amplitude(), TOLERANCE)
    }

    @Test
    fun letsGoOfTheMicrophoneOnceTheRecordingIsFinished() {
        recorder.start(File(folder.root, "voice-1.m4a"))

        assertTrue(recorder.stop().isSuccess)

        // Stopping twice can only work if the first stop let the microphone go.
        assertTrue(recorder.stop().isFailure)
    }

    @Test
    fun refusesToStopWhenNothingIsRecording() {
        assertTrue(recorder.stop().isFailure)
    }

    @Test
    fun letsGoOfTheMicrophoneWhenTheRecordingIsGivenUpOn() {
        recorder.start(File(folder.root, "voice-1.m4a"))

        recorder.cancel()

        assertTrue(recorder.stop().isFailure)
    }

    @Test
    fun doesNothingWhenThereIsNoRecordingToGiveUpOn() {
        recorder.cancel()

        assertTrue(recorder.stop().isFailure)
    }

    @Test
    fun recordsAgainAfterARecordingWasFinished() {
        recorder.start(File(folder.root, "voice-1.m4a"))
        recorder.stop()

        assertTrue(recorder.start(File(folder.root, "voice-2.m4a")).isSuccess)
        recorder.cancel()
    }

    @Test
    fun reportsAMicrophoneTheDeviceWillNotOpen() {
        val refusing = recorder(onPrepare = { throw RuntimeException("The microphone is in use") })

        val started = refusing.start(File(folder.root, "voice-1.m4a"))

        assertTrue(started.isFailure)
        // Nothing was kept, so the next tap is free to try again.
        assertTrue(refusing.start(File(folder.root, "voice-2.m4a")).isFailure)
    }

    @Test
    fun reportsARecordingTheDeviceCannotWrite() {
        val failing = recorder(onPrepare = { throw IOException("No room") })

        assertTrue(failing.start(File(folder.root, "voice-1.m4a")).isFailure)
    }

    @Test
    fun reportsADeviceThatWasNotReadyToRecord() {
        val failing = recorder(onPrepare = { throw IllegalStateException("Not configured") })

        assertTrue(failing.start(File(folder.root, "voice-1.m4a")).isFailure)
    }

    @Test
    fun hearsNothingWhenTheDeviceWillNotSayHowLoudItIs() {
        val silent = recorder(
            onAmplitude = { throw IllegalStateException("Not recording") },
        )
        silent.start(File(folder.root, "voice-1.m4a"))

        assertEquals(0f, silent.amplitude(), TOLERANCE)
        silent.cancel()
    }

    @Test
    fun reportsARecordingTheDeviceWouldNotFinish() {
        val failing = recorder(onStop = { throw RuntimeException("Too short") })
        failing.start(File(folder.root, "voice-1.m4a"))

        assertTrue(failing.stop().isFailure)
        // The microphone went back even though finishing failed.
        assertTrue(failing.start(File(folder.root, "voice-2.m4a")).isSuccess)
        failing.cancel()
    }

    @Test
    fun givesUpQuietlyOnARecordingTheDeviceWouldNotFinish() {
        val failing = recorder(onStop = { throw RuntimeException("Too short") })
        failing.start(File(folder.root, "voice-1.m4a"))

        failing.cancel()

        assertTrue(failing.start(File(folder.root, "voice-2.m4a")).isSuccess)
        failing.cancel()
    }

    @Test
    fun carriesOnWhenTheDeviceWasAlreadyGone() {
        val failing = recorder(onRelease = { throw RuntimeException("Already released") })
        failing.start(File(folder.root, "voice-1.m4a"))

        assertTrue(failing.stop().isSuccess)
    }

    /** A recorder that fails wherever the test says the device would. */
    private fun recorder(
        onPrepare: () -> Unit = {},
        onAmplitude: () -> Int = { 0 },
        onStop: () -> Unit = {},
        onRelease: () -> Unit = {},
    ) = VoiceRecorderDeviceDataSource(RuntimeEnvironment.getApplication(), recorders = {
        object : MediaRecorder() {
            override fun prepare() {
                onPrepare()
                super.prepare()
            }

            override fun getMaxAmplitude(): Int = onAmplitude()

            override fun stop() {
                onStop()
                super.stop()
            }

            override fun release() {
                onRelease()
                super.release()
            }
        }
    })

    private companion object {
        const val TOLERANCE = 0.0001f
    }
}

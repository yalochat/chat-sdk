// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.voice

import android.media.MediaPlayer
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.shadows.ShadowMediaPlayer
import org.robolectric.shadows.ShadowMediaPlayer.MediaInfo
import org.robolectric.shadows.util.DataSource
import java.io.File
import java.io.IOException

@RunWith(RobolectricTestRunner::class)
class VoicePlayerDeviceDataSourceTest {

    @get:Rule
    val folder = TemporaryFolder()

    private val player = VoicePlayerDeviceDataSource()

    private lateinit var note: File

    @Before
    fun describeTheNoteTheDeviceCanPlay() {
        note = folder.newFile("note.m4a")
        ShadowMediaPlayer.addMediaInfo(
            DataSource.toDataSource(note.absolutePath),
            MediaInfo(DURATION_MILLIS, PREPARE_MILLIS),
        )
    }

    @Test
    fun saysHowLongANoteRunsOnceItIsLoaded() {
        assertTrue(player.load(note) {}.isSuccess)

        assertEquals(DURATION_MILLIS.toLong(), player.duration())
        player.release()
    }

    @Test
    fun startsAtTheBeginningOfANoteItHasJustLoaded() {
        player.load(note) {}

        assertEquals(0L, player.position())
        player.release()
    }

    @Test
    fun reportsANoteTheDeviceWillNotPlay() {
        val unknown = folder.newFile("not-audio.m4a")

        assertTrue(player.load(unknown) {}.isFailure)
    }

    @Test
    fun saysNothingAboutAudioItWasNeverGiven() {
        assertEquals(0L, player.position())
        assertEquals(0L, player.duration())
    }

    @Test
    fun letsGoOfWhateverWasLoadedWhenItIsReleased() {
        player.load(note) {}

        player.release()

        assertEquals(0L, player.duration())
    }

    @Test
    fun doesNothingWhenThereIsNothingToPlayOrPause() {
        player.play()
        player.pause()

        assertEquals(0L, player.position())
    }

    @Test
    fun doesNothingWhenThereIsNothingToRelease() {
        player.release()

        assertEquals(0L, player.duration())
    }

    @Test
    fun pausesANoteThatIsPlaying() {
        player.load(note) {}
        player.play()

        player.pause()

        assertTrue(player.position() >= 0)
        player.release()
    }

    @Test
    fun letsGoOfTheOldNoteWhenAnotherOneIsLoaded() {
        val other = folder.newFile("other.m4a")
        ShadowMediaPlayer.addMediaInfo(
            DataSource.toDataSource(other.absolutePath),
            MediaInfo(OTHER_DURATION_MILLIS, PREPARE_MILLIS),
        )
        player.load(note) {}

        player.load(other) {}

        assertEquals(OTHER_DURATION_MILLIS.toLong(), player.duration())
        player.release()
    }

    @Test
    fun reportsAFileTheDeviceCannotRead() {
        val failing = player(onLoad = { throw IOException("Gone") })

        assertTrue(failing.load(note) {}.isFailure)
    }

    @Test
    fun reportsADeviceThatWasNotReadyToPlay() {
        val failing = player(onLoad = { throw IllegalStateException("Busy") })

        assertTrue(failing.load(note) {}.isFailure)
    }

    @Test
    fun reportsAFileTheDeviceMakesNoSenseOf() {
        val failing = player(onLoad = { throw IllegalArgumentException("Not a path") })

        assertTrue(failing.load(note) {}.isFailure)
    }

    @Test
    fun carriesOnWhenTheDeviceWillNotStart() {
        val failing = player(onPlay = { throw IllegalStateException("Not prepared") })
        failing.load(note) {}

        failing.play()

        assertEquals(DURATION_MILLIS.toLong(), failing.duration())
        failing.release()
    }

    @Test
    fun carriesOnWhenThereWasNothingToPause() {
        val failing = player(onPause = { throw IllegalStateException("Not playing") })
        failing.load(note) {}
        failing.play()

        failing.pause()

        assertEquals(DURATION_MILLIS.toLong(), failing.duration())
        failing.release()
    }

    @Test
    fun saysNothingAboutAudioTheDeviceHasAlreadyLetGoOf() {
        val failing = player(onPosition = { throw IllegalStateException("Released") })
        failing.load(note) {}

        assertEquals(0L, failing.position())
        failing.release()
    }

    @Test
    fun carriesOnWhenTheDeviceWasAlreadyGone() {
        val failing = player(onRelease = { throw RuntimeException("Already released") })
        failing.load(note) {}

        failing.release()

        assertEquals(0L, failing.duration())
    }

    /** A player that fails wherever the test says the device would. */
    private fun player(
        onLoad: () -> Unit = {},
        onPlay: () -> Unit = {},
        onPause: () -> Unit = {},
        onPosition: () -> Int = { 0 },
        onRelease: () -> Unit = {},
    ) = VoicePlayerDeviceDataSource(players = {
        object : MediaPlayer() {
            override fun prepare() {
                onLoad()
                super.prepare()
            }

            override fun start() {
                onPlay()
                super.start()
            }

            override fun pause() {
                onPause()
                super.pause()
            }

            override fun getCurrentPosition(): Int = onPosition()

            override fun release() {
                onRelease()
                super.release()
            }
        }
    })

    private companion object {
        const val DURATION_MILLIS = 3_000
        const val OTHER_DURATION_MILLIS = 5_000
        const val PREPARE_MILLIS = 0
    }
}

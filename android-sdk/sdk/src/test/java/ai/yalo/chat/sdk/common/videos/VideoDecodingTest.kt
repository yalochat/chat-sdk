// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.common.videos

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.shadows.ShadowMediaMetadataRetriever
import java.io.File

@RunWith(RobolectricTestRunner::class)
class VideoDecodingTest {

    @get:Rule
    val folder = TemporaryFolder()

    @After
    fun forgetTheVideos() {
        ShadowMediaMetadataRetriever.reset()
    }

    @Test
    fun readsTheFirstFrameAndTheLength() {
        val video = video(width = 640, height = 360, durationMillis = "9000")

        val frame = decodeVideo(video)

        assertEquals(640, frame?.poster?.width)
        assertEquals(9_000L, frame?.durationMillis)
    }

    @Test
    fun readsAVideoThatDoesNotSayHowLongItIsAsHavingNoLength() {
        val video = video(width = 640, height = 360, durationMillis = null)

        assertEquals(0L, decodeVideo(video)?.durationMillis)
    }

    @Test
    fun shrinksAFrameTooBigToHoldForOneBubble() {
        val video = video(width = 3_840, height = 2_160, durationMillis = "1000")

        val poster = decodeVideo(video)!!.poster

        assertTrue(poster.width.toLong() * poster.height <= 2_000_000)
        assertEquals(3_840f / 2_160f, poster.width.toFloat() / poster.height, 0.01f)
    }

    @Test
    fun readsNothingFromAFileThatIsNotAVideo() {
        assertNull(decodeVideo(folder.newFile("notes.txt")))
    }

    private fun video(width: Int, height: Int, durationMillis: String?): File {
        val file = folder.newFile("video.mp4")
        ShadowMediaMetadataRetriever.addFrame(
            file.absolutePath,
            0,
            Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888),
        )
        if (durationMillis != null) {
            ShadowMediaMetadataRetriever.addMetadata(
                file.absolutePath,
                MediaMetadataRetriever.METADATA_KEY_DURATION,
                durationMillis,
            )
        }
        return file
    }
}

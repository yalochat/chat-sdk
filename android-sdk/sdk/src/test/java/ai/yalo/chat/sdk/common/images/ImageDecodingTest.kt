// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.common.images

import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * How far a picture is shrunk before it is drawn. A conversation holds one
 * bitmap per message on screen, so a camera sized picture costs more memory
 * than the bubble it ends up in is worth.
 */
class ImageDecodingTest {

    @Test
    fun readsASmallPictureAsItIs() {
        assertEquals(1, sampleSizeFor(width = 800, height = 600, maxPixels = 2_000_000))
    }

    @Test
    fun halvesAPictureTwiceTheSizeItIsWorth() {
        assertEquals(2, sampleSizeFor(width = 3_000, height = 2_000, maxPixels = 2_000_000))
    }

    @Test
    fun keepsHalvingUntilAPictureFits() {
        assertEquals(8, sampleSizeFor(width = 12_000, height = 9_000, maxPixels = 2_000_000))
    }

    @Test
    fun readsAPictureOfNoSizeAsItIs() {
        assertEquals(1, sampleSizeFor(width = 0, height = 0, maxPixels = 2_000_000))
    }
}

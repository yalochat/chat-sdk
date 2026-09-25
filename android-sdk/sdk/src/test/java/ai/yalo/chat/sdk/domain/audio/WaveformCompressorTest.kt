// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.domain.audio

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class WaveformCompressorTest {

    @Test
    fun alwaysDrawsAsManyBarsAsItWasAskedFor() {
        val compressor = WaveformCompressor(8)

        compressor.push(0.5f)

        assertEquals(8, compressor.snapshot().size)
    }

    @Test
    fun spreadsAShortRecordingAcrossTheWholeWaveform() {
        val compressor = WaveformCompressor(4)

        compressor.push(0.6f)

        // One bar of sound is drawn as a full waveform rather than as a sliver
        // followed by silence, so a note just started still looks like a note.
        assertEquals(listOf(0.6f, 0.6f, 0.6f, 0.6f), compressor.snapshot())
    }

    @Test
    fun keepsTheLoudestMomentOfEveryBar() {
        val compressor = WaveformCompressor(2)

        // Four samples into two bars means two samples each, and once the bars
        // are full they are merged, so the loudest has to survive both steps.
        listOf(0.1f, 0.9f, 0.2f, 0.3f).forEach { sample -> compressor.push(sample) }

        assertTrue(compressor.snapshot().contains(0.9f))
    }

    @Test
    fun stillSpansTheRecordingOnceItHasRunLongerThanTheBars() {
        val compressor = WaveformCompressor(4)

        // Far more samples than bars: the first thing said has to still be in
        // the waveform, at the front, rather than having scrolled off it.
        compressor.push(1f)
        repeat(100) { compressor.push(0.1f) }

        val waveform = compressor.snapshot()
        assertEquals(4, waveform.size)
        assertEquals(1f, waveform.first(), TOLERANCE)
    }

    @Test
    fun forgetsEverythingWhenItIsReset() {
        val compressor = WaveformCompressor(3)
        compressor.push(0.8f)

        compressor.reset()

        assertEquals(listOf(0f, 0f, 0f), compressor.snapshot())
    }

    @Test
    fun hasNothingToDrawWhenItWasAskedForNoBars() {
        val compressor = WaveformCompressor(0)

        compressor.push(0.5f)

        assertEquals(emptyList<Float>(), compressor.snapshot())
    }

    private companion object {
        const val TOLERANCE = 0.0001f
    }
}

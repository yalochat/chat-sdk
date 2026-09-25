// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.voice

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class VoiceWaveformTest {

    @Test
    fun drawsOneBarPerAmplitude() {
        val bars = bars(amplitudes = listOf(0.1f, 0.5f, 1f))

        assertEquals(3, bars.size)
    }

    @Test
    fun sharesTheWidthEvenlyBetweenTheBars() {
        val bars = bars(amplitudes = listOf(0f, 0f, 0f, 0f), width = 100f)

        // Four bars in a hundred means a slot of twenty five each, and every bar
        // sits in the middle of its own slot.
        assertEquals(listOf(11f, 36f, 61f, 86f), bars.map { bar -> bar.left })
    }

    @Test
    fun neverDrawsABarWiderThanItWasAllowed() {
        val bars = bars(amplitudes = listOf(0f), width = 1_000f, maximumBarWidth = 3f)

        assertEquals(3f, bars.single().width, TOLERANCE)
    }

    @Test
    fun narrowsTheBarsRatherThanOverlappingThemWhenTheRoomRunsOut() {
        val bars = bars(amplitudes = List(50) { 0f }, width = 100f, maximumBarWidth = 3f)

        // Fifty bars in a hundred leaves two apiece, of which a bar takes its
        // share, so the gaps between them survive.
        assertTrue(bars.all { bar -> bar.width < 2f })
    }

    @Test
    fun leavesSilenceAsALineRatherThanAGap() {
        val bars = bars(amplitudes = listOf(0f), height = 40f, minimumBarHeight = 2f)

        assertEquals(2f, bars.single().height, TOLERANCE)
    }

    @Test
    fun drawsTheLoudestMomentAsTheFullHeight() {
        val bars = bars(amplitudes = listOf(1f), height = 40f)

        assertEquals(40f, bars.single().height, TOLERANCE)
    }

    @Test
    fun centresEveryBarOnTheLine() {
        val bars = bars(amplitudes = listOf(0f), height = 40f, minimumBarHeight = 2f)

        assertEquals(19f, bars.single().top, TOLERANCE)
    }

    @Test
    fun marksTheBarsBehindThePlayheadAsHeard() {
        val bars = bars(amplitudes = listOf(0f, 0f, 0f, 0f), progress = 0.5f)

        assertEquals(listOf(true, true, false, false), bars.map { bar -> bar.isPlayed })
    }

    @Test
    fun marksEveryBarAsHeardOnceTheNoteIsOver() {
        val bars = bars(amplitudes = listOf(0f, 0f), progress = 1f)

        assertTrue(bars.all { bar -> bar.isPlayed })
    }

    @Test
    fun keepsAProgressOutsideWhatIsPossibleInsideTheWaveform() {
        assertTrue(bars(amplitudes = listOf(0f, 0f), progress = 9f).all { bar -> bar.isPlayed })
        assertTrue(bars(amplitudes = listOf(0f, 0f), progress = -9f).none { bar -> bar.isPlayed })
    }

    @Test
    fun hasNothingToDrawWithoutAmplitudesOrRoom() {
        assertEquals(emptyList<WaveformBar>(), bars(amplitudes = emptyList()))
        assertEquals(emptyList<WaveformBar>(), bars(amplitudes = listOf(1f), width = 0f))
        assertEquals(emptyList<WaveformBar>(), bars(amplitudes = listOf(1f), height = 0f))
    }

    @Test
    fun writesALengthAsMinutesAndSeconds() {
        assertEquals("0:00", formatDuration(0))
        assertEquals("0:07", formatDuration(7_400))
        assertEquals("1:05", formatDuration(65_000))
        assertEquals("12:30", formatDuration(750_000))
    }

    @Test
    fun writesALengthThatMakesNoSenseAsNothing() {
        assertEquals("0:00", formatDuration(-1_000))
    }

    private fun bars(
        amplitudes: List<Float>,
        width: Float = 100f,
        height: Float = 40f,
        maximumBarWidth: Float = 3f,
        minimumBarHeight: Float = 2f,
        progress: Float = 1f,
    ): List<WaveformBar> = waveformBars(
        amplitudes = amplitudes,
        width = width,
        height = height,
        maximumBarWidth = maximumBarWidth,
        minimumBarHeight = minimumBarHeight,
        progress = progress,
    )

    private companion object {
        const val TOLERANCE = 0.0001f
    }
}

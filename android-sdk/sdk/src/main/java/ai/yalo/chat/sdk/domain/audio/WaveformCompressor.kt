// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.domain.audio

/**
 * Turns however many amplitude samples a recording produces into a fixed number
 * of bars, without keeping the samples.
 *
 * Each sample is folded into the bar being written with the loudest of the two
 * winning, so a quiet moment cannot hide a loud one. When the last bar is
 * written the bars are merged in pairs: the recording so far now fills the
 * first half, and every bar from then on covers twice as much time. Memory is
 * the same for a five second note and a five minute one, and the shape still
 * spans the whole recording.
 *
 * Carried over from the web SDK, which draws the same waveform from the same
 * algorithm, so a note recorded on either client looks the same.
 */
internal class WaveformCompressor(private val barCount: Int) {

    private var bars: FloatArray = FloatArray(barCount.coerceAtLeast(0))
    private var writeIndex = 0
    private var stride = 1
    private var samplesInBar = 0

    /** Folds [sample], between zero and one, into the waveform. */
    fun push(sample: Float) {
        if (barCount <= 0) {
            return
        }
        if (sample > bars[writeIndex]) {
            bars[writeIndex] = sample
        }
        samplesInBar++
        if (samplesInBar < stride) {
            return
        }
        samplesInBar = 0
        writeIndex++
        if (writeIndex < barCount) {
            return
        }
        halve()
    }

    /**
     * The waveform as it stands, always [barCount] bars long.
     *
     * A recording that has not filled the bars yet is stretched across all of
     * them, so a note one second in is drawn as wide as one a minute in rather
     * than as a sliver followed by silence.
     */
    fun snapshot(): List<Float> {
        if (barCount <= 0) {
            return emptyList()
        }
        val filled = writeIndex + if (samplesInBar > 0) 1 else 0
        if (filled <= 0 || filled >= barCount) {
            return bars.toList()
        }
        return List(barCount) { index -> bars[index * filled / barCount] }
    }

    fun reset() {
        bars = FloatArray(barCount.coerceAtLeast(0))
        writeIndex = 0
        stride = 1
        samplesInBar = 0
    }

    private fun halve() {
        val half = barCount / 2
        for (index in 0 until half) {
            bars[index] = maxOf(bars[2 * index], bars[2 * index + 1])
        }
        for (index in half until barCount) {
            bars[index] = 0f
        }
        writeIndex = half
        stride *= 2
    }
}

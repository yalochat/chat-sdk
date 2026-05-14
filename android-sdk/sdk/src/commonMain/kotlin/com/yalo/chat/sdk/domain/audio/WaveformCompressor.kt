// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.audio

import kotlin.math.max

// Streaming max-pool compressor with doubling stride. Each new sample is folded into
// the current bin using max-pooling. When the buffer fills, adjacent bins are pairwise
// merged so the older half of the recording lives in the first half of the buffer and
// the stride for new samples doubles. Memory stays O(binCount) regardless of recording
// length, and snapshot() always spans the entire recording uniformly.
//
// Mirrors Flutter WaveformCompressor introduced in PR #146.
internal class WaveformCompressor(
    val binCount: Int,
    val defaultValue: Double = -30.0,
) {
    init {
        // halve() merges pairs — an odd binCount silently drops the last bin.
        require(binCount == 0 || binCount % 2 == 0) { "binCount must be even (got $binCount)" }
    }

    private val bins = DoubleArray(binCount) { defaultValue }
    private var writeIdx = 0
    private var stride = 1
    private var countInBin = 0
    private var currentBinHasData = false

    fun pushSample(sample: Double) {
        if (binCount <= 0) return
        if (!currentBinHasData || sample > bins[writeIdx]) {
            bins[writeIdx] = sample
            currentBinHasData = true
        }
        countInBin++
        if (countInBin < stride) return
        countInBin = 0
        writeIdx++
        currentBinHasData = false
        if (writeIdx < binCount) return
        halve()
    }

    fun snapshot(): List<Double> {
        val filled = writeIdx + if (currentBinHasData) 1 else 0
        if (filled <= 0 || filled >= binCount) return bins.toList()
        return List(binCount) { i -> bins[(i * filled) / binCount] }
    }

    fun reset() {
        bins.fill(defaultValue)
        writeIdx = 0
        stride = 1
        countInBin = 0
        currentBinHasData = false
    }

    private fun halve() {
        val half = binCount / 2
        for (i in 0 until half) {
            bins[i] = max(bins[2 * i], bins[2 * i + 1])
        }
        for (i in half until binCount) {
            bins[i] = defaultValue
        }
        writeIdx = half
        stride *= 2
        currentBinHasData = false
    }
}

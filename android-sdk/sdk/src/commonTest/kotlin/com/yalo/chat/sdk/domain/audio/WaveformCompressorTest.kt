// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.audio

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

class WaveformCompressorTest {

    // ── Initial fill phase ────────────────────────────────────────────────────

    @Test
    fun `snapshot size is always binCount`() {
        val c = WaveformCompressor(binCount = 48, defaultValue = -30.0)
        assertEquals(48, c.snapshot().size)
        repeat(100) { c.pushSample(-20.0) }
        assertEquals(48, c.snapshot().size)
    }

    @Test
    fun `first sample appears in snapshot and is not defaultValue`() {
        val c = WaveformCompressor(binCount = 4, defaultValue = -30.0)
        c.pushSample(-10.0)
        assertTrue(c.snapshot().any { it > -30.0 })
    }

    @Test
    fun `filling exactly binCount samples produces no defaultValue bins`() {
        val c = WaveformCompressor(binCount = 4, defaultValue = -30.0)
        listOf(-10.0, -12.0, -8.0, -15.0).forEach { c.pushSample(it) }
        assertTrue(c.snapshot().none { it == -30.0 })
    }

    // ── Max-pool within a bin ─────────────────────────────────────────────────

    @Test
    fun `pushSample keeps global max somewhere in snapshot`() {
        val c = WaveformCompressor(binCount = 4, defaultValue = -30.0)
        listOf(-20.0, -5.0, -15.0, -18.0).forEach { c.pushSample(it) }
        // -5.0 is the loudest sample — it must survive max-pooling somewhere.
        val max = c.snapshot().max() ?: -100.0
        assertTrue(max >= -5.0 - 0.001)
    }

    // ── Halve (doubling stride) ───────────────────────────────────────────────

    @Test
    fun `halve preserves the maximum from each merged pair`() {
        val c = WaveformCompressor(binCount = 4, defaultValue = -30.0)
        // Pairs: (-10, -20) → max -10 ; (-5, -15) → max -5
        listOf(-10.0, -20.0, -5.0, -15.0).forEach { c.pushSample(it) }
        // After halving the snapshot must contain both maxima somewhere.
        val snap = c.snapshot()
        assertTrue(snap.any { it >= -10.0 - 0.001 })
        assertTrue(snap.any { it >= -5.0 - 0.001 })
    }

    @Test
    fun `values after halve can accept new samples without crashing`() {
        val c = WaveformCompressor(binCount = 4, defaultValue = -30.0)
        repeat(4) { c.pushSample(-20.0) }   // triggers halve, stride becomes 2
        c.pushSample(-5.0)
        c.pushSample(-15.0)
        assertEquals(4, c.snapshot().size)
        assertTrue(c.snapshot().max() ?: -100.0 >= -5.0 - 0.001)
    }

    // ── Reset ─────────────────────────────────────────────────────────────────

    @Test
    fun `reset restores all bins to defaultValue`() {
        val c = WaveformCompressor(binCount = 4, defaultValue = -30.0)
        repeat(10) { c.pushSample(-5.0) }
        c.reset()
        assertEquals(List(4) { -30.0 }, c.snapshot())
    }

    @Test
    fun `after reset new samples are accepted normally`() {
        val c = WaveformCompressor(binCount = 4, defaultValue = -30.0)
        repeat(100) { c.pushSample(-5.0) }
        c.reset()
        c.pushSample(-10.0)
        assertEquals(4, c.snapshot().size)
        assertTrue(c.snapshot().any { it > -30.0 })
    }

    // ── Edge cases ────────────────────────────────────────────────────────────

    @Test
    fun `odd binCount throws IllegalArgumentException`() {
        assertFailsWith<IllegalArgumentException> {
            WaveformCompressor(binCount = 3, defaultValue = -30.0)
        }
    }

    @Test
    fun `binCount zero produces empty snapshot without crash`() {
        val c = WaveformCompressor(binCount = 0, defaultValue = -30.0)
        c.pushSample(-10.0)
        assertEquals(0, c.snapshot().size)
    }

    @Test
    fun `long recording stays within binCount and never crashes`() {
        val c = WaveformCompressor(binCount = 48, defaultValue = -30.0)
        repeat(10_000) { i -> c.pushSample(-30.0 + (i % 30).toDouble()) }
        assertEquals(48, c.snapshot().size)
    }

    @Test
    fun `snapshot always spans entire recording — loudest sample survives`() {
        // Push a loud spike at the start, then many quiet samples.
        // The spike must still be representable in the final snapshot.
        val c = WaveformCompressor(binCount = 8, defaultValue = -30.0)
        c.pushSample(0.0)                          // loud spike
        repeat(1000) { c.pushSample(-30.0) }       // quiet tail
        assertTrue(c.snapshot().max() ?: -100.0 >= 0.0 - 0.001)
    }

    @Test
    fun `exact fill triggers halve — pair maxima survive in snapshot`() {
        val c = WaveformCompressor(binCount = 4, defaultValue = -30.0)
        // Pairs: (-5, -10) → max -5 ; (-15, -20) → max -15
        listOf(-5.0, -10.0, -15.0, -20.0).forEach { c.pushSample(it) }
        val snap = c.snapshot()
        // After halve, -10.0 and -20.0 are absorbed; only the pair maxima remain.
        assertEquals(setOf(-5.0, -15.0), snap.toSet())
    }
}

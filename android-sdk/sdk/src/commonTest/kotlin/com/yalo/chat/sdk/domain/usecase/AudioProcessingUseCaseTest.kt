// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.usecase

import kotlin.test.Test
import kotlin.test.assertEquals

class AudioProcessingUseCaseTest {

    private val useCase = AudioProcessingUseCase()

    // ── Initial fill phase (totalSamples <= totalBins) ────────────────────────

    @Test
    fun `first sample fills slot 0`() {
        val preview = List(4) { -30.0 }
        val result = useCase.compressWaveformForPreview(
            newPoint = -10.0,
            totalSamples = 1,
            preview = preview,
        )
        assertEquals(-10.0, result[0])
        assertEquals(-30.0, result[1])
        assertEquals(-30.0, result[2])
        assertEquals(-30.0, result[3])
    }

    @Test
    fun `last sample in initial fill phase fills last slot`() {
        val preview = List(4) { -30.0 }
        val result = useCase.compressWaveformForPreview(
            newPoint = -5.0,
            totalSamples = 4,
            preview = preview,
        )
        assertEquals(-5.0, result[3])
    }

    @Test
    fun `middle sample fills its slot without touching others`() {
        val preview = listOf(-10.0, -30.0, -30.0, -30.0)
        val result = useCase.compressWaveformForPreview(
            newPoint = -15.0,
            totalSamples = 2,
            preview = preview,
        )
        assertEquals(-10.0, result[0])
        assertEquals(-15.0, result[1])
        assertEquals(-30.0, result[2])
    }

    // ── Compression phase (totalSamples > totalBins) ──────────────────────────

    @Test
    fun `first sample past the window shifts and places newPoint at last slot`() {
        val preview = listOf(-10.0, -12.0, -14.0, -16.0)
        // totalSamples = 5, totalBins = 4 → targetBin = 5 % 4 = 1
        // slots 1..3 shift: result[1]=max(-12,-14)=-12, result[2]=-14, result[3]=-14 (result[2] from old)
        // ... then result[last] = newPoint
        val result = useCase.compressWaveformForPreview(
            newPoint = -20.0,
            totalSamples = 5,
            preview = preview,
        )
        assertEquals(-20.0, result[result.size - 1])
        assertEquals(preview.size, result.size)
    }

    @Test
    fun `compression keeps max when merging bins`() {
        // preview = [-30, -10, -5, -30], targetBin = 1 (totalSamples=5, bins=4)
        // slot 1 absorbs max(result[1], result[2]) = max(-10, -5) = -5
        val preview = listOf(-30.0, -10.0, -5.0, -30.0)
        val result = useCase.compressWaveformForPreview(
            newPoint = -20.0,
            totalSamples = 5,
            preview = preview,
        )
        assertEquals(-5.0, result[1])
    }

    @Test
    fun `result list size is always equal to preview size`() {
        val preview = List(48) { -30.0 }
        val result1 = useCase.compressWaveformForPreview(-10.0, 1, preview)
        val result2 = useCase.compressWaveformForPreview(-10.0, 48, preview)
        val result3 = useCase.compressWaveformForPreview(-10.0, 49, preview)
        assertEquals(48, result1.size)
        assertEquals(48, result2.size)
        assertEquals(48, result3.size)
    }

    @Test
    fun `input list is not mutated`() {
        val preview = List(4) { -30.0 }
        val original = preview.toList()
        useCase.compressWaveformForPreview(-10.0, 1, preview)
        assertEquals(original, preview)
    }

    @Test
    fun `sequential fill produces a window equal to the input samples`() {
        var preview = List(4) { -30.0 }
        val points = listOf(-10.0, -12.0, -8.0, -15.0)
        for ((index, point) in points.withIndex()) {
            preview = useCase.compressWaveformForPreview(
                newPoint = point,
                totalSamples = index + 1,
                preview = preview,
            )
        }
        assertEquals(points, preview)
    }

    @Test
    fun `one bin window always returns list containing only newPoint`() {
        val preview = listOf(-30.0)
        val result = useCase.compressWaveformForPreview(-10.0, 1, preview)
        assertEquals(listOf(-10.0), result)
    }
}

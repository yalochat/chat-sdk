// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ImageData
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class FakeAudioImageRepositoryTest {

    // ── FakeAudioRepository ──────────────────────────────────────────────────

    @Test
    fun `FakeAudioRepository startRecording returns Ok with file path`() = runTest {
        val result = FakeAudioRepository().startRecording()
        assertIs<Result.Ok<String>>(result)
        assertTrue(result.result.isNotEmpty())
    }

    @Test
    fun `FakeAudioRepository stopRecording returns Ok with AudioData`() = runTest {
        val result = FakeAudioRepository().stopRecording()
        assertIs<Result.Ok<AudioData>>(result)
        assertNotNull(result.result.fileName)
    }

    @Test
    fun `FakeAudioRepository play returns Ok`() = runTest {
        val result = FakeAudioRepository().play("fake_audio.mp4")
        assertIs<Result.Ok<Unit>>(result)
    }

    @Test
    fun `FakeAudioRepository stop returns Ok`() = runTest {
        val result = FakeAudioRepository().stop()
        assertIs<Result.Ok<Unit>>(result)
    }

    @Test
    fun `FakeAudioRepository amplitudeFlow emits configured values then completes`() = runTest {
        val values = listOf(-10.0, -20.0)
        val emissions = FakeAudioRepository(amplitudeValues = values).amplitudeFlow().toList()
        assertEquals(values, emissions)
    }

    @Test
    fun `FakeAudioRepository amplitudeFlow completes without emitting when given empty list`() = runTest {
        val emissions = FakeAudioRepository(amplitudeValues = emptyList()).amplitudeFlow().toList()
        assertTrue(emissions.isEmpty())
    }

    // ── FakeImageRepository ──────────────────────────────────────────────────

    @Test
    fun `FakeImageRepository pickFromGallery returns Ok with non-null path`() = runTest {
        val result = FakeImageRepository().pickFromGallery()
        assertIs<Result.Ok<ImageData>>(result)
        assertNotNull(result.result.path)
    }

    @Test
    fun `FakeImageRepository pickFromCamera returns Ok with non-null path`() = runTest {
        val result = FakeImageRepository().pickFromCamera()
        assertIs<Result.Ok<ImageData>>(result)
        assertNotNull(result.result.path)
    }
}

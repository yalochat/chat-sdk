// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.VoiceNote
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class VoiceNoteColumnTest {

    @Test
    fun readsBackEverythingARecordingCarries() {
        val note = VoiceNote(
            durationMillis = 4_200,
            amplitudes = listOf(0f, 0.5f, 1f),
            mediaUrl = "media-1",
            mediaType = "audio/mp4",
            fileName = "voice-1.m4a",
            byteCount = 2_048,
            localPath = "/files/voice-1.m4a",
        )

        assertEquals(note, VoiceNoteColumn.decode(VoiceNoteColumn.encode(note)))
    }

    @Test
    fun leavesTheColumnEmptyForAMessageWithNoRecording() {
        assertNull(VoiceNoteColumn.encode(null))
    }

    @Test
    fun readsAnEmptyColumnAsNoRecording() {
        assertNull(VoiceNoteColumn.decode(null))
        assertNull(VoiceNoteColumn.decode(""))
    }

    @Test
    fun readsSomethingThatIsNotARecordingAsNone() {
        assertNull(VoiceNoteColumn.decode("not json at all"))
    }

    @Test
    fun readsARecordingWrittenWithoutAWaveformAsOneWithNoBars() {
        val stored = VoiceNoteColumn.decode("""{"duration":1000}""")

        assertEquals(1_000L, stored?.durationMillis)
        assertEquals(emptyList<Float>(), stored?.amplitudes)
    }

    @Test
    fun keepsARecordingThatWasNeverMadeOnThisDeviceWithoutAFile() {
        val note = VoiceNote(durationMillis = 1_000, mediaUrl = "https://media.example.com/1")

        assertNull(VoiceNoteColumn.decode(VoiceNoteColumn.encode(note))?.localPath)
    }
}

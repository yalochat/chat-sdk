// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.VideoAttachment
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class VideoAttachmentColumnTest {

    @Test
    fun readsBackEverythingAVideoCarries() {
        val video = VideoAttachment(
            mediaUrl = "https://yalo.com/setup.mp4",
            mediaType = "video/mp4",
            fileName = "setup.mp4",
            byteCount = 1_048_576,
            durationMillis = 42_500,
        )

        assertEquals(video, VideoAttachmentColumn.decode(VideoAttachmentColumn.encode(video)))
    }

    @Test
    fun leavesTheColumnEmptyForAMessageWithNoVideo() {
        assertNull(VideoAttachmentColumn.encode(null))
    }

    @Test
    fun readsAnEmptyColumnAsNoVideo() {
        assertNull(VideoAttachmentColumn.decode(null))
        assertNull(VideoAttachmentColumn.decode(""))
    }

    @Test
    fun readsSomethingThatIsNotAVideoAsNone() {
        assertNull(VideoAttachmentColumn.decode("not json at all"))
    }

    @Test
    fun readsAVideoWrittenWithoutALengthAsOneOfNoLength() {
        val stored = VideoAttachmentColumn.decode("""{"mediaUrl":"media-1"}""")

        assertEquals("media-1", stored?.mediaUrl)
        assertEquals(0L, stored?.durationMillis)
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.ImageAttachment
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ImageAttachmentColumnTest {

    @Test
    fun readsBackEverythingAPictureCarries() {
        val picture = ImageAttachment(
            mediaUrl = "media-1",
            mediaType = "image/jpeg",
            fileName = "holiday.jpg",
            byteCount = 4_096,
            localPath = "/files/image-1.jpg",
        )

        assertEquals(picture, ImageAttachmentColumn.decode(ImageAttachmentColumn.encode(picture)))
    }

    @Test
    fun leavesTheColumnEmptyForAMessageWithNoPicture() {
        assertNull(ImageAttachmentColumn.encode(null))
    }

    @Test
    fun readsAnEmptyColumnAsNoPicture() {
        assertNull(ImageAttachmentColumn.decode(null))
        assertNull(ImageAttachmentColumn.decode(""))
    }

    @Test
    fun readsSomethingThatIsNotAPictureAsNone() {
        assertNull(ImageAttachmentColumn.decode("not json at all"))
    }

    @Test
    fun readsAPictureWrittenWithoutASizeAsOneOfNoSize() {
        val stored = ImageAttachmentColumn.decode("""{"mediaUrl":"media-1"}""")

        assertEquals("media-1", stored?.mediaUrl)
        assertEquals(0L, stored?.byteCount)
    }

    @Test
    fun keepsAPictureThatWasNeverOnThisDeviceWithoutAFile() {
        val picture = ImageAttachment(mediaUrl = "https://media.example.com/shirt.png")

        assertNull(ImageAttachmentColumn.decode(ImageAttachmentColumn.encode(picture))?.localPath)
    }
}

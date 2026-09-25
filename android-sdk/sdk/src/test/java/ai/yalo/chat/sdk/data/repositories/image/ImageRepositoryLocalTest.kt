// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.image

import ai.yalo.chat.sdk.data.datasources.image.ImageDataSource
import ai.yalo.chat.sdk.data.datasources.media.MediaContent
import android.net.Uri
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.io.ByteArrayInputStream
import java.io.File
import java.io.IOException
import java.io.InputStream

@RunWith(RobolectricTestRunner::class)
class ImageRepositoryLocalTest {

    @get:Rule
    val folder = TemporaryFolder()

    private val source = FakeImageDataSource()

    @Test
    fun keepsACopyOfWhatWasPicked() = runBlocking {
        val picture = repository().store(PICKED).getOrThrow()

        val copy = File(picture.localPath.orEmpty())
        assertTrue(copy.exists())
        assertEquals(PICTURE_BYTES.size, copy.readBytes().size)
    }

    @Test
    fun describesWhatWasPickedAsTheDeviceNamedIt() = runBlocking {
        val picture = repository().store(PICKED).getOrThrow()

        assertEquals("holiday.jpg", picture.fileName)
        assertEquals("image/jpeg", picture.mediaType)
        assertEquals(PICTURE_BYTES.size.toLong(), picture.byteCount)
    }

    // A picture only has an address once it has been uploaded, which is not
    // something this knows about.
    @Test
    fun leavesAPictureNobodyHasUploadedWithoutAnAddress() = runBlocking {
        assertEquals("", repository().store(PICKED).getOrThrow().mediaUrl)
    }

    @Test
    fun keepsTwoPicturesOfTheSameNameApart() = runBlocking {
        val repository = repository()

        val first = repository.store(PICKED).getOrThrow()
        val second = repository.store(PICKED).getOrThrow()

        assertNotEquals(first.localPath, second.localPath)
    }

    @Test
    fun keepsTheCopyUnderTheNameTheDeviceGaveItsKind() = runBlocking {
        val picture = repository(from = 7L).store(PICKED).getOrThrow()

        assertEquals("image-7.jpg", File(picture.localPath.orEmpty()).name)
    }

    @Test
    fun keepsAPictureWhoseNameSaysNothingAboutItsKind() = runBlocking {
        source.answer = mediaContent(fileName = "holiday")

        val picture = repository(from = 7L).store(PICKED).getOrThrow()

        assertEquals("image-7", File(picture.localPath.orEmpty()).name)
    }

    @Test
    fun reportsAPictureTheDeviceWillNotDescribe() = runBlocking {
        source.answer = null

        val result = repository().store(PICKED)

        assertTrue(result.exceptionOrNull() is IOException)
    }

    @Test
    fun leavesNothingBehindWhenThePictureCannotBeRead() = runBlocking {
        source.answer = mediaContent(openStream = { throw IOException("gone") })

        val result = repository(from = 7L).store(PICKED)

        assertTrue(result.exceptionOrNull() is IOException)
        assertFalse(File(imagesDir(), "image-7.jpg").exists())
    }

    private fun imagesDir(): File = File(folder.root, "images")

    private fun repository(from: Long = 1L): ImageRepositoryLocal {
        var tick = from
        return ImageRepositoryLocal(
            source = source,
            imagesDir = imagesDir(),
            dispatcher = Dispatchers.Unconfined,
            now = { tick++ },
        )
    }

    private fun mediaContent(
        fileName: String = "holiday.jpg",
        mimeType: String = "image/jpeg",
        openStream: () -> InputStream = { ByteArrayInputStream(PICTURE_BYTES) },
    ): MediaContent = MediaContent(
        fileName = fileName,
        mimeType = mimeType,
        sizeBytes = PICTURE_BYTES.size.toLong(),
        openStream = openStream,
    )

    /** Stands in for the gallery, so a test says what the device answers. */
    private inner class FakeImageDataSource : ImageDataSource {

        var answer: MediaContent? = mediaContent()

        override fun content(uri: Uri): MediaContent? = answer
    }

    private companion object {

        val PICKED: Uri = Uri.parse("content://media/external/images/media/1")
        val PICTURE_BYTES = ByteArray(1_024) { index -> index.toByte() }
    }
}

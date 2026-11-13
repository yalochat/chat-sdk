// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.image

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.content.pm.ProviderInfo
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.Bundle
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.OpenableColumns
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowContentResolver
import java.io.ByteArrayInputStream

@RunWith(RobolectricTestRunner::class)
class ImageDeviceDataSourceTest {

    private val context: Context = RuntimeEnvironment.getApplication()
    private val uri: Uri = Uri.parse("content://$AUTHORITY/1")

    @Test
    fun describesWhatTheGalleryHandedOver() {
        registerPicture()

        val content = ImageDeviceDataSource(context).content(uri)

        assertEquals("holiday.jpg", content?.fileName)
        assertEquals("image/jpeg", content?.mimeType)
        assertEquals("the-bytes", content?.openStream?.invoke()?.readBytes()?.decodeToString())
    }

    @Test
    fun saysNothingAboutAPictureTheDeviceWillNotDescribe() {
        assertNull(ImageDeviceDataSource(context).content(uri))
    }

    @Test
    fun readsTheFolderOfAFilePickedFromStorage() {
        val picked = DocumentsContract.buildDocumentUri(EXTERNAL_STORAGE, "primary:DCIM/Screenshots/a.png")

        assertEquals("DCIM/Screenshots", ImageDeviceDataSource(context).folder(picked))
    }

    @Test
    fun readsTheFolderOfAFilePickedFromTheImagesView() {
        registerMediaPicture(relativePath = "Pictures/Screenshots/")

        assertEquals("Pictures/Screenshots", ImageDeviceDataSource(context).folder(MEDIA_DOCUMENT))
    }

    @Test
    @Config(sdk = [28])
    fun saysNothingAboutTheImagesViewBeforeAndroid10() {
        registerMediaPicture(relativePath = "Pictures/Screenshots/")

        assertNull(ImageDeviceDataSource(context).folder(MEDIA_DOCUMENT))
    }

    @Test
    fun saysNothingAboutTheFolderOfAPictureFromAnotherApp() {
        assertNull(ImageDeviceDataSource(context).folder(uri))
    }

    @Test
    fun saysNothingAboutAnAddressThatIsNotADocument() {
        val notADocument = Uri.parse("content://$EXTERNAL_STORAGE/root/primary")

        assertNull(ImageDeviceDataSource(context).folder(notADocument))
    }

    private fun registerMediaPicture(relativePath: String) {
        val media = FakeMediaProvider(relativePath)
        media.attachInfo(context, ProviderInfo().apply { authority = MediaStore.AUTHORITY })
        ShadowContentResolver.registerProviderInternal(MediaStore.AUTHORITY, media)
    }

    private fun registerPicture() {
        val provider = FakeGalleryProvider()
        provider.attachInfo(context, ProviderInfo().apply { authority = AUTHORITY })
        ShadowContentResolver.registerProviderInternal(AUTHORITY, provider)
        shadowOf(context.contentResolver)
            .registerInputStreamSupplier(uri) { ByteArrayInputStream("the-bytes".toByteArray()) }
    }

    private class FakeGalleryProvider : ContentProvider() {

        override fun onCreate(): Boolean = true

        override fun getType(uri: Uri): String = "image/jpeg"

        override fun query(
            uri: Uri,
            projection: Array<out String>?,
            selection: String?,
            selectionArgs: Array<out String>?,
            sortOrder: String?,
        ): Cursor = MatrixCursor(arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE))
            .apply { addRow(arrayOf("holiday.jpg", 9L)) }

        override fun insert(uri: Uri, values: ContentValues?): Uri? = null

        override fun update(
            uri: Uri,
            values: ContentValues?,
            selection: String?,
            selectionArgs: Array<out String>?,
        ): Int = 0

        override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0
    }

    /** Turns a document address into a media one and describes it, as the media provider does. */
    private class FakeMediaProvider(private val relativePath: String) : FakeProvider() {

        override fun call(method: String, arg: String?, extras: Bundle?): Bundle =
            Bundle().apply { putParcelable("uri", MEDIA_ITEM) }

        override fun query(
            uri: Uri,
            projection: Array<out String>?,
            selection: String?,
            selectionArgs: Array<out String>?,
            sortOrder: String?,
        ): Cursor = MatrixCursor(arrayOf(MediaStore.MediaColumns.RELATIVE_PATH))
            .apply { addRow(arrayOf(relativePath)) }
    }

    private abstract class FakeProvider : ContentProvider() {

        override fun onCreate(): Boolean = true

        override fun getType(uri: Uri): String = "image/png"

        override fun query(
            uri: Uri,
            projection: Array<out String>?,
            selection: String?,
            selectionArgs: Array<out String>?,
            sortOrder: String?,
        ): Cursor? = null

        override fun insert(uri: Uri, values: ContentValues?): Uri? = null

        override fun update(
            uri: Uri,
            values: ContentValues?,
            selection: String?,
            selectionArgs: Array<out String>?,
        ): Int = 0

        override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0
    }

    private companion object {
        const val AUTHORITY = "ai.yalo.chat.sdk.test.gallery"
        const val EXTERNAL_STORAGE = "com.android.externalstorage.documents"
        const val MEDIA_DOCUMENTS = "com.android.providers.media.documents"
        val MEDIA_DOCUMENT: Uri = DocumentsContract.buildDocumentUri(MEDIA_DOCUMENTS, "image:1234")
        val MEDIA_ITEM: Uri = Uri.parse("content://media/external/images/media/1234")
    }
}

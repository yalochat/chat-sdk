// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.image

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.content.pm.ProviderInfo
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.provider.OpenableColumns
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
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

    private companion object {
        const val AUTHORITY = "ai.yalo.chat.sdk.test.gallery"
    }
}

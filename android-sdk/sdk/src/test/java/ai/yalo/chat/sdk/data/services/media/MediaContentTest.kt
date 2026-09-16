// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.media

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
import org.junit.Assert.assertThrows
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.shadows.ShadowContentResolver
import java.io.ByteArrayInputStream
import java.io.FileNotFoundException

@RunWith(RobolectricTestRunner::class)
class MediaContentTest {

    private val context: Context = RuntimeEnvironment.getApplication()
    private val uri: Uri = Uri.parse("content://$AUTHORITY/1")

    @Test
    fun describesWhatTheDeviceSaysAboutTheFile() {
        register(mimeType = "image/jpeg", displayName = "holiday.jpg", size = 9L)

        val content = MediaContent.of(context, uri)

        assertEquals("holiday.jpg", content?.fileName)
        assertEquals("image/jpeg", content?.mimeType)
        assertEquals(9L, content?.sizeBytes)
    }

    @Test
    fun readsTheContentTheUriPointsAt() {
        register(payload = "the-bytes")

        val content = MediaContent.of(context, uri)

        assertEquals("the-bytes", content?.openStream?.invoke()?.readBytes()?.decodeToString())
    }

    // An upload that has to be sent a second time reads the content again, so
    // a stream that was already drained would send an empty file.
    @Test
    fun opensAFreshStreamEveryTimeItIsAsked() {
        register(payload = "the-bytes")
        val content = requireNotNull(MediaContent.of(context, uri))

        content.openStream().readBytes()
        val second = content.openStream().readBytes().decodeToString()

        assertEquals("the-bytes", second)
    }

    @Test
    fun hasNothingToUploadWhenTheDeviceWillNotSayWhatTheFileIs() {
        register(mimeType = null)

        assertNull(MediaContent.of(context, uri))
    }

    @Test
    fun hasNothingToUploadWhenTheDeviceKnowsNothingAboutTheUri() {
        assertNull(MediaContent.of(context, uri))
    }

    // A null size reads back as zero, which would promise the backend a file
    // and then send it nothing.
    @Test
    fun hasNothingToUploadWhenTheSizeIsMissing() {
        register(size = null)

        assertNull(MediaContent.of(context, uri))
    }

    @Test
    fun hasNothingToUploadWhenTheNameIsMissing() {
        register(displayName = null)

        assertNull(MediaContent.of(context, uri))
    }

    @Test
    fun hasNothingToUploadWhenTheUriDescribesNoRows() {
        register(rows = false)

        assertNull(MediaContent.of(context, uri))
    }

    @Test
    fun hasNothingToUploadWhenTheUriCannotBeDescribedAtAll() {
        register(describes = false)
        assertNull(MediaContent.of(context, uri))
    }

    @Test
    fun raisesWhenTheContentIsGoneByTheTimeItIsRead() {
        register()
        shadowOf(context.contentResolver).registerInputStreamSupplier(uri) { null }
        val content = requireNotNull(MediaContent.of(context, uri))

        assertThrows(FileNotFoundException::class.java) { content.openStream() }
    }

    private fun register(
        mimeType: String? = "image/jpeg",
        displayName: String? = "photo.jpg",
        size: Long? = 5L,
        rows: Boolean = true,
        describes: Boolean = true,
        payload: String = "hello",
    ) {
        val provider = FakeMediaProvider(mimeType, displayName, size, rows, describes)
        provider.attachInfo(context, ProviderInfo().apply { authority = AUTHORITY })
        ShadowContentResolver.registerProviderInternal(AUTHORITY, provider)
        // The supplier form, not registerInputStream: that one hands back the
        // same stream every time, which would hide a body that can only be sent
        // once.
        shadowOf(context.contentResolver)
            .registerInputStreamSupplier(uri) { ByteArrayInputStream(payload.toByteArray()) }
    }

    private class FakeMediaProvider(
        private val mimeType: String?,
        private val displayName: String?,
        private val size: Long?,
        private val rows: Boolean,
        private val describes: Boolean,
    ) : ContentProvider() {

        override fun onCreate(): Boolean = true

        override fun getType(uri: Uri): String? = mimeType

        override fun query(
            uri: Uri,
            projection: Array<out String>?,
            selection: String?,
            selectionArgs: Array<out String>?,
            sortOrder: String?,
        ): Cursor? {
            if (!describes) {
                return null
            }
            return MatrixCursor(arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE))
                .apply {
                    if (rows) {
                        addRow(arrayOf(displayName, size))
                    }
                }
        }

        override fun insert(uri: Uri, values: ContentValues?): Uri? = null

        override fun update(
            uri: Uri,
            values: ContentValues?,
            selection: String?,
            selectionArgs: Array<out String>?,
        ): Int = 0

        override fun delete(
            uri: Uri,
            selection: String?,
            selectionArgs: Array<out String>?,
        ): Int = 0
    }

    private companion object {
        private const val AUTHORITY = "media-test"
    }
}

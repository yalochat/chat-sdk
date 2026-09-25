// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.image

import ai.yalo.chat.sdk.data.datasources.media.MediaContent
import android.content.Context
import android.net.Uri

/** Reads whatever the person picked out of the gallery. */
internal interface ImageDataSource {

    /**
     * Describes what [uri] points at, or nothing when the device will not say.
     * Blocking, because it asks another process.
     */
    fun content(uri: Uri): MediaContent?
}

/** The device's own answer, through the content resolver. */
internal class ImageDeviceDataSource(context: Context) : ImageDataSource {

    private val applicationContext: Context = context.applicationContext

    override fun content(uri: Uri): MediaContent? = MediaContent.of(applicationContext, uri)
}

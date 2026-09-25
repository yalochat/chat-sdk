// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.images

import android.graphics.BitmapFactory
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import java.io.File

/** How many pixels of a picture are worth holding to draw one bubble. */
private const val MAX_PIXELS = 2_000_000

/**
 * Reads [file] as a picture, small enough to draw without holding a camera
 * sized bitmap for every message in the conversation, or nothing when the file
 * is not a picture at all.
 *
 * Blocking, so call it off the main thread.
 */
internal fun decodeImage(file: File, maxPixels: Int = MAX_PIXELS): ImageBitmap? {
    val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
    BitmapFactory.decodeFile(file.absolutePath, bounds)
    val options = BitmapFactory.Options().apply {
        inSampleSize = sampleSizeFor(bounds.outWidth, bounds.outHeight, maxPixels)
    }
    return BitmapFactory.decodeFile(file.absolutePath, options)?.asImageBitmap()
}

/**
 * How many times over to halve a picture of [width] by [height] before it fits
 * in [maxPixels]. Always a power of two, which is the only step the decoder
 * takes.
 */
internal fun sampleSizeFor(width: Int, height: Int, maxPixels: Int): Int {
    if (width <= 0 || height <= 0 || maxPixels <= 0) {
        return 1
    }
    var sampleSize = 1
    while (width.toLong() * height / (sampleSize.toLong() * sampleSize) > maxPixels) {
        sampleSize *= 2
    }
    return sampleSize
}

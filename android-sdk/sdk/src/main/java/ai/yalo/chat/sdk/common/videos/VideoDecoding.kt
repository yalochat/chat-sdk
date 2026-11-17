// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.common.videos

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import androidx.core.graphics.scale
import java.io.File
import kotlin.math.sqrt

/** How many pixels of a frame are worth holding to draw one bubble. */
private const val MAX_PIXELS = 2_000_000

/** What a bubble shows of a video before it is played. */
internal class VideoFrame(val poster: Bitmap, val durationMillis: Long)

/**
 * Reads the first frame and the length of the video in [file], or nothing when
 * the file is not a video the device can read.
 *
 * Blocking, so call it off the main thread.
 */
internal fun decodeVideo(file: File): VideoFrame? {
    val retriever = MediaMetadataRetriever()
    return try {
        retriever.setDataSource(file.absolutePath)
        val frame = retriever.getFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC) ?: return null
        val duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0
        VideoFrame(poster = shrunk(frame), durationMillis = duration)
    } catch (error: RuntimeException) {
        null
    } finally {
        retriever.release()
    }
}

private fun shrunk(frame: Bitmap): Bitmap {
    val pixels = frame.width.toLong() * frame.height
    if (pixels <= MAX_PIXELS) {
        return frame
    }
    val scale = sqrt(MAX_PIXELS.toDouble() / pixels)
    return frame.scale((frame.width * scale).toInt(), (frame.height * scale).toInt())
}

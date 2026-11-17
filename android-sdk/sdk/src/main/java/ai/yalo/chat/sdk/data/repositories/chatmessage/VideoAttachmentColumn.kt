// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.VideoAttachment
import org.json.JSONException
import org.json.JSONObject

/**
 * Says what a video message's video looks like in one database column, the
 * same way [ImageAttachmentColumn] does for a picture.
 */
internal object VideoAttachmentColumn {

    private const val MEDIA_URL = "mediaUrl"
    private const val MEDIA_TYPE = "mediaType"
    private const val FILE_NAME = "fileName"
    private const val BYTE_COUNT = "byteCount"
    private const val DURATION_MILLIS = "durationMillis"

    /** Null for a message that carries no video, so the column stays empty. */
    fun encode(video: VideoAttachment?): String? {
        if (video == null) {
            return null
        }
        return JSONObject()
            .put(MEDIA_URL, video.mediaUrl)
            .put(MEDIA_TYPE, video.mediaType)
            .put(FILE_NAME, video.fileName)
            .put(BYTE_COUNT, video.byteCount)
            .put(DURATION_MILLIS, video.durationMillis)
            .toString()
    }

    fun decode(stored: String?): VideoAttachment? {
        if (stored.isNullOrEmpty()) {
            return null
        }
        return try {
            val fields = JSONObject(stored)
            VideoAttachment(
                mediaUrl = fields.optString(MEDIA_URL),
                mediaType = fields.optString(MEDIA_TYPE),
                fileName = fields.optString(FILE_NAME),
                byteCount = fields.optLong(BYTE_COUNT),
                durationMillis = fields.optLong(DURATION_MILLIS),
            )
        } catch (error: JSONException) {
            null
        }
    }
}

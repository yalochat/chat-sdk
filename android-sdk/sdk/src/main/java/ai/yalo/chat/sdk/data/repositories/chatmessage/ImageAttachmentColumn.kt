// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.ImageAttachment
import org.json.JSONException
import org.json.JSONObject

/**
 * Says what an image message's picture looks like in one database column.
 *
 * Kept whole in a single column because it is written once and read whole, and
 * nothing is ever searched on. A row written by a newer version, or by nothing
 * at all, still has to read back as a message, so anything that is not a
 * picture reads as none rather than breaking the conversation.
 */
internal object ImageAttachmentColumn {

    private const val MEDIA_URL = "mediaUrl"
    private const val MEDIA_TYPE = "mediaType"
    private const val FILE_NAME = "fileName"
    private const val BYTE_COUNT = "byteCount"
    private const val LOCAL_PATH = "localPath"

    /** Null for a message that carries no picture, so the column stays empty. */
    fun encode(image: ImageAttachment?): String? {
        if (image == null) {
            return null
        }
        return JSONObject()
            .put(MEDIA_URL, image.mediaUrl)
            .put(MEDIA_TYPE, image.mediaType)
            .put(FILE_NAME, image.fileName)
            .put(BYTE_COUNT, image.byteCount)
            .put(LOCAL_PATH, image.localPath)
            .toString()
    }

    fun decode(stored: String?): ImageAttachment? {
        if (stored.isNullOrEmpty()) {
            return null
        }
        return try {
            val fields = JSONObject(stored)
            ImageAttachment(
                mediaUrl = fields.optString(MEDIA_URL),
                mediaType = fields.optString(MEDIA_TYPE),
                fileName = fields.optString(FILE_NAME),
                byteCount = fields.optLong(BYTE_COUNT),
                localPath = fields.optString(LOCAL_PATH).takeIf { path -> path.isNotEmpty() },
            )
        } catch (error: JSONException) {
            null
        }
    }
}

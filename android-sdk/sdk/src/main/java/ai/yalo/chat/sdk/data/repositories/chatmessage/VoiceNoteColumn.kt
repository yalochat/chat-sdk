// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.VoiceNote
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/**
 * Says what a voice message's recording looks like in one database column.
 *
 * Kept whole in a single column because it is written once and read whole, and
 * nothing is ever searched on. A row written by a newer version, or by nothing
 * at all, still has to read back as a message, so anything that is not a
 * recording reads as none rather than breaking the conversation.
 */
internal object VoiceNoteColumn {

    private const val DURATION = "duration"
    private const val AMPLITUDES = "amplitudes"
    private const val MEDIA_URL = "mediaUrl"
    private const val MEDIA_TYPE = "mediaType"
    private const val FILE_NAME = "fileName"
    private const val BYTE_COUNT = "byteCount"
    private const val LOCAL_PATH = "localPath"

    /** Null for a message that carries no recording, so the column stays empty. */
    fun encode(note: VoiceNote?): String? {
        if (note == null) {
            return null
        }
        val amplitudes = JSONArray()
        note.amplitudes.forEach { level -> amplitudes.put(level.toDouble()) }
        return JSONObject()
            .put(DURATION, note.durationMillis)
            .put(AMPLITUDES, amplitudes)
            .put(MEDIA_URL, note.mediaUrl)
            .put(MEDIA_TYPE, note.mediaType)
            .put(FILE_NAME, note.fileName)
            .put(BYTE_COUNT, note.byteCount)
            .put(LOCAL_PATH, note.localPath)
            .toString()
    }

    fun decode(stored: String?): VoiceNote? {
        if (stored.isNullOrEmpty()) {
            return null
        }
        return try {
            val fields = JSONObject(stored)
            VoiceNote(
                durationMillis = fields.optLong(DURATION),
                amplitudes = amplitudesOf(fields.optJSONArray(AMPLITUDES)),
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

    private fun amplitudesOf(stored: JSONArray?): List<Float> {
        if (stored == null) {
            return emptyList()
        }
        return (0 until stored.length()).map { index -> stored.optDouble(index, 0.0).toFloat() }
    }
}

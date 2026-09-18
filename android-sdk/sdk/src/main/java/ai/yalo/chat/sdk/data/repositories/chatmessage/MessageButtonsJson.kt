// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.domain.models.MessageButtonType
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/**
 * Says what a message's buttons look like in one database column.
 *
 * A row written by a newer version, or by nothing at all, still has to read
 * back as a message, so anything that is not a list of buttons reads as none
 * rather than breaking the conversation.
 */
internal object MessageButtonsJson {

    private const val TEXT = "text"
    private const val TYPE = "type"
    private const val URL = "url"

    /** Null for a message with no buttons, so the column stays empty. */
    fun encode(buttons: List<MessageButton>): String? {
        if (buttons.isEmpty()) {
            return null
        }
        val array = JSONArray()
        buttons.forEach { button ->
            array.put(
                JSONObject()
                    .put(TEXT, button.text)
                    .put(TYPE, button.type.wireName)
                    .put(URL, button.url),
            )
        }
        return array.toString()
    }

    fun decode(stored: String?): List<MessageButton> {
        if (stored.isNullOrEmpty()) {
            return emptyList()
        }
        return try {
            val array = JSONArray(stored)
            (0 until array.length()).mapNotNull { index ->
                array.optJSONObject(index)?.let { button -> buttonOf(button) }
            }
        } catch (error: JSONException) {
            emptyList()
        }
    }

    private fun buttonOf(stored: JSONObject): MessageButton? {
        val text = stored.optString(TEXT)
        if (text.isEmpty()) {
            return null
        }
        return MessageButton(
            text = text,
            type = MessageButtonType.of(stored.optString(TYPE)),
            url = stored.optString(URL).takeIf { url -> url.isNotEmpty() },
        )
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.domain.models

/** Who wrote a message. */
internal enum class MessageRole(val wireName: String) {
    User("USER"),
    Agent("AGENT"),
    ;

    companion object {
        fun of(wireName: String): MessageRole = entries.first { it.wireName == wireName }
    }
}

/**
 * What a message carries.
 *
 * The full vocabulary the backend can send, even though the SDK only renders
 * some of it so far. [Unknown] is what an unrecognised value reads back as, so
 * a newer backend cannot break an older app.
 */
internal enum class MessageType(val wireName: String) {
    Text("text"),
    Image("image"),
    Voice("voice"),
    Product("product"),
    ProductCarousel("productCarousel"),
    ProductConfirmation("productConfirmation"),
    Promotion("promotion"),
    Video("video"),
    Attachment("attachment"),
    ChatStatus("chat-status"),
    Unknown("unknown"),
    ;

    companion object {
        fun of(wireName: String): MessageType =
            entries.firstOrNull { it.wireName == wireName } ?: Unknown
    }
}

/** How far a message got. */
internal enum class MessageStatus(val wireName: String) {
    Delivered("DELIVERED"),
    Read("READ"),
    Error("ERROR"),
    Sent("SENT"),
    InProgress("IN_PROGRESS"),
    Clicked("CLICKED"),
    ;

    companion object {
        fun of(wireName: String): MessageStatus = entries.first { it.wireName == wireName }

        /** What [wireName] means, or [fallback] when it is one this SDK does not know. */
        fun of(wireName: String, fallback: MessageStatus): MessageStatus =
            entries.firstOrNull { status -> status.wireName == wireName } ?: fallback
    }
}

/** What tapping a button attached to a message does. */
internal enum class MessageButtonType(val wireName: String) {
    Reply("reply"),
    Postback("postback"),
    Link("link"),
    ;

    companion object {
        /** What [wireName] means, or [Reply] when it is one this SDK does not know. */
        fun of(wireName: String): MessageButtonType =
            entries.firstOrNull { type -> type.wireName == wireName } ?: Reply
    }
}

/**
 * A tappable option the channel attached to a message.
 *
 * [url] is only meaningful for a [MessageButtonType.Link], which is the one
 * kind that leaves the conversation.
 */
internal data class MessageButton(
    val text: String,
    val type: MessageButtonType = MessageButtonType.Reply,
    val url: String? = null,
)

/**
 * One message in a conversation.
 *
 * [id] is the local row and is null until the message is stored. [wiId] is the
 * backend's id and is null for a message the user has just written, which is
 * why the two cannot be the same field.
 *
 * [timestamp] is epoch milliseconds. It is passed in rather than read from the
 * clock so that whoever creates the message decides what time it happened.
 *
 * [voice] is the recording a [MessageType.Voice] message carries, and [image]
 * the picture a [MessageType.Image] message carries. Each is null for every
 * other kind.
 */
internal data class ChatMessage(
    val role: MessageRole,
    val type: MessageType,
    val timestamp: Long,
    val id: Long? = null,
    val wiId: String? = null,
    val content: String = "",
    val status: MessageStatus = MessageStatus.InProgress,
    val header: String? = null,
    val footer: String? = null,
    val buttons: List<MessageButton> = emptyList(),
    val voice: VoiceNote? = null,
    val image: ImageAttachment? = null,
)

/**
 * The buttons that answer the message rather than doing something else with it.
 *
 * These are what the chat offers as quick replies. Tapping one says its text
 * back to the channel, so the person picks an answer instead of typing it.
 */
internal val ChatMessage.quickReplies: List<MessageButton>
    get() = buttons.filter { button -> button.type == MessageButtonType.Reply }

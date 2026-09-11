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
    }
}

/**
 * One message in a conversation.
 *
 * [id] is the local row and is null until the message is stored. [wiId] is the
 * backend's id and is null for a message the user has just written, which is
 * why the two cannot be the same field.
 *
 * [timestamp] is epoch milliseconds. It is passed in rather than read from the
 * clock so that whoever creates the message decides what time it happened.
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
)

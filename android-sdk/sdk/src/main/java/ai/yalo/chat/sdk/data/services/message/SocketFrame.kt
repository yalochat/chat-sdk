// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.message

/** A frame the server sent, as far as the connection needs to care. */
internal sealed interface SocketFrame {

    data object ConnectionAck : SocketFrame

    data class Payload(val message: InboundMessage) : SocketFrame

    data object Unusable : SocketFrame
}

/**
 * Something the server sent that a listener is meant to see. Empty here so the
 * connection stays free of the wire format.
 */
internal sealed interface InboundMessage

internal class MessageConnectionClosedException :
    IllegalStateException("The chat is not open, so the message was not taken")

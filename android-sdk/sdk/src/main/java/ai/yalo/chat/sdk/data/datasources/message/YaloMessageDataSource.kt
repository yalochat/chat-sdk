// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.message

import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessageAck
import kotlinx.coroutines.flow.Flow

/**
 * Something the channel sent that a listener is meant to see. Held apart from
 * the wire format so a listener never sees a frame.
 */
internal sealed interface InboundMessage

/** A message the channel sent into the conversation. */
internal data class MessageReceived(val item: PollMessageItem) : InboundMessage

/** The channel confirming it has a message that was sent to it. */
internal data class MessageAcknowledged(val ack: SdkMessageAck) : InboundMessage

/** Carries a conversation between the device and the channel. */
internal interface YaloMessageDataSource {

    /** What the channel sends, as it arrives. Hot, and nothing is replayed. */
    val messages: Flow<InboundMessage>

    /**
     * Opens one connection with [token] and reads from it until it dies,
     * answering whether it ever opened.
     *
     * Nothing here decides when to try again or what token to try with: the
     * caller does, by calling this again. Cancelling the call is what ends the
     * connection.
     */
    suspend fun runSession(token: String): Boolean

    /**
     * Sends [message] to the channel.
     *
     * Success means the message has been taken, not that it has arrived. One
     * sent while the line is down waits until it is up again.
     */
    suspend fun send(message: SdkMessage): Result<Unit>

    /** Forgets whatever was waiting to be sent. */
    suspend fun close()
}

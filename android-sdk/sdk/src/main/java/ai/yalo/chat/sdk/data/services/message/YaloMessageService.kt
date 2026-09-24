// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.message

import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessageAck
import kotlinx.coroutines.flow.Flow

/** A message the channel sent into the conversation. */
internal data class MessageReceived(val item: PollMessageItem) : InboundMessage

/** The channel confirming it has a message that was sent to it. */
internal data class MessageAcknowledged(val ack: SdkMessageAck) : InboundMessage

/** Carries a conversation between the device and the channel. */
internal interface YaloMessageService {

    /** What the channel sends, as it arrives. Hot, and nothing is replayed. */
    val messages: Flow<InboundMessage>

    /**
     * Whether the channel will take a message right now.
     *
     * Turns true each time a connection is acknowledged and false when it is
     * lost, so whoever is holding messages back knows when to let them go.
     */
    val isReady: Flow<Boolean>

    /**
     * Asks for a connection with [token], and for it to be rebuilt whenever it
     * is lost. Every rebuild carries the same token, so a caller whose token has
     * since expired connects again with a new one.
     */
    suspend fun connect(token: String)

    /**
     * Sends [message] to the channel.
     *
     * Success means the message has been taken, not that it has arrived. Fails
     * with [MessageConnectionClosedException] whenever there is no connection to
     * write to: holding one back until there is belongs to the caller.
     */
    suspend fun send(message: SdkMessage): Result<Unit>

    /** Drops the socket because the app went away, keeping whatever is waiting to be sent. */
    suspend fun pause()

    /** Connects again after a [pause], and sends whatever was held meanwhile. */
    suspend fun resume()

    /** Ends the conversation and forgets what was being held for it. */
    suspend fun close()
}

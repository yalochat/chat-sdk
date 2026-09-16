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

    /** Asks for a connection, and for it to be rebuilt whenever it is lost. */
    suspend fun connect()

    /**
     * Sends [message] to the channel.
     *
     * Success means the message has been taken, not that it has arrived. One
     * sent while the line is down waits until it is up again. Sending before
     * [connect] or after [close] fails.
     */
    suspend fun send(message: SdkMessage): Result<Unit>

    /** Drops the socket because the app went away, keeping whatever is waiting to be sent. */
    suspend fun pause()

    /** Connects again after a [pause], and sends whatever was held meanwhile. */
    suspend fun resume()

    /** Ends the conversation and forgets what was being held for it. */
    suspend fun close()
}

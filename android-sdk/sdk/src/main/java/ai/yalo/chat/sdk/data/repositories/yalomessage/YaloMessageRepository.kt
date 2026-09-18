// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.yalomessage

import ai.yalo.chat.sdk.domain.models.ChatMessage
import kotlinx.coroutines.flow.Flow

/**
 * The channel's side of one conversation, in the terms the chat thinks in.
 *
 * Everything here can fail on a network the app does not control, which is
 * something the chat has to show rather than crash on, so [send] reports it as
 * a failed [Result] instead of throwing.
 */
internal interface YaloMessageRepository {

    /**
     * Opens the line to the channel and has it rebuilt whenever it is lost.
     * Asking again while one is already open changes nothing.
     *
     * This returns as soon as it has asked. Nothing has to wait for the line to
     * be up, because a message sent before then is held and goes out once it is.
     */
    fun connect()

    /** What the channel says, as it arrives. Hot, and nothing is replayed. */
    fun messages(): Flow<ChatMessage>

    /**
     * Sends [message] to the channel.
     *
     * Success means the channel has taken the message, not that anyone has read
     * it. Only text can be sent so far: any other kind comes back as a failed
     * [Result] rather than being dropped quietly.
     */
    suspend fun send(message: ChatMessage): Result<Unit>

    /**
     * Tells the channel a chat has been opened, so it can say something first.
     *
     * [openContext] is what the chat was opened from, and reaches the channel
     * as it is given. An empty one asks the same question with nothing to go on.
     */
    suspend fun requestGuidanceCard(openContext: Map<String, String> = emptyMap()): Result<Unit>

    /** Ends the conversation and forgets whatever was waiting to be sent. */
    fun close()
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.receiveAsFlow
import java.util.concurrent.ConcurrentHashMap

/**
 * The way into the SDK.
 *
 * Creating one costs nothing: it holds the config and a channel for what the
 * host asks the chat to do. Storage and the connection are built elsewhere,
 * when a chat is actually shown, so an app with several conversations creates
 * a client for each without paying for any of them up front.
 */
public class YaloChatClient(internal val config: YaloChatClientConfig) {

    private val commands = ConcurrentHashMap<String, Function<*>>()

    // A queue rather than a broadcast: a message waits here until a chat
    // takes it, and is taken exactly once. A shared flow would drop whatever
    // was sent before the chat subscribed, and would hand the same message
    // over again every time the chat was rebuilt.
    private val outgoing = Channel<String>(capacity = OUTGOING_BUFFER)

    /** Text the host asked to send, for an open chat to pick up and store. */
    internal val outgoingTextMessages: Flow<String> = outgoing.receiveAsFlow()

    public fun registerCommand(command: String, handler: Function<*>) {
	this.commands[command] = handler
    }

    /**
     * Sends [text] as if the person had typed it.
     *
     * The message is handed to a chat open on this session, which is what
     * stores and shows it. Sending before a chat is shown is fine: the message
     * waits until one opens, up to [OUTGOING_BUFFER] of them.
     */
    public fun sendTextMessage(text: String) {
        outgoing.trySend(text)
    }

    private companion object {
        const val OUTGOING_BUFFER = 64
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

import ai.yalo.chat.sdk.common.session.sessionOf
import ai.yalo.chat.sdk.config.ChatDependencies
import ai.yalo.chat.sdk.log.YaloLog
import android.content.Context
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.receiveAsFlow
import java.util.concurrent.ConcurrentHashMap

/**
 * Runs a command the channel asked for. It receives the request payload and
 * answers with the payload sent back. Throwing reports the command as failed.
 */
public typealias CommandHandler = suspend (payload: String) -> String

/**
 * The way into the SDK.
 *
 * Creating one costs nothing: it holds the config and a channel for what the
 * host asks the chat to do. Storage and the connection are built elsewhere,
 * when a chat is actually shown, so an app with several conversations creates
 * a client for each without paying for any of them up front.
 */
public class YaloChatClient(internal val config: YaloChatClientConfig) {

    private val commands = ConcurrentHashMap<String, CommandHandler>()

    // A queue rather than a broadcast: a message waits here until a chat
    // takes it, and is taken exactly once. A shared flow would drop whatever
    // was sent before the chat subscribed, and would hand the same message
    // over again every time the chat was rebuilt.
    private val outgoing = Channel<String>(capacity = OUTGOING_BUFFER)

    /** Text the host asked to send, for an open chat to pick up and store. */
    internal val outgoingTextMessages: Flow<String> = outgoing.receiveAsFlow()

    // A broadcast rather than a queue: every open chat has to empty, and a
    // chat opened later reads storage that is already empty.
    private val clears = MutableSharedFlow<Unit>(
        extraBufferCapacity = 1,
        onBufferOverflow = BufferOverflow.DROP_OLDEST,
    )

    /** Emits every time the host asks to clear the messages. */
    internal val clearRequests: Flow<Unit> = clears.asSharedFlow()

    private val log = YaloLog(LOG_NAME, config.logLevel)

    /**
     * Runs [handler] whenever the channel asks for [command] while a chat is
     * open. Registering the same command again replaces its handler.
     */
    public fun registerCommand(command: String, handler: CommandHandler) {
        commands[command] = handler
    }

    internal fun commandHandler(command: String): CommandHandler? = commands[command]

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

    /**
     * Deletes every message of the conversation, whether a chat is showing it
     * or not, for example when the person logs out. A chat showing it empties
     * and the channel greets the person again, as in a new conversation.
     *
     * [context] is only used to reach the storage, so any one will do.
     */
    public suspend fun clearMessages(context: Context) {
        // An ephemeral conversation is forgotten with its chat, so only a chat
        // showing one has anything to delete.
        if (config.sessionMode != SessionMode.Ephemeral) {
            ChatDependencies(context, config, sessionOf(config)).chatMessages.clearSession()
                .onFailure { error -> log.error(error) { "could not clear the messages" } }
        }
        clears.tryEmit(Unit)
    }

    private companion object {
        const val OUTGOING_BUFFER = 64
        const val LOG_NAME = "Client"
    }
}

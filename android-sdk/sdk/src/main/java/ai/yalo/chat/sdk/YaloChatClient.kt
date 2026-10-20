// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

import ai.yalo.chat.sdk.common.session.sessionOf
import ai.yalo.chat.sdk.config.ChatDependencies
import ai.yalo.chat.sdk.log.YaloLog
import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.withContext
import java.util.concurrent.ConcurrentHashMap

/**
 * Runs a command the channel asked for. It receives the request payload and
 * answers with the payload sent back. Throwing reports the command as failed.
 */
public typealias CommandHandler = suspend (payload: String) -> String

/** What the host emptied the storage for, as every open chat hears it. */
internal enum class ClearRequest { Messages, Logout }

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

    /** Emits every time any client empties the storage. */
    internal val clearRequests: Flow<ClearRequest> = clears.asSharedFlow()

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
     * Deletes every message stored on the device, of every conversation,
     * whether a chat is showing it or not. Every open chat empties and the
     * channel greets the person again, as in a new conversation.
     *
     * [context] is only used to reach the storage, so any one will do.
     */
    public suspend fun clearMessages(context: Context) {
        deleteMessages(ChatDependencies(context, config, sessionOf(config)))
        clears.tryEmit(ClearRequest.Messages)
    }

    /**
     * Deletes every message and every token stored on the device, for example
     * when the person logs out. Every open chat empties and reconnects as a
     * new person, and the channel greets them as in a new conversation.
     *
     * [context] is only used to reach the storage, so any one will do.
     */
    public suspend fun logout(context: Context) {
        val dependencies = ChatDependencies(context, config, sessionOf(config))
        deleteMessages(dependencies)
        dependencies.auth.deleteAll()
            .onFailure { error -> log.error(error) { "could not clear the tokens" } }
        clears.tryEmit(ClearRequest.Logout)
    }

    private suspend fun deleteMessages(dependencies: ChatDependencies) {
        dependencies.chatMessages.deleteAll()
            .onFailure { error -> log.error(error) { "could not clear the messages" } }
        withContext(Dispatchers.IO) {
            dependencies.sessionsDir.deleteRecursively()
        }
    }

    private companion object {
        const val OUTGOING_BUFFER = 64
        const val LOG_NAME = "Client"

        // A broadcast rather than a queue: every open chat has to empty, and
        // a chat opened later reads storage that is already empty. Shared by
        // every client because the storage is.
        val clears = MutableSharedFlow<ClearRequest>(
            extraBufferCapacity = 1,
            onBufferOverflow = BufferOverflow.DROP_OLDEST,
        )
    }
}

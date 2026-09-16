// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.message

import ai.yalo.chat.sdk.data.services.auth.YaloMessageAuthService
import ai.yalo.chat.sdk.data.services.message.MessageConnection.Command
import ai.yalo.chat.sdk.data.services.message.MessageConnection.Event
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ConnectionAck
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ConnectionAckType
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessageAck
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessageAckType
import com.google.protobuf.InvalidProtocolBufferException
import com.google.protobuf.util.JsonFormat
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import okhttp3.HttpUrl
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okio.ByteString
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.util.concurrent.atomic.AtomicLong

/**
 * Carries out what a [MessageConnection] decides, against a real socket.
 */
internal class YaloMessageServiceWebsocket(
    private val auth: YaloMessageAuthService,
    private val scope: CoroutineScope,
    baseUrl: HttpUrl,
    private val sockets: WebSocket.Factory = OkHttpClient(),
) : YaloMessageService {

    private val connection = MessageConnection()
    private val mutex = Mutex()
    private val waiting = mutableMapOf<Long, CompletableDeferred<Unit>>()
    private val nextRequestId = AtomicLong()

    // A socket callback arrives on OkHttp's reader thread, which cannot wait on
    // the lock. Queueing keeps the order the server sent things in.
    private val events = Channel<Event>(Channel.UNLIMITED)

    // Delivering happens under the lock, so a listener that stopped reading
    // must not be able to stall the connection behind it.
    private val incoming = MutableSharedFlow<InboundMessage>(
        extraBufferCapacity = INCOMING_BUFFER,
        onBufferOverflow = BufferOverflow.DROP_OLDEST,
    )

    private val socketUrl: HttpUrl = baseUrl.newBuilder().addPathSegments(SOCKET_PATH).build()

    private var socket: WebSocket? = null
    private var ackTimer: Job? = null
    private var reconnectTimer: Job? = null

    init {
        scope.launch {
            for (event in events) {
                post(event)
            }
        }
    }

    override val messages: Flow<InboundMessage> = incoming.asSharedFlow()

    override suspend fun connect() {
        post(Event.Started)
    }

    override suspend fun pause() {
        post(Event.Paused)
    }

    override suspend fun resume() {
        post(Event.Resumed)
    }

    override suspend fun close() {
        post(Event.Stopped)
    }

    override suspend fun send(message: SdkMessage): Result<Unit> {
        val frame = frameOf(message).getOrElse { cause -> return Result.failure(cause) }
        val requestId = nextRequestId.incrementAndGet()
        val answer = CompletableDeferred<Unit>()
        mutex.withLock {
            waiting[requestId] = answer
            apply(Event.SendRequested(requestId, frame))
        }
        return try {
            Result.success(answer.await())
        } catch (error: CancellationException) {
            throw error
        } catch (error: Throwable) {
            Result.failure(error)
        } finally {
            withContext(NonCancellable) {
                mutex.withLock { waiting.remove(requestId) }
            }
        }
    }

    private suspend fun post(event: Event) {
        mutex.withLock { apply(event) }
    }

    private fun apply(event: Event) {
        for (command in connection.handle(event)) {
            when (command) {
                is Command.FetchToken -> scope.launch {
                    auth.token().fold(
                        onSuccess = { token -> events.trySend(Event.TokenFetched(command.generation, token)) },
                        onFailure = { events.trySend(Event.TokenFetchFailed(command.generation)) },
                    )
                }
                is Command.OpenSocket -> open(command.generation, command.accessToken)
                is Command.CloseSocket -> {
                    socket?.close(NORMAL_CLOSURE, null)
                    socket = null
                }
                is Command.SendFrame -> {
                    val answer = waiting.remove(command.requestId)
                    // OkHttp answers false rather than throwing when the socket
                    // will not take the frame.
                    if (socket?.send(command.frame) == true) {
                        answer?.complete(Unit)
                    } else {
                        answer?.completeExceptionally(IOException(FRAME_NOT_SENT))
                    }
                }
                is Command.FlushFrames -> {
                    for (frame in command.frames) {
                        socket?.send(frame)
                    }
                }
                is Command.CompleteSend -> waiting.remove(command.requestId)?.complete(Unit)
                is Command.FailSend ->
                    waiting.remove(command.requestId)?.completeExceptionally(command.cause)
                is Command.DeliverMessage -> incoming.tryEmit(command.message)
                is Command.StartAckTimer -> {
                    ackTimer = timer(ackTimer, command.delayMillis) {
                        Event.AckTimerFired(command.generation)
                    }
                }
                is Command.CancelAckTimer -> {
                    ackTimer?.cancel()
                    ackTimer = null
                }
                is Command.StartReconnectTimer -> {
                    reconnectTimer = timer(reconnectTimer, command.delayMillis) {
                        Event.ReconnectTimerFired(command.generation)
                    }
                }
                is Command.CancelReconnectTimer -> {
                    reconnectTimer?.cancel()
                    reconnectTimer = null
                }
            }
        }
    }

    // Cancelling a job already past its wait does not unfire it, so the event it
    // posts names its attempt and the state machine drops it.
    private fun timer(running: Job?, delayMillis: Long, event: () -> Event): Job {
        running?.cancel()
        return scope.launch {
            delay(delayMillis)
            events.trySend(event())
        }
    }

    private fun open(generation: Long, accessToken: String) {
        // The backend reads the token from the query, not a header. These are
        // JWTs, so base64url, so the literal plus addQueryParameter leaves
        // alone cannot be read back as a space.
        val url = socketUrl.newBuilder().addQueryParameter(QUERY_TOKEN, accessToken).build()
        socket = sockets.newWebSocket(Request.Builder().url(url).build(), Listener(generation))
    }

    /** One socket's reports, stamped with the attempt they belong to. */
    private inner class Listener(private val generation: Long) : WebSocketListener() {

        override fun onOpen(webSocket: WebSocket, response: Response) {
            events.trySend(Event.SocketOpened(generation))
        }

        // Read on the reader thread rather than under the lock.
        override fun onMessage(webSocket: WebSocket, text: String) {
            events.trySend(Event.FrameReceived(generation, frameFrom(text)))
        }

        /** The wire format is text, so binary is not this protocol. */
        override fun onMessage(webSocket: WebSocket, bytes: ByteString) = Unit

        override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
            webSocket.close(NORMAL_CLOSURE, null)
        }

        override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
            events.trySend(Event.SocketClosed(generation))
        }

        override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
            events.trySend(Event.SocketClosed(generation))
        }
    }

    private fun frameOf(message: SdkMessage): Result<String> = try {
        Result.success(PRINTER.print(message))
    } catch (error: InvalidProtocolBufferException) {
        Result.failure(error)
    }

    // Classified by shape rather than by what the connection is waiting for, so
    // a repeated acknowledgement is recognised as one instead of being read as
    // a message.
    private fun frameFrom(text: String): SocketFrame = try {
        val fields = JSONObject(text)
        when {
            !fields.has(FIELD_TYPE) -> SocketFrame.Payload(
                MessageReceived(
                    PollMessageItem.newBuilder().also { PARSER.merge(text, it) }.build(),
                ),
            )
            fields.has(FIELD_CORRELATION_ID) -> messageAck(text)
            else -> connectionAck(text)
        }
    } catch (error: JSONException) {
        SocketFrame.Unusable
    } catch (error: InvalidProtocolBufferException) {
        SocketFrame.Unusable
    }

    private fun connectionAck(text: String): SocketFrame {
        val ack = ConnectionAck.newBuilder().also { PARSER.merge(text, it) }.build()
        if (ack.type != ConnectionAckType.CONNECTION_ACK_TYPE_CONNECTION_ACK) {
            return SocketFrame.Unusable
        }
        return SocketFrame.ConnectionAck
    }

    private fun messageAck(text: String): SocketFrame {
        val ack = SdkMessageAck.newBuilder().also { PARSER.merge(text, it) }.build()
        if (ack.type != SdkMessageAckType.SDK_MESSAGE_ACK_TYPE_MESSAGE_ACK) {
            return SocketFrame.Unusable
        }
        return SocketFrame.Payload(MessageAcknowledged(ack))
    }

    private companion object {

        private const val SOCKET_PATH = "websocket/v1/connect/inapp"
        private const val QUERY_TOKEN = "token"
        private const val FIELD_TYPE = "type"
        private const val FIELD_CORRELATION_ID = "correlationId"
        private const val FRAME_NOT_SENT = "The socket would not take the frame"
        private const val NORMAL_CLOSURE = 1000
        private const val INCOMING_BUFFER = 64

        // The wire format is proto3 JSON, which is what these produce and accept
        // by default. Ignoring unknown fields keeps a newer backend from
        // breaking an older app.
        private val PRINTER: JsonFormat.Printer =
            JsonFormat.printer().omittingInsignificantWhitespace()
        private val PARSER: JsonFormat.Parser = JsonFormat.parser().ignoringUnknownFields()
    }
}

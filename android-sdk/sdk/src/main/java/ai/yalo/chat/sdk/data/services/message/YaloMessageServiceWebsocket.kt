// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.message

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.log.YaloLog
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ConnectionAck
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ConnectionAckType
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessageAck
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessageAckType
import com.google.protobuf.InvalidProtocolBufferException
import com.google.protobuf.util.JsonFormat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.isActive
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
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
import kotlin.time.Duration.Companion.milliseconds

/**
 * Keeps a socket to the channel open, and rebuilds it whenever it is lost.
 *
 * One coroutine owns the connection: it opens a socket, waits for the server to
 * acknowledge it, hands on what arrives, and when the socket dies waits a little
 * longer each time before trying again. Cancelling that coroutine is what pause
 * and close do, so a dropped attempt cleans up after itself rather than having
 * to be told to.
 *
 * Messages written before there is a connection are held and sent once there is
 * one. Messages written after [close] are refused.
 */
internal class YaloMessageServiceWebsocket(
    private val scope: CoroutineScope,
    baseUrl: HttpUrl,
    private val sockets: WebSocket.Factory = OkHttpClient(),
    logLevel: LogLevel = LogLevel.Warn,
) : YaloMessageService {

    private val log = YaloLog(LOG_NAME, logLevel)
    private val mutex = Mutex()
    private val socketUrl: HttpUrl = baseUrl.newBuilder().addPathSegments(SOCKET_PATH).build()

    // Delivering must not be able to stall the connection behind it.
    private val incoming = MutableSharedFlow<InboundMessage>(
        extraBufferCapacity = INCOMING_BUFFER,
        onBufferOverflow = BufferOverflow.DROP_OLDEST,
    )

    // All four are guarded by [mutex].
    private var token: String? = null
    private var closed: Boolean = false
    private var connection: Job? = null
    private var live: WebSocket? = null

    private val ready = MutableStateFlow(false)

    override val messages: Flow<InboundMessage> = incoming.asSharedFlow()

    override val isReady: Flow<Boolean> = ready.asStateFlow()

    override suspend fun connect(token: String) {
        log.info { "connecting" }
        mutex.withLock {
            if (closed || connection != null) {
                return
            }
            this.token = token
            connection = scope.launch { keepConnected(token) }
        }
    }

    override suspend fun pause() {
        log.info { "pausing, the app went away" }
        stopConnecting()
    }

    override suspend fun resume() {
        log.info { "resuming" }
        val token = mutex.withLock {
            if (closed || connection != null) {
                return
            }
            token ?: return
        }
        mutex.withLock { connection = scope.launch { keepConnected(token) } }
    }

    override suspend fun close() {
        log.info { "closing" }
        mutex.withLock { closed = true }
        stopConnecting()
    }

    private suspend fun stopConnecting() {
        val running = mutex.withLock {
            val job = connection
            connection = null
            job
        }
        running?.cancelAndJoin()
    }

    override suspend fun send(message: SdkMessage): Result<Unit> {
        val frame = frameOf(message).getOrElse { cause -> return Result.failure(cause) }
        return mutex.withLock {
            val socket = live
            when {
                socket == null -> Result.failure(MessageConnectionClosedException())
                // OkHttp answers false rather than throwing when the socket will
                // not take the frame.
                socket.send(frame) -> {
                    log.debug { "sent $frame" }
                    Result.success(Unit)
                }
                else -> {
                    log.warn { "the socket would not take a message" }
                    Result.failure(IOException(FRAME_NOT_SENT))
                }
            }
        }
    }

    /**
     * Opens a socket, and opens another whenever the last one dies.
     *
     * The wait doubles after each attempt that never got a socket open. One that
     * did starts the ladder over, since the line has shown it works.
     */
    private suspend fun keepConnected(token: String) {
        var attempt = FIRST_ATTEMPT
        while (currentCoroutineContext().isActive) {
            val opened = connectOnce(token)
            if (opened) {
                attempt = FIRST_ATTEMPT
            }
            val wait = minOf(MAX_BACKOFF_MILLIS, INITIAL_BACKOFF_MILLIS shl attempt)
            attempt = (attempt + 1).coerceAtMost(MAX_ATTEMPT)
            log.info { "reconnecting in ${wait}ms" }
            delay(wait.milliseconds)
        }
    }

    /** Runs one socket to its end. Answers whether it ever opened. */
    private suspend fun connectOnce(token: String): Boolean {
        val events = Channel<SocketEvent>(Channel.UNLIMITED)
        log.info { "opening the socket to ${socketUrl.host}" }
        // The backend reads the token from the query, not a header. These are
        // JWTs, so base64url, so the literal plus addQueryParameter leaves
        // alone cannot be read back as a space.
        val url = socketUrl.newBuilder().addQueryParameter(QUERY_TOKEN, token).build()
        val socket = sockets.newWebSocket(Request.Builder().url(url).build(), Listener(events))

        var opened = false
        var acknowledged = false
        var watchdog: Job? = null
        try {
            for (event in events) {
                when (event) {
                    is SocketEvent.Opened -> {
                        log.info { "the socket is open" }
                        opened = true
                        // Nothing obliges the server to acknowledge, so a socket
                        // that stays quiet is dropped rather than waited on.
                        watchdog = scope.launch {
                            delay(ACK_TIMEOUT_MILLIS.milliseconds)
                            log.warn { "the connection was never acknowledged" }
                            events.trySend(SocketEvent.Closed)
                        }
                    }
                    is SocketEvent.Closed -> return opened
                    is SocketEvent.Received -> when {
                        !opened -> Unit
                        acknowledged -> deliver(event.frame)
                        event.frame is SocketFrame.ConnectionAck -> {
                            acknowledged = true
                            watchdog?.cancel()
                            mutex.withLock { live = socket }
                            ready.value = true
                        }
                        else -> Unit
                    }
                }
            }
            return opened
        } finally {
            watchdog?.cancel()
            // Cancelled is the usual way out of here, and a cancelled coroutine
            // cannot take a lock.
            ready.value = false
            withContext(NonCancellable) { mutex.withLock { live = null } }
            log.debug { "closing the socket" }
            socket.close(NORMAL_CLOSURE, null)
        }
    }

    private fun deliver(frame: SocketFrame) {
        if (frame !is SocketFrame.Payload) {
            return
        }
        log.debug { "the channel sent ${nameOf(frame.message)}" }
        incoming.tryEmit(frame.message)
    }

    private sealed interface SocketEvent {

        data object Opened : SocketEvent

        data object Closed : SocketEvent

        data class Received(val frame: SocketFrame) : SocketEvent
    }

    /** One socket's reports. A socket that is gone has nobody reading its channel. */
    private inner class Listener(private val events: Channel<SocketEvent>) : WebSocketListener() {

        override fun onOpen(webSocket: WebSocket, response: Response) {
            events.trySend(SocketEvent.Opened)
        }

        // Read on the reader thread rather than under the lock.
        override fun onMessage(webSocket: WebSocket, text: String) {
            log.debug { "received $text" }
            events.trySend(SocketEvent.Received(frameFrom(text)))
        }

        /** The wire format is text, so binary is not this protocol. */
        override fun onMessage(webSocket: WebSocket, bytes: ByteString) = Unit

        override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
            webSocket.close(NORMAL_CLOSURE, null)
        }

        override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
            log.info { "the socket closed with $code" }
            events.trySend(SocketEvent.Closed)
        }

        override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
            log.warn(t) { "the socket failed" }
            events.trySend(SocketEvent.Closed)
        }
    }

    private fun frameOf(message: SdkMessage): Result<String> = try {
        Result.success(PRINTER.print(message))
    } catch (error: InvalidProtocolBufferException) {
        log.error(error) { "a message cannot be put on the wire" }
        Result.failure(error)
    }

    // What reached the chat, as against what arrived on the wire: a frame can be
    // dropped or belong to a socket that has since been replaced.
    private fun nameOf(message: InboundMessage): String = when (message) {
        is MessageReceived -> "a ${message.item.message.payloadCase.name} message"
        is MessageAcknowledged -> "an acknowledgement"
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
        log.warn(error) { "a frame that is not JSON was dropped" }
        SocketFrame.Unusable
    } catch (error: InvalidProtocolBufferException) {
        log.warn(error) { "a frame this SDK cannot read was dropped" }
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

        private const val LOG_NAME = "MessageSocket"

        private const val SOCKET_PATH = "websocket/v1/connect/inapp"
        private const val QUERY_TOKEN = "token"
        private const val FIELD_TYPE = "type"
        private const val FIELD_CORRELATION_ID = "correlationId"
        private const val FRAME_NOT_SENT = "The socket would not take the frame"
        private const val NORMAL_CLOSURE = 1000
        private const val INCOMING_BUFFER = 64

        private const val ACK_TIMEOUT_MILLIS = 10_000L
        private const val INITIAL_BACKOFF_MILLIS = 1_000L
        private const val MAX_BACKOFF_MILLIS = 30_000L
        private const val FIRST_ATTEMPT = 0

        // Counting past the point where the delay stops growing keeps the shift
        // that computes it honest.
        private const val MAX_ATTEMPT = 5


        // The wire format is proto3 JSON, which is what these produce and accept
        // by default. Ignoring unknown fields keeps a newer backend from
        // breaking an older app.
        private val PRINTER: JsonFormat.Printer =
            JsonFormat.printer().omittingInsignificantWhitespace()
        private val PARSER: JsonFormat.Parser = JsonFormat.parser().ignoringUnknownFields()
    }
}

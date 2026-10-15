// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.message

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.log.YaloLog
import ai.yalo.chat.sdk.internal.proto.v2.ConnectionAck
import ai.yalo.chat.sdk.internal.proto.v2.ConnectionAckType
import ai.yalo.chat.sdk.internal.proto.v2.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageAck
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageAckType
import com.squareup.moshi.JsonDataException
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.channels.ReceiveChannel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
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
 * Holds a live link to the channel over a websocket, one socket at a time.
 *
 * [runSession] is that socket's whole life: it opens one with the token it is
 * given, waits for the server to acknowledge it, reads from it until it dies
 * and then returns. Whether another one follows, how long to wait first and
 * which token to open it with are not decided here.
 *
 * What a caller wrote while no socket was up is kept, and goes out in order as
 * soon as one is acknowledged.
 */
internal class YaloMessageWebsocketDataSource(
    baseUrl: HttpUrl,
    private val sockets: WebSocket.Factory = OkHttpClient(),
    logLevel: LogLevel = LogLevel.Warn,
) : YaloMessageDataSource {

    private val log = YaloLog(LOG_NAME, logLevel)

    // Guards everything a caller and the socket both touch.
    private val mutex = Mutex()

    /** The socket a message can go out on now, set once the server acknowledged it. */
    private var live: WebSocket? = null

    /** Written while the line was down, sent in order once it is up again. */
    private val pending = ArrayDeque<String>()

    // A listener that stopped reading must not be able to stall the connection
    // behind it.
    private val incoming = MutableSharedFlow<InboundMessage>(
        extraBufferCapacity = INCOMING_BUFFER,
        onBufferOverflow = BufferOverflow.DROP_OLDEST,
    )

    private val socketUrl: HttpUrl = baseUrl.newBuilder().addPathSegments(SOCKET_PATH).build()

    override val messages: Flow<InboundMessage> = incoming.asSharedFlow()

    override suspend fun send(message: SdkMessage): Result<Unit> {
        val frame = WireFormat.write(message)
        return mutex.withLock {
            val socket = live
            when {
                socket == null -> {
                    hold(frame)
                    Result.success(Unit)
                }
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

    override suspend fun close() {
        mutex.withLock {
            log.info { "forgetting what was waiting to be sent" }
            pending.clear()
        }
    }

    /**
     * Runs one socket for as long as it lasts, and answers whether it ever
     * opened.
     */
    override suspend fun runSession(token: String): Boolean {
        val events = Channel<SocketEvent>(Channel.UNLIMITED)
        log.info { "opening the socket to ${socketUrl.host}" }
        // The backend reads the token from the query, not a header. These are
        // JWTs, so base64url, so the literal plus addQueryParameter leaves
        // alone cannot be read back as a space.
        val url = socketUrl.newBuilder().addQueryParameter(QUERY_TOKEN, token).build()
        val socket = sockets.newWebSocket(Request.Builder().url(url).build(), Listener(events))
        try {
            if (!awaitOpen(events)) {
                return false
            }
            if (!awaitAcknowledgement(events)) {
                return true
            }
            flushInto(socket)
            deliverUntilClosed(events)
            return true
        } finally {
            withContext(NonCancellable) {
                mutex.withLock { live = null }
            }
            log.debug { "closing the socket" }
            socket.close(NORMAL_CLOSURE, null)
        }
    }

    /** Answers false when the socket died before it ever opened. */
    private suspend fun awaitOpen(events: ReceiveChannel<SocketEvent>): Boolean {
        for (event in events) {
            if (event is SocketEvent.Opened) {
                return true
            }
            if (event is SocketEvent.Closed) {
                return false
            }
        }
        return false
    }

    // Nothing may be sent until the server says the connection is theirs, and a
    // server that never says so is a line that looks up but is not.
    private suspend fun awaitAcknowledgement(events: ReceiveChannel<SocketEvent>): Boolean {
        val acknowledged = withTimeoutOrNull(ACK_TIMEOUT_MILLIS.milliseconds) {
            var seen = false
            for (event in events) {
                if (event is SocketEvent.Closed) {
                    break
                }
                if (event is SocketEvent.Frame && event.frame is SocketFrame.ConnectionAck) {
                    seen = true
                    break
                }
            }
            seen
        }
        if (acknowledged == null) {
            log.warn { "the server never acknowledged the connection" }
        }
        return acknowledged == true
    }

    private suspend fun deliverUntilClosed(events: ReceiveChannel<SocketEvent>) {
        for (event in events) {
            if (event is SocketEvent.Closed) {
                return
            }
            if (event is SocketEvent.Frame && event.frame is SocketFrame.Payload) {
                val message = event.frame.message
                log.debug { "the channel sent ${nameOf(message)}" }
                incoming.tryEmit(message)
            }
        }
    }

    private suspend fun flushInto(socket: WebSocket) {
        mutex.withLock {
            live = socket
            if (pending.isEmpty()) {
                return@withLock
            }
            log.info { "sending ${pending.size} held back while the line was down" }
            for (frame in pending) {
                log.debug { "sent $frame" }
                socket.send(frame)
            }
            pending.clear()
        }
    }

    private fun hold(frame: String) {
        pending += frame
        while (pending.size > MAX_PENDING_FRAMES) {
            pending.removeFirst()
        }
    }

    /** One socket's reports, which arrive on OkHttp's reader thread. */
    private inner class Listener(private val events: Channel<SocketEvent>) : WebSocketListener() {

        override fun onOpen(webSocket: WebSocket, response: Response) {
            log.info { "the socket is open" }
            events.trySend(SocketEvent.Opened)
        }

        override fun onMessage(webSocket: WebSocket, text: String) {
            log.debug { "received $text" }
            events.trySend(SocketEvent.Frame(frameFrom(text)))
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

    // What reached the chat, as against what arrived on the wire: a frame can be
    // dropped or belong to a socket that has since been replaced.
    private fun nameOf(message: InboundMessage): String = when (message) {
        is MessageReceived -> "a message"
        is MessageAcknowledged -> "an acknowledgement"
    }

    // Classified by shape rather than by what the connection is waiting for, so
    // a repeated acknowledgement is recognised as one instead of being read as
    // a message.
    private fun frameFrom(text: String): SocketFrame = try {
        val fields = JSONObject(text)
        when {
            !fields.has(FIELD_TYPE) -> SocketFrame.Payload(
                MessageReceived(WireFormat.read(text, PollMessageItem::class.java)),
            )
            fields.has(FIELD_CORRELATION_ID) -> messageAck(text)
            else -> connectionAck(text)
        }
    } catch (error: JSONException) {
        log.warn(error) { "a frame that is not JSON was dropped" }
        SocketFrame.Unusable
    } catch (error: JsonDataException) {
        log.warn(error) { "a frame this SDK cannot read was dropped" }
        SocketFrame.Unusable
    } catch (error: IOException) {
        // org.json accepts JSON that is looser than what the reader takes.
        log.warn(error) { "a frame this SDK cannot read was dropped" }
        SocketFrame.Unusable
    }

    private fun connectionAck(text: String): SocketFrame {
        val ack = WireFormat.read(text, ConnectionAck::class.java)
        if (ack.type != ConnectionAckType.CONNECTION_ACK_TYPE_CONNECTION_ACK) {
            return SocketFrame.Unusable
        }
        return SocketFrame.ConnectionAck
    }

    private fun messageAck(text: String): SocketFrame {
        val ack = WireFormat.read(text, SdkMessageAck::class.java)
        if (ack.type != SdkMessageAckType.SDK_MESSAGE_ACK_TYPE_MESSAGE_ACK) {
            return SocketFrame.Unusable
        }
        return SocketFrame.Payload(MessageAcknowledged(ack))
    }

    /** A frame the server sent, as far as the connection needs to care. */
    private sealed interface SocketFrame {

        data object ConnectionAck : SocketFrame

        data class Payload(val message: InboundMessage) : SocketFrame

        data object Unusable : SocketFrame
    }

    /** What one socket reported, in the order it reported it. */
    private sealed interface SocketEvent {

        data object Opened : SocketEvent

        data class Frame(val frame: SocketFrame) : SocketEvent

        /** A failure, a close from the server and a close asked for from here all arrive this way. */
        data object Closed : SocketEvent
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

        private const val MAX_PENDING_FRAMES = 128
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.message

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.log.YaloLog
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ConnectionAck
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ConnectionAckType
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.MessageRole
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessageAck
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessageAckType
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.TextMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.TextMessageRequest
import com.google.protobuf.util.JsonFormat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.Protocol
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okio.ByteString
import okio.ByteString.Companion.encodeUtf8
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.shadows.ShadowLog
import java.io.IOException

/**
 * Covers what only the shell can get wrong.
 *
 * Which command follows which event is the state machine's to answer and is
 * tested in [MessageConnectionTest] without any of this machinery. What is left
 * here is the translation: the address it dials, the wire format it reads and
 * writes, and whether the timers it is told to start actually fire.
 *
 * Robolectric is here because the frames are classified with `org.json`, which
 * throws out of a plain JVM test. The socket itself is a fake, so the delays are
 * the scheduler's virtual ones and the whole suite runs in milliseconds rather
 * than the two real minutes a backoff ladder would otherwise take.
 */
@OptIn(ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
class YaloMessageServiceWebsocketTest {

    private val sockets = FakeWebSocketFactory()
    private val scheduler = TestCoroutineScheduler()

    // The service outlives any one call into it: the loop that applies what the
    // socket reports runs for as long as the chat is open. So it gets a scope of
    // its own, cancelled after each test, rather than the test's own scope,
    // which would wait forever for a loop designed never to finish.
    private val scope = CoroutineScope(SupervisorJob() + UnconfinedTestDispatcher(scheduler))

    @Before
    fun forgetEarlierLogs() {
        ShadowLog.clear()
    }

    @After
    fun stopTheService() {
        scope.cancel()
    }

    @Test
    fun opensTheSocketWithTheTokenAsAQueryParameter() = runTest(scheduler) {
        val service = service()

        service.connect("access")
        runCurrent()

        assertEquals(
            "https://chat.example.com/websocket/v1/connect/inapp?token=access",
            sockets.opened.single().url(),
        )
    }

    @Test
    fun encodesATokenThatWouldNotSurviveAUrl() = runTest(scheduler) {
        val service = service()

        service.connect("a b&c=d")
        runCurrent()

        assertEquals("a b&c=d", sockets.opened.single().queryParameter("token"))
    }

    @Test
    fun opensEveryAttemptWithTheTokenItWasGiven() = runTest(scheduler) {
        val service = service()
        service.connect("access")
        runCurrent()

        sockets.last().die()
        advanceTimeBy(SECOND_MILLIS + 1)

        assertEquals(listOf("access", "access"), sockets.opened.map { it.queryParameter("token") })
    }

    @Test
    fun handsBackTheMessageTheBackendSent() = runTest(scheduler) {
        val service = service()
        val seen = collect(service.messages)
        acknowledgedConnection(service)

        sockets.last().deliver(json(pollItem("wi-1", "hello")))
        runCurrent()

        val received = seen.single() as MessageReceived
        assertEquals("wi-1", received.item.id)
        assertEquals("hello", received.item.message.textMessageRequest.content.text)
    }

    @Test
    fun handsBackTheAcknowledgementForAMessageItSent() = runTest(scheduler) {
        val service = service()
        val seen = collect(service.messages)
        acknowledgedConnection(service)

        sockets.last().deliver(json(messageAck("cid-1")))
        runCurrent()

        assertEquals("cid-1", (seen.single() as MessageAcknowledged).ack.correlationId)
    }

    @Test
    fun ignoresAFrameThatIsNotJson() = runTest(scheduler) {
        val service = service()
        val seen = collect(service.messages)
        acknowledgedConnection(service)

        sockets.last().deliver("not json at all")
        sockets.last().deliver(json(pollItem("wi-1", "hello")))
        runCurrent()

        assertEquals(1, seen.size)
    }

    @Test
    fun ignoresAFrameCarryingATypeItDoesNotKnow() = runTest(scheduler) {
        val service = service()
        val seen = collect(service.messages)
        acknowledgedConnection(service)

        sockets.last().deliver("""{"type":"SOMETHING_NEW","connectionId":"c-9"}""")
        runCurrent()

        assertTrue(seen.isEmpty())
    }

    @Test
    fun dropsMessagesThatArriveBeforeTheConnectionIsAcknowledged() = runTest(scheduler) {
        val service = service()
        val seen = collect(service.messages)
        service.connect("access")
        runCurrent()
        sockets.last().open()
        runCurrent()

        sockets.last().deliver(json(pollItem("wi-1", "hello")))
        runCurrent()

        assertTrue(seen.isEmpty())
    }

    @Test
    fun sendsTheMessageOnceTheConnectionIsAcknowledged() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)

        val result = service.send(textMessage("cid-1", "hi"))
        runCurrent()

        assertTrue(result.isSuccess)
        assertEquals("hi", parsedSdkMessage(sockets.last().sent.single()).textMessageRequest.content.text)
    }

    @Test
    fun refusesAMessageWhileThereIsNoConnection() = runTest(scheduler) {
        val service = service()

        val result = service.send(textMessage("cid-1", "hi"))
        runCurrent()

        assertTrue(result.exceptionOrNull() is MessageConnectionClosedException)
        assertTrue(sockets.opened.isEmpty())
    }

    @Test
    fun refusesAMessageWhileTheConnectionIsNotAcknowledgedYet() = runTest(scheduler) {
        val service = service()
        service.connect("access")
        runCurrent()
        sockets.last().open()
        runCurrent()

        val result = service.send(textMessage("cid-1", "hi"))
        runCurrent()

        assertTrue(result.exceptionOrNull() is MessageConnectionClosedException)
    }

    @Test
    fun saysWhenTheChannelWillTakeMessages() = runTest(scheduler) {
        val service = service()
        val seen = mutableListOf<Boolean>()
        scope.launch { service.isReady.toList(seen) }
        runCurrent()

        acknowledgedConnection(service)
        sockets.last().die()
        runCurrent()

        assertEquals(listOf(false, true, false), seen)
    }

    @Test
    fun reportsAFailureWhenTheChatIsClosed() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)
        service.close()
        runCurrent()

        val result = service.send(textMessage("cid-1", "hi"))
        runCurrent()

        assertTrue(result.exceptionOrNull() is MessageConnectionClosedException)
    }

    @Test
    fun reportsAFailureWhenTheSocketRefusesTheFrame() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)
        sockets.last().refuseSends = true

        val result = service.send(textMessage("cid-1", "hi"))
        runCurrent()

        assertTrue(result.exceptionOrNull() is IOException)
    }

    @Test
    fun waitsLongerBeforeEachReconnectAttempt() = runTest(scheduler) {
        val service = service()
        service.connect("access")
        runCurrent()

        sockets.last().die()
        advanceTimeBy(SECOND_MILLIS + 1)
        assertEquals(2, sockets.opened.size)

        sockets.last().die()
        advanceTimeBy(SECOND_MILLIS + 1)
        assertEquals("a second failure waits longer than a second", 2, sockets.opened.size)

        advanceTimeBy(SECOND_MILLIS + 1)
        assertEquals(3, sockets.opened.size)
    }

    @Test
    fun neverWaitsLongerThanHalfAMinute() = runTest(scheduler) {
        val service = service()
        service.connect("access")
        runCurrent()

        // Six failures is past the point where the wait stops growing.
        repeat(6) {
            sockets.last().die()
            advanceTimeBy(MINUTE_MILLIS)
        }
        val opened = sockets.opened.size

        sockets.last().die()
        advanceTimeBy(HALF_MINUTE_MILLIS + 1)

        assertEquals(opened + 1, sockets.opened.size)
    }

    // A socket that opened has shown the line works, so the next failure is
    // treated as the first one rather than carrying the old delay on.
    @Test
    fun startsTheDelaysOverOnceASocketOpens() = runTest(scheduler) {
        val service = service()
        service.connect("access")
        runCurrent()
        sockets.last().die()
        advanceTimeBy(SECOND_MILLIS + 1)
        sockets.last().die()
        advanceTimeBy(MINUTE_MILLIS)

        sockets.last().open()
        runCurrent()
        sockets.last().die()
        advanceTimeBy(SECOND_MILLIS + 1)

        assertEquals("the wait is a second again", 4, sockets.opened.size)
    }

    @Test
    fun ignoresASecondRequestToConnect() = runTest(scheduler) {
        val service = service()
        service.connect("access")
        runCurrent()

        service.connect("another")
        runCurrent()

        assertEquals(1, sockets.opened.size)
    }

    @Test
    fun ignoresComingBackWhenItNeverWentAway() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)

        service.resume()
        runCurrent()

        assertEquals(1, sockets.opened.size)
    }

    @Test
    fun closesAConnectionThatIsNeverAcknowledged() = runTest(scheduler) {
        val service = service()
        service.connect("access")
        runCurrent()
        sockets.last().open()
        runCurrent()

        assertNull(sockets.last().closedWith)
        advanceTimeBy(ACK_TIMEOUT_MILLIS + 1)

        assertNotNull(sockets.last().closedWith)
    }

    @Test
    fun leavesAnAcknowledgedConnectionAloneWhenItGoesQuiet() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)

        advanceTimeBy(MINUTE_MILLIS)

        assertNull(sockets.opened.single().closedWith)
    }

    @Test
    fun reconnectsWhenTheServerClosesTheSocket() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)

        sockets.last().listener.onClosed(sockets.last(), NORMAL_CLOSURE, "bye")
        advanceTimeBy(SECOND_MILLIS + 1)

        assertEquals(2, sockets.opened.size)
    }

    @Test
    fun closesTheSocketWhenTheServerStartsClosingIt() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)

        sockets.last().listener.onClosing(sockets.last(), NORMAL_CLOSURE, "bye")
        runCurrent()

        assertNotNull(sockets.opened.single().closedWith)
    }

    @Test
    fun ignoresAFrameThatIsNotText() = runTest(scheduler) {
        val service = service()
        val seen = collect(service.messages)
        acknowledgedConnection(service)

        sockets.last().listener.onMessage(sockets.last(), "hello".encodeUtf8())
        runCurrent()

        assertTrue(seen.isEmpty())
    }

    @Test
    fun stopsAPendingReconnectWhenTheChatIsClosed() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)
        sockets.last().die()
        runCurrent()

        service.close()
        advanceTimeBy(MINUTE_MILLIS)

        assertEquals(1, sockets.opened.size)
    }

    @Test
    fun ignoresAFrameThatIsJsonButNotTheWireFormat() = runTest(scheduler) {
        val service = service()
        val seen = collect(service.messages)
        acknowledgedConnection(service)

        sockets.last().deliver("""{"date":"the day before yesterday"}""")
        runCurrent()

        assertTrue(seen.isEmpty())
    }

    @Test
    fun ignoresAnAcknowledgementOfAKindItDoesNotUnderstand() = runTest(scheduler) {
        val service = service()
        val seen = collect(service.messages)
        acknowledgedConnection(service)

        sockets.last().deliver(
            """{"type":"SDK_MESSAGE_ACK_TYPE_UNSPECIFIED","correlationId":"cid-1"}""",
        )
        runCurrent()

        assertTrue(seen.isEmpty())
    }

    @Test
    fun waitsForAnAcknowledgementOfTheRightKindBeforeSending() = runTest(scheduler) {
        val service = service()
        service.connect("access")
        runCurrent()
        sockets.last().open()
        service.send(textMessage("cid-1", "held"))
        runCurrent()

        sockets.last().deliver("""{"type":"CONNECTION_ACK_TYPE_UNSPECIFIED","connectionId":"c-1"}""")
        runCurrent()
        assertTrue("an unspecified acknowledgement is not one", sockets.last().sent.isEmpty())

        sockets.last().acknowledge()
        runCurrent()

        assertEquals(1, sockets.last().sent.size)
    }

    @Test
    fun stopsReconnectingOnceTheChatIsClosed() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)

        service.close()
        advanceTimeBy(MINUTE_MILLIS)

        assertEquals(1, sockets.opened.size)
        assertNotNull(sockets.opened.single().closedWith)
    }

    @Test
    fun dropsTheSocketWhenTheAppGoesAwayAndOpensAnotherWhenItComesBack() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)

        service.pause()
        advanceTimeBy(MINUTE_MILLIS)
        assertEquals("nothing is retried while the app is away", 1, sockets.opened.size)
        assertNotNull(sockets.opened.first().closedWith)

        service.resume()
        runCurrent()

        assertEquals(2, sockets.opened.size)
    }

    private fun service(): YaloMessageService = YaloMessageServiceWebsocket(
        scope = scope,
        baseUrl = BASE_URL,
        sockets = sockets,
        logLevel = LogLevel.Debug,
    )

    /** Drives a service all the way to a connection the server has acknowledged. */
    private suspend fun TestScope.acknowledgedConnection(service: YaloMessageService) {
        service.connect("access")
        runCurrent()
        sockets.last().open()
        sockets.last().acknowledge()
        runCurrent()
    }

    @Test
    fun writesWhatItSentSoAConversationCanBeFollowed() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)

        service.send(textMessage("cid-1", "hi"))
        runCurrent()

        assertTrue(logged().any { line -> line.contains("sent") && line.contains("\"text\":\"hi\"") })
    }

    @Test
    fun writesWhatTheBackendSentSoAConversationCanBeFollowed() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)

        sockets.last().deliver(json(pollItem("wi-1", "hello")))
        runCurrent()

        assertTrue(logged().any { line -> line.contains("received") && line.contains("\"text\":\"hello\"") })
    }

    // The token only ever travels in the address the socket is opened with, and
    // that is the one thing these lines must never carry.
    @Test
    fun writesNoTokenWhileFollowingAConversation() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)

        service.send(textMessage("cid-1", "hi"))
        sockets.last().deliver(json(pollItem("wi-1", "hello")))
        runCurrent()

        assertTrue(logged().none { line -> line.contains("access") })
    }

    private fun logged(): List<String> = ShadowLog.getLogs()
        .filter { item -> item.tag == YaloLog.TAG }
        .map { item -> item.msg }

    // Subscribing eagerly matters: the flow is hot and replays nothing, so a
    // collector that starts a moment late sees none of what the test then makes
    // the server send.
    private fun TestScope.collect(messages: Flow<InboundMessage>): List<InboundMessage> {
        val seen = mutableListOf<InboundMessage>()
        backgroundScope.launch(UnconfinedTestDispatcher(scheduler)) {
            messages.collect { message -> seen += message }
        }
        return seen
    }

    private fun json(message: com.google.protobuf.Message): String = PRINTER.print(message)

    private fun parsedSdkMessage(frame: String): SdkMessage =
        SdkMessage.newBuilder().also { PARSER.merge(frame, it) }.build()

    private fun textMessage(correlationId: String, text: String): SdkMessage = SdkMessage.newBuilder()
        .setCorrelationId(correlationId)
        .setTextMessageRequest(
            TextMessageRequest.newBuilder().setContent(
                TextMessage.newBuilder()
                    .setText(text)
                    .setRole(MessageRole.MESSAGE_ROLE_USER),
            ),
        )
        .build()

    private fun pollItem(id: String, text: String): PollMessageItem = PollMessageItem.newBuilder()
        .setId(id)
        .setUserId("user-1")
        .setStatus("DELIVERED")
        .setMessage(textMessage("cid-$id", text))
        .build()

    private fun messageAck(correlationId: String): SdkMessageAck = SdkMessageAck.newBuilder()
        .setType(SdkMessageAckType.SDK_MESSAGE_ACK_TYPE_MESSAGE_ACK)
        .setCorrelationId(correlationId)
        .build()

    private companion object {

        val BASE_URL: HttpUrl = "https://chat.example.com/".toHttpUrl()

        const val SECOND_MILLIS = 1_000L
        const val ACK_TIMEOUT_MILLIS = 10_000L
        const val MINUTE_MILLIS = 60_000L
        const val HALF_MINUTE_MILLIS = 30_000L

        /** What the service will hold before it starts forgetting. */
        const val HELD_LIMIT = 128
        const val NORMAL_CLOSURE = 1_000

        val PRINTER: JsonFormat.Printer = JsonFormat.printer().omittingInsignificantWhitespace()
        val PARSER: JsonFormat.Parser = JsonFormat.parser().ignoringUnknownFields()

        val CONNECTION_ACK: ConnectionAck = ConnectionAck.newBuilder()
            .setType(ConnectionAckType.CONNECTION_ACK_TYPE_CONNECTION_ACK)
            .setConnectionId("connection-1")
            .build()
    }

    /**
     * Hands out fakes and remembers them, so a test can ask how many attempts
     * were made and what each of them was addressed to.
     */
    private class FakeWebSocketFactory : WebSocket.Factory {

        val opened = mutableListOf<FakeWebSocket>()

        override fun newWebSocket(request: Request, listener: WebSocketListener): WebSocket =
            FakeWebSocket(request, listener).also { opened += it }

        fun last(): FakeWebSocket = opened.last()
    }

    private class FakeWebSocket(
        private val request: Request,
        val listener: WebSocketListener,
    ) : WebSocket {

        val sent = mutableListOf<String>()
        var closedWith: Int? = null
        var refuseSends = false

        fun url(): String = request.url.toString()

        fun queryParameter(name: String): String? = request.url.queryParameter(name)

        fun open() {
            listener.onOpen(
                this,
                Response.Builder()
                    .request(request)
                    .protocol(Protocol.HTTP_1_1)
                    .code(101)
                    .message("Switching Protocols")
                    .build(),
            )
        }

        fun acknowledge() {
            deliver(PRINTER.print(CONNECTION_ACK))
        }

        fun deliver(frame: String) {
            listener.onMessage(this, frame)
        }

        fun die() {
            listener.onFailure(this, IOException("the socket died"), null)
        }

        override fun request(): Request = request

        override fun queueSize(): Long = 0

        override fun send(text: String): Boolean {
            if (refuseSends) {
                return false
            }
            sent += text
            return true
        }

        override fun send(bytes: ByteString): Boolean = send(bytes.utf8())

        override fun close(code: Int, reason: String?): Boolean {
            closedWith = code
            return true
        }

        override fun cancel() = Unit
    }

}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.message

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.log.YaloLog
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
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
 * Covers the conversation the SDK holds with the channel: the address it dials,
 * the wire format it reads and writes, what it does with a message while the
 * line is down and how long it waits before opening the line again.
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
    private val auth = FakeTokenRepository()
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

        service.connect()
        runCurrent()

        assertEquals(
            "https://chat.example.com/websocket/v1/connect/inapp?token=access",
            sockets.opened.single().url(),
        )
    }

    @Test
    fun encodesATokenThatWouldNotSurviveAUrl() = runTest(scheduler) {
        auth.current = "a b&c=d"
        val service = service()

        service.connect()
        runCurrent()

        assertEquals("a b&c=d", sockets.opened.single().queryParameter("token"))
    }

    @Test
    fun fetchesAFreshTokenForEveryAttempt() = runTest(scheduler) {
        val service = service()
        service.connect()
        runCurrent()

        auth.current = "second"
        sockets.last().die()
        advanceTimeBy(SECOND_MILLIS + 1)

        assertEquals(listOf("access", "second"), sockets.opened.map { it.queryParameter("token") })
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
        service.connect()
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
    fun holdsMessagesUntilTheConnectionIsAcknowledged() = runTest(scheduler) {
        val service = service()
        service.connect()
        runCurrent()
        sockets.last().open()
        runCurrent()

        val result = service.send(textMessage("cid-1", "held"))
        runCurrent()
        assertTrue(result.isSuccess)
        assertTrue(sockets.last().sent.isEmpty())

        sockets.last().acknowledge()
        runCurrent()

        assertEquals("cid-1", parsedSdkMessage(sockets.last().sent.single()).correlationId)
    }

    @Test
    fun reportsAFailureWhenTheChatIsNotOpen() = runTest(scheduler) {
        val service = service()

        val result = service.send(textMessage("cid-1", "hi"))
        runCurrent()

        assertTrue(result.exceptionOrNull() is MessageServiceClosedException)
        assertTrue(sockets.opened.isEmpty())
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
        service.connect()
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
    fun closesAConnectionThatIsNeverAcknowledged() = runTest(scheduler) {
        val service = service()
        service.connect()
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
    fun waitsAndTriesAgainWhenNoTokenCanBeFetched() = runTest(scheduler) {
        auth.failure = IOException("no token")
        val service = service()

        service.connect()
        runCurrent()
        assertTrue(sockets.opened.isEmpty())

        auth.failure = null
        advanceTimeBy(SECOND_MILLIS + 1)

        assertEquals(1, sockets.opened.size)
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
        service.connect()
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

    @Test
    fun opensOnlyOneSocketWhenAskedToConnectTwice() = runTest(scheduler) {
        val service = service()

        service.connect()
        service.connect()
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
    fun keepsWhatItWasHoldingWhileTheAppIsAway() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)
        service.pause()
        runCurrent()

        val result = service.send(textMessage("cid-1", "held"))
        service.resume()
        sockets.last().open()
        sockets.last().acknowledge()
        runCurrent()

        assertTrue(result.isSuccess)
        assertEquals("cid-1", parsedSdkMessage(sockets.last().sent.single()).correlationId)
    }

    @Test
    fun forgetsWhatItWasHoldingWhenTheChatIsClosed() = runTest(scheduler) {
        val service = service()
        service.connect()
        runCurrent()
        sockets.last().open()
        service.send(textMessage("cid-1", "held"))
        runCurrent()

        service.close()
        service.connect()
        sockets.last().open()
        sockets.last().acknowledge()
        runCurrent()

        assertTrue(sockets.last().sent.isEmpty())
    }

    @Test
    fun reportsAFailureWhenTheChatIsClosedAgain() = runTest(scheduler) {
        val service = service()
        acknowledgedConnection(service)
        service.close()

        val result = service.send(textMessage("cid-1", "hi"))
        runCurrent()

        assertTrue(result.exceptionOrNull() is MessageServiceClosedException)
    }

    @Test
    fun dropsTheOldestHeldMessageWhenTooManyPileUp() = runTest(scheduler) {
        val service = service()
        service.connect()
        runCurrent()
        sockets.last().open()

        repeat(MAX_PENDING_FRAMES + 1) { index ->
            service.send(textMessage("cid-$index", "held"))
        }
        runCurrent()
        sockets.last().acknowledge()
        runCurrent()

        val sent = sockets.last().sent
        assertEquals(MAX_PENDING_FRAMES, sent.size)
        assertEquals("cid-1", parsedSdkMessage(sent.first()).correlationId)
    }

    @Test
    fun startsTheDelaysOverOnceASocketOpens() = runTest(scheduler) {
        val service = service()
        service.connect()
        runCurrent()

        sockets.last().die()
        advanceTimeBy(SECOND_MILLIS + 1)
        sockets.last().die()
        advanceTimeBy(2 * SECOND_MILLIS + 1)
        assertEquals(3, sockets.opened.size)

        sockets.last().open()
        runCurrent()
        sockets.last().die()
        advanceTimeBy(SECOND_MILLIS + 1)

        assertEquals("a socket that opened puts the waits back to a second", 4, sockets.opened.size)
    }

    @Test
    fun neverWaitsLongerThanHalfAMinuteBetweenAttempts() = runTest(scheduler) {
        val service = service()
        service.connect()
        runCurrent()
        repeat(ATTEMPTS_TO_THE_LONGEST_WAIT) {
            sockets.last().die()
            advanceTimeBy(MAX_BACKOFF_MILLIS + 1)
        }
        val attempts = sockets.opened.size

        sockets.last().die()
        advanceTimeBy(MAX_BACKOFF_MILLIS)
        assertEquals(attempts, sockets.opened.size)
        advanceTimeBy(1)

        assertEquals(attempts + 1, sockets.opened.size)
    }

    private fun service(): YaloMessageService = YaloMessageServiceWebsocket(
        auth = auth,
        scope = scope,
        baseUrl = BASE_URL,
        sockets = sockets,
        logLevel = LogLevel.Debug,
    )

    /** Drives a service all the way to a connection the server has acknowledged. */
    private suspend fun TestScope.acknowledgedConnection(service: YaloMessageService) {
        service.connect()
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
        const val MAX_BACKOFF_MILLIS = 30_000L
        const val MAX_PENDING_FRAMES = 128

        // 1s, 2s, 4s, 8s and 16s, after which the wait stops growing.
        const val ATTEMPTS_TO_THE_LONGEST_WAIT = 5
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

    private class FakeTokenRepository : TokenRepository {

        var current: String = "access"
        var failure: Throwable? = null

        override suspend fun token(): Result<String> =
            failure?.let { cause -> Result.failure(cause) } ?: Result.success(current)

        override suspend fun invalidateToken() = Unit

        override suspend fun clearSession() = Unit
    }
}

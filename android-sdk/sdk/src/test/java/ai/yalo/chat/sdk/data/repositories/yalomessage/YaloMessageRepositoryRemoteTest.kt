// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.yalomessage

import ai.yalo.chat.sdk.data.datasources.message.InboundMessage
import ai.yalo.chat.sdk.data.datasources.message.MessageAcknowledged
import ai.yalo.chat.sdk.data.datasources.message.MessageReceived
import ai.yalo.chat.sdk.data.datasources.message.YaloMessageDataSource
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageButtonType
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageStatus
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.domain.models.VoiceNote
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.Button
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ButtonType
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ChatStatusRequest
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ImageMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ImageMessageRequest
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessageAck
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.TextMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.TextMessageRequest
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.VoiceMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.VoiceNoteMessageRequest
import com.google.protobuf.util.Timestamps
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.io.IOException
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.MessageRole as WireRole
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.MessageStatus as WireStatus

// Robolectric is here for the lines the repository writes about the line it is
// holding: logcat throws out of a plain JVM test.
@OptIn(ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
class YaloMessageRepositoryRemoteTest {

    private val source = FakeYaloMessageDataSource()
    private val auth = FakeTokenRepository()
    private val scheduler = TestCoroutineScheduler()

    // Holding the line open is a coroutine that runs for as long as the chat
    // does, so the repository gets a scope of its own, cancelled after each
    // test, rather than the test's own scope, which would wait forever for it.
    private val scope = CoroutineScope(SupervisorJob() + UnconfinedTestDispatcher(scheduler))

    @After
    fun stopTheRepository() {
        scope.cancel()
    }

    @Test
    fun sendsWhatThePersonWrote() = runTest(scheduler) {
        connected().send(message(content = "Hello"))

        assertEquals("Hello", sentText())
    }

    @Test
    fun sendsAMessageAsComingFromWhoeverWroteIt() = runTest(scheduler) {
        connected().send(message(role = MessageRole.User))

        assertEquals(WireRole.MESSAGE_ROLE_USER, source.sent.single().textMessageRequest.content.role)
    }

    @Test
    fun sendsAMessageAsComingFromTheChannelWhenThatIsWhoWroteIt() = runTest(scheduler) {
        connected().send(message(role = MessageRole.Agent))

        assertEquals(WireRole.MESSAGE_ROLE_AGENT, source.sent.single().textMessageRequest.content.role)
    }

    // Whatever the stored row says, a message on its way out has not arrived
    // anywhere yet.
    @Test
    fun sendsAMessageAsNotYetArrived() = runTest(scheduler) {
        connected().send(message(status = MessageStatus.Delivered))

        assertEquals(
            WireStatus.MESSAGE_STATUS_IN_PROGRESS,
            source.sent.single().textMessageRequest.content.status,
        )
    }

    @Test
    fun keepsTheTimeTheMessageWasWritten() = runTest(scheduler) {
        connected().send(message(timestamp = WRITTEN_AT))

        assertEquals(
            WRITTEN_AT,
            Timestamps.toMillis(source.sent.single().textMessageRequest.content.timestamp),
        )
    }

    @Test
    fun saysWhenTheMessageWasSentApartFromWhenItWasWritten() = runTest(scheduler) {
        connected().send(message(timestamp = WRITTEN_AT))

        assertEquals(SENT_AT, Timestamps.toMillis(source.sent.single().timestamp))
    }

    // An acknowledgement comes back naming the correlation id, so the row id is
    // what lets the answer find the message it belongs to.
    @Test
    fun namesTheMessageAfterTheRowItWasStoredAs() = runTest(scheduler) {
        connected().send(message(id = 42L))

        assertEquals("42", source.sent.single().correlationId)
    }

    @Test
    fun givesAMessageThatWasNeverStoredAnIdOfItsOwn() = runTest(scheduler) {
        connected().send(message(id = null))

        assertEquals("generated-id", source.sent.single().correlationId)
    }

    @Test
    fun reportsAMessageTheChannelTook() = runTest(scheduler) {
        val result = connected().send(message())

        assertTrue(result.isSuccess)
    }

    @Test
    fun reportsAMessageTheChannelWouldNotTake() = runTest(scheduler) {
        source.failure = IOException("the line is down")

        val result = connected().send(message())

        assertEquals("the line is down", result.exceptionOrNull()?.message)
    }

    @Test
    fun refusesAKindOfMessageItCannotPutOnTheWireYet() = runTest(scheduler) {
        val result = connected().send(message(type = MessageType.Image))

        assertTrue(result.exceptionOrNull() is UnsupportedMessageTypeException)
        assertEquals(emptyList<SdkMessage>(), source.sent)
    }

    @Test
    fun sendsAVoiceNoteUnderTheNameTheUploadGaveIt() = runTest(scheduler) {
        connected().send(voiceMessage(note = recorded(mediaUrl = "media-42")))

        val sent = source.sent.single().voiceNoteMessageRequest.content
        assertEquals("media-42", sent.mediaUrl)
        assertEquals("audio/mp4", sent.mediaType)
        assertEquals("voice-1.m4a", sent.fileName)
        assertEquals(2_048L, sent.byteCount)
    }

    @Test
    fun sendsAVoiceNoteLengthInSeconds() = runTest(scheduler) {
        connected().send(voiceMessage(note = recorded(durationMillis = 4_500)))

        assertEquals(4.5, source.sent.single().voiceNoteMessageRequest.content.duration, TOLERANCE)
    }

    @Test
    fun sendsTheWaveformAVoiceNoteIsDrawnFrom() = runTest(scheduler) {
        connected().send(voiceMessage(note = recorded(amplitudes = listOf(0.25f, 1f))))

        assertEquals(
            listOf(0.25f, 1f),
            source.sent.single().voiceNoteMessageRequest.content.amplitudesPreviewList,
        )
    }

    @Test
    fun sendsAVoiceNoteAsNotHavingArrivedAnywhereYet() = runTest(scheduler) {
        connected().send(voiceMessage(note = recorded()))

        val sent = source.sent.single().voiceNoteMessageRequest.content
        assertEquals(WireStatus.MESSAGE_STATUS_IN_PROGRESS, sent.status)
        assertEquals(WireRole.MESSAGE_ROLE_USER, sent.role)
    }

    @Test
    fun refusesAVoiceMessageWithNothingToPlay() = runTest(scheduler) {
        val result = connected().send(voiceMessage(note = null))

        assertTrue(result.exceptionOrNull() is UnsupportedMessageTypeException)
        assertEquals(emptyList<SdkMessage>(), source.sent)
    }

    @Test
    fun readsAVoiceNoteTheChannelSent() = runTest(scheduler) {
        val received = received(pollItem(wireVoiceMessage()))

        val note = received.single().voice
        assertEquals(MessageType.Voice, received.single().type)
        assertEquals("https://media.example.com/note.m4a", note?.mediaUrl)
        assertEquals("audio/mp4", note?.mediaType)
        assertEquals(4_500L, note?.durationMillis)
        assertEquals(listOf(0.25f, 1f), note?.amplitudes)
    }

    @Test
    fun readsAVoiceNoteTheChannelSentAsHavingNoFileHere() = runTest(scheduler) {
        val received = received(pollItem(wireVoiceMessage()))

        assertNull(received.single().voice?.localPath)
    }

    @Test
    fun leavesTheRecordingOffAMessageThatIsNotAVoiceNote() = runTest(scheduler) {
        val received = received(pollItem(textMessage()))

        assertNull(received.single().voice)
    }

    @Test
    fun asksTheChannelToOpenTheConversation() = runTest(scheduler) {
        connected().requestGuidanceCard()

        assertEquals(
            SdkMessage.PayloadCase.GUIDANCE_CARD_REQUEST,
            source.sent.single().payloadCase,
        )
        assertEquals(SENT_AT, Timestamps.toMillis(source.sent.single().guidanceCardRequest.timestamp))
    }

    @Test
    fun saysWhatTheChatWasOpenedFrom() = runTest(scheduler) {
        connected().requestGuidanceCard(mapOf("source" to "product-page", "sku" to "123"))

        assertEquals(
            """{"source":"product-page","sku":"123"}""",
            source.sent.single().guidanceCardRequest.context,
        )
    }

    // A context the channel could not read back is worse than none, so what a
    // host puts in a value cannot break out of it.
    @Test
    fun saysAContextWithQuotesAndLineBreaksInItWithoutBreakingTheJson() = runTest(scheduler) {
        connected().requestGuidanceCard(
            mapOf("note" to "a \"quoted\" \\ line\r\n\tand a \u0001 of its own"),
        )

        assertEquals(
            """{"note":"a \"quoted\" \\ line\r\n\tand a \u0001 of its own"}""",
            source.sent.single().guidanceCardRequest.context,
        )
    }

    @Test
    fun leavesTheContextOutWhenTheChatWasOpenedFromNothing() = runTest(scheduler) {
        connected().requestGuidanceCard()

        assertFalse(source.sent.single().guidanceCardRequest.hasContext())
    }

    @Test
    fun reportsAnOpenTheChannelWouldNotTake() = runTest(scheduler) {
        source.failure = IOException("the line is down")

        val result = connected().requestGuidanceCard()

        assertEquals("the line is down", result.exceptionOrNull()?.message)
    }

    @Test
    fun opensTheLineToTheChannel() = runTest(scheduler) {
        connected()

        assertEquals(listOf("access"), source.tokens)
    }

    @Test
    fun opensOnlyOneLineWhenAskedToConnectTwice() = runTest(scheduler) {
        val repository = connected()

        repository.connect()
        runCurrent()

        assertEquals(1, source.tokens.size)
    }

    // The token that opened the last socket may have run out while it was up.
    @Test
    fun opensEverySocketWithAFreshToken() = runTest(scheduler) {
        connected()

        auth.current = "second"
        source.endSession()
        advanceTimeBy(SECOND_MILLIS + 1)

        assertEquals(listOf("access", "second"), source.tokens)
    }

    @Test
    fun waitsLongerBeforeEachAttemptThatGetsNowhere() = runTest(scheduler) {
        connected()

        source.endSession(opened = false)
        advanceTimeBy(SECOND_MILLIS + 1)
        assertEquals(2, source.tokens.size)

        source.endSession(opened = false)
        advanceTimeBy(SECOND_MILLIS + 1)
        assertEquals("a second failure waits longer than a second", 2, source.tokens.size)

        advanceTimeBy(SECOND_MILLIS + 1)
        assertEquals(3, source.tokens.size)
    }

    @Test
    fun startsTheWaitsOverOnceASocketOpens() = runTest(scheduler) {
        connected()
        source.endSession(opened = false)
        advanceTimeBy(SECOND_MILLIS + 1)
        source.endSession(opened = false)
        advanceTimeBy(2 * SECOND_MILLIS + 1)
        assertEquals(3, source.tokens.size)

        source.endSession(opened = true)
        advanceTimeBy(SECOND_MILLIS + 1)

        assertEquals("a socket that opened puts the waits back to a second", 4, source.tokens.size)
    }

    @Test
    fun neverWaitsLongerThanHalfAMinuteBetweenAttempts() = runTest(scheduler) {
        connected()
        repeat(ATTEMPTS_TO_THE_LONGEST_WAIT) {
            source.endSession(opened = false)
            advanceTimeBy(MAX_BACKOFF_MILLIS + 1)
        }
        val attempts = source.tokens.size

        source.endSession(opened = false)
        advanceTimeBy(MAX_BACKOFF_MILLIS)
        assertEquals(attempts, source.tokens.size)
        advanceTimeBy(1)

        assertEquals(attempts + 1, source.tokens.size)
    }

    @Test
    fun waitsAndAsksAgainWhenNoTokenCanBeHad() = runTest(scheduler) {
        auth.failure = IOException("no token")

        connected()
        assertTrue(source.tokens.isEmpty())

        auth.failure = null
        advanceTimeBy(SECOND_MILLIS + 1)

        assertEquals(1, source.tokens.size)
    }

    @Test
    fun endsTheConversation() = runTest(scheduler) {
        val repository = connected()

        repository.close()
        advanceTimeBy(MINUTE_MILLIS)

        assertEquals(1, source.tokens.size)
        assertTrue(source.isForgotten)
    }

    @Test
    fun opensNoOtherLineWhenTheChatIsClosedWhileOneIsDue() = runTest(scheduler) {
        val repository = connected()
        source.endSession(opened = false)
        runCurrent()

        repository.close()
        advanceTimeBy(MINUTE_MILLIS)

        assertEquals(1, source.tokens.size)
    }

    @Test
    fun dropsTheLineWhenTheAppGoesAwayAndOpensItAgainWhenItComesBack() = runTest(scheduler) {
        val repository = connected()

        repository.pause()
        advanceTimeBy(MINUTE_MILLIS)
        assertEquals("nothing is opened while the app is away", 1, source.tokens.size)
        assertFalse(source.hasSession)

        repository.resume()
        runCurrent()

        assertEquals(2, source.tokens.size)
    }

    @Test
    fun ignoresGoingAwayWhenTheChatWasNeverOpened() = runTest(scheduler) {
        repository().pause()
        runCurrent()

        assertTrue(source.tokens.isEmpty())
    }

    @Test
    fun ignoresComingBackWhenItNeverWentAway() = runTest(scheduler) {
        val repository = connected()

        repository.resume()
        runCurrent()

        assertEquals(1, source.tokens.size)
    }

    @Test
    fun reportsAFailureWhenTheChatWasNeverOpened() = runTest(scheduler) {
        val result = repository().send(message())

        assertTrue(result.exceptionOrNull() is ChatClosedException)
        assertTrue(source.sent.isEmpty())
    }

    @Test
    fun reportsAFailureWhenTheChatIsClosedAgain() = runTest(scheduler) {
        val repository = connected()
        repository.close()
        runCurrent()

        val result = repository.send(message())

        assertTrue(result.exceptionOrNull() is ChatClosedException)
    }

    @Test
    fun saysNothingToTheChannelOnceTheChatIsClosed() = runTest(scheduler) {
        val repository = connected()
        repository.close()
        runCurrent()

        val result = repository.requestGuidanceCard()

        assertTrue(result.exceptionOrNull() is ChatClosedException)
        assertTrue(source.sent.isEmpty())
    }

    @Test
    fun readsWhatTheChannelSaid() = runTest(scheduler) {
        val received = received(pollItem(textMessage("On its way")))

        assertEquals("On its way", received.single().content)
        assertEquals(MessageRole.Agent, received.single().role)
        assertEquals(MessageType.Text, received.single().type)
    }

    // The backend's id is what tells a repeat from a new message.
    @Test
    fun keepsTheIdTheChannelGaveTheMessage() = runTest(scheduler) {
        val received = received(pollItem(textMessage(), id = "wi-7"))

        assertEquals("wi-7", received.single().wiId)
    }

    @Test
    fun keepsTheTimeTheChannelRecordedTheMessage() = runTest(scheduler) {
        val received = received(pollItem(textMessage(), date = ARRIVED_AT))

        assertEquals(ARRIVED_AT, received.single().timestamp)
    }

    @Test
    fun timesAMessageThatArrivedWithoutADateAsNow() = runTest(scheduler) {
        val received = received(pollItem(textMessage(), date = null))

        assertEquals(SENT_AT, received.single().timestamp)
    }

    @Test
    fun keepsWhatWasWrittenAroundTheMessage() = runTest(scheduler) {
        val message = textMessage(header = "Your order", footer = "Reply to change it")

        val received = received(pollItem(message))

        assertEquals("Your order", received.single().header)
        assertEquals("Reply to change it", received.single().footer)
    }

    @Test
    fun leavesOutAHeaderAndFooterTheChannelDidNotSend() = runTest(scheduler) {
        val received = received(pollItem(textMessage()))

        assertEquals(null, received.single().header)
        assertEquals(null, received.single().footer)
    }

    // A picture the chat cannot draw yet still has to show up as something.
    @Test
    fun readsAKindItCannotDrawYetAsThatKind() = runTest(scheduler) {
        val received = received(pollItem(imageMessage()))

        assertEquals(MessageType.Image, received.single().type)
    }

    @Test
    fun readsAStatusItDoesNotKnowAsArrived() = runTest(scheduler) {
        val received = received(pollItem(textMessage(), status = "SOMETHING_NEWER"))

        assertEquals(MessageStatus.Delivered, received.single().status)
    }

    @Test
    fun takesTheChannelsWordForHowFarTheMessageGot() = runTest(scheduler) {
        val received = received(pollItem(textMessage(), status = "READ"))

        assertEquals(MessageStatus.Read, received.single().status)
    }

    @Test
    fun leavesOutWhatIsNotSomethingAnyoneSaid() = runTest(scheduler) {
        val status = SdkMessage.newBuilder()
            .setChatStatusRequest(ChatStatusRequest.newBuilder().setStatus("typing"))
            .build()

        assertEquals(emptyList<ChatMessage>(), received(pollItem(status)))
    }

    @Test
    fun readsTheAnswersAMessageOffers() = runTest(scheduler) {
        val message = textMessage(buttons = listOf(button("Yes"), button("No")))

        val received = received(pollItem(message))

        assertEquals(listOf("Yes", "No"), received.single().buttons.map { it.text })
    }

    @Test
    fun keepsWhatEachButtonIsForApartFromWhatItSays() = runTest(scheduler) {
        val message = textMessage(
            buttons = listOf(
                button("Yes", ButtonType.BUTTON_TYPE_REPLY),
                button("Track it", ButtonType.BUTTON_TYPE_POSTBACK),
                button("Open the store", ButtonType.BUTTON_TYPE_LINK, url = "https://yalo.com"),
            ),
        )

        val received = received(pollItem(message))

        assertEquals(
            listOf(MessageButtonType.Reply, MessageButtonType.Postback, MessageButtonType.Link),
            received.single().buttons.map { it.type },
        )
    }

    @Test
    fun keepsWhereALinkGoes() = runTest(scheduler) {
        val message = textMessage(
            buttons = listOf(button("Open the store", ButtonType.BUTTON_TYPE_LINK, url = "https://yalo.com")),
        )

        val received = received(pollItem(message))

        assertEquals("https://yalo.com", received.single().buttons.single().url)
    }

    @Test
    fun leavesOutAnAddressAButtonNeverCarried() = runTest(scheduler) {
        val received = received(pollItem(textMessage(buttons = listOf(button("Yes")))))

        assertEquals(null, received.single().buttons.single().url)
    }

    // A button kind only a newer backend knows still has to do something, and
    // answering is the one thing every button can do.
    @Test
    fun readsAButtonKindItDoesNotKnowAsAnAnswer() = runTest(scheduler) {
        val newerKind = Button.newBuilder().setText("Yes").setButtonTypeValue(99).build()

        val received = received(pollItem(textMessage(buttons = listOf(newerKind))))

        assertEquals(MessageButtonType.Reply, received.single().buttons.single().type)
    }

    @Test
    fun readsTheAnswersOfferedWithAMessageItCannotDrawYet() = runTest(scheduler) {
        val received = received(pollItem(imageMessage(buttons = listOf(button("Yes")))))

        assertEquals(listOf("Yes"), received.single().buttons.map { it.text })
    }

    @Test
    fun offersNothingForAMessageWithNoButtons() = runTest(scheduler) {
        val received = received(pollItem(textMessage()))

        assertEquals(emptyList<String>(), received.single().buttons.map { it.text })
    }

    @Test
    fun leavesOutAnAcknowledgement() = runTest(scheduler) {
        val received = received(MessageAcknowledged(SdkMessageAck.getDefaultInstance()))

        assertEquals(emptyList<ChatMessage>(), received)
    }

    private fun sentText(): String = source.sent.single().textMessageRequest.content.text

    /** What the repository makes of [inbound], once the channel has sent it. */
    private fun TestScope.received(vararg inbound: InboundMessage): List<ChatMessage> {
        val received = mutableListOf<ChatMessage>()
        val collector = launch {
            repository().messages().collect { message -> received.add(message) }
        }
        runCurrent()
        inbound.forEach { message -> source.receive(message) }
        runCurrent()
        collector.cancel()
        return received
    }

    private fun TestScope.received(vararg items: PollMessageItem): List<ChatMessage> =
        received(*items.map { item -> MessageReceived(item) }.toTypedArray())

    private fun pollItem(
        message: SdkMessage,
        id: String = "wi-1",
        date: Long? = ARRIVED_AT,
        status: String = "DELIVERED",
    ): PollMessageItem = PollMessageItem.newBuilder()
        .setId(id)
        .setMessage(message)
        .setStatus(status)
        .also { item ->
            if (date != null) {
                item.date = Timestamps.fromMillis(date)
            }
        }
        .build()

    private fun button(
        text: String,
        type: ButtonType = ButtonType.BUTTON_TYPE_REPLY,
        url: String? = null,
    ): Button = Button.newBuilder()
        .setText(text)
        .setButtonType(type)
        .also { button ->
            if (url != null) {
                button.url = url
            }
        }
        .build()

    private fun textMessage(
        text: String = "On its way",
        header: String? = null,
        footer: String? = null,
        buttons: List<Button> = emptyList(),
    ): SdkMessage {
        val request = TextMessageRequest.newBuilder()
            .setContent(
                TextMessage.newBuilder()
                    .setText(text)
                    .setRole(WireRole.MESSAGE_ROLE_AGENT),
            )
            .addAllButtons(buttons)
        if (header != null) {
            request.header = header
        }
        if (footer != null) {
            request.footer = footer
        }
        return SdkMessage.newBuilder().setTextMessageRequest(request).build()
    }

    private fun recorded(
        durationMillis: Long = 4_200,
        amplitudes: List<Float> = listOf(0.1f, 0.9f),
        mediaUrl: String = "media-1",
    ): VoiceNote = VoiceNote(
        durationMillis = durationMillis,
        amplitudes = amplitudes,
        mediaUrl = mediaUrl,
        mediaType = "audio/mp4",
        fileName = "voice-1.m4a",
        byteCount = 2_048,
        localPath = "/files/voice-1.m4a",
    )

    private fun voiceMessage(note: VoiceNote?): ChatMessage = ChatMessage(
        role = MessageRole.User,
        type = MessageType.Voice,
        timestamp = WRITTEN_AT,
        id = 1L,
        voice = note,
    )

    private fun wireVoiceMessage(): SdkMessage = SdkMessage.newBuilder()
        .setVoiceNoteMessageRequest(
            VoiceNoteMessageRequest.newBuilder()
                .setContent(
                    VoiceMessage.newBuilder()
                        .setMediaUrl("https://media.example.com/note.m4a")
                        .setMediaType("audio/mp4")
                        .setFileName("note.m4a")
                        .setByteCount(4_096)
                        .setDuration(4.5)
                        .addAllAmplitudesPreview(listOf(0.25f, 1f))
                        .setRole(WireRole.MESSAGE_ROLE_AGENT),
                ),
        )
        .build()

    private fun imageMessage(buttons: List<Button> = emptyList()): SdkMessage = SdkMessage.newBuilder()
        .setImageMessageRequest(
            ImageMessageRequest.newBuilder()
                .setContent(ImageMessage.newBuilder().setMediaUrl("https://yalo.com/shirt.png"))
                .addAllButtons(buttons),
        )
        .build()

    /** A chat with its line open, which is what anything is sent from. */
    private fun TestScope.connected(): YaloMessageRepositoryRemote = repository().also { repository ->
        repository.connect()
        runCurrent()
    }

    private fun repository(): YaloMessageRepositoryRemote = YaloMessageRepositoryRemote(
        source = source,
        auth = auth,
        scope = scope,
        now = { SENT_AT },
        correlationIds = { "generated-id" },
    )

    private fun message(
        content: String = "Hello",
        role: MessageRole = MessageRole.User,
        type: MessageType = MessageType.Text,
        status: MessageStatus = MessageStatus.InProgress,
        timestamp: Long = WRITTEN_AT,
        id: Long? = 1L,
    ): ChatMessage = ChatMessage(
        role = role,
        type = type,
        timestamp = timestamp,
        id = id,
        content = content,
        status = status,
    )

    private class FakeYaloMessageDataSource : YaloMessageDataSource {

        val sent: MutableList<SdkMessage> = mutableListOf()

        /** One token for every socket it was asked to open, in order. */
        val tokens: MutableList<String> = mutableListOf()

        var failure: Throwable? = null

        var isForgotten: Boolean = false
            private set

        /** Whether a socket is up now. */
        val hasSession: Boolean
            get() = session != null

        private var session: CompletableDeferred<Boolean>? = null

        private val incoming = MutableSharedFlow<InboundMessage>(extraBufferCapacity = 8)

        override val messages: Flow<InboundMessage> = incoming

        fun receive(message: InboundMessage) {
            incoming.tryEmit(message)
        }

        /** Ends the session that is running, the way its socket dying would. */
        fun endSession(opened: Boolean = true) {
            session?.complete(opened)
        }

        override suspend fun runSession(token: String): Boolean {
            tokens += token
            val running = CompletableDeferred<Boolean>()
            session = running
            try {
                return running.await()
            } finally {
                session = null
            }
        }

        override suspend fun send(message: SdkMessage): Result<Unit> {
            failure?.let { error -> return Result.failure(error) }
            sent.add(message)
            return Result.success(Unit)
        }

        override suspend fun close() {
            isForgotten = true
        }
    }

    private class FakeTokenRepository : TokenRepository {

        var current: String = "access"
        var failure: Throwable? = null

        override suspend fun token(): Result<String> =
            failure?.let { cause -> Result.failure(cause) } ?: Result.success(current)

        override suspend fun invalidateToken() = Unit

        override suspend fun clearSession() = Unit
    }

    private companion object {
        const val WRITTEN_AT = 1_700_000_000_000L
        const val SENT_AT = 1_700_000_005_000L
        const val ARRIVED_AT = 1_700_000_009_000L

        /** How close a length in seconds has to be once it has been through a double. */
        const val TOLERANCE = 0.0001

        const val SECOND_MILLIS = 1_000L
        const val MINUTE_MILLIS = 60_000L
        const val MAX_BACKOFF_MILLIS = 30_000L

        // 1s, 2s, 4s, 8s and 16s, after which the wait stops growing.
        const val ATTEMPTS_TO_THE_LONGEST_WAIT = 5
    }
}

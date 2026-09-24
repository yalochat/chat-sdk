// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.yalomessage

import ai.yalo.chat.sdk.data.datasources.message.InboundMessage
import ai.yalo.chat.sdk.data.datasources.message.MessageAcknowledged
import ai.yalo.chat.sdk.data.datasources.message.MessageReceived
import ai.yalo.chat.sdk.data.datasources.message.YaloMessageDataSource
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageButtonType
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageStatus
import ai.yalo.chat.sdk.domain.models.MessageType
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
import com.google.protobuf.util.Timestamps
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.IOException
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.MessageRole as WireRole
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.MessageStatus as WireStatus

@OptIn(ExperimentalCoroutinesApi::class)
class YaloMessageRepositoryRemoteTest {

    private val source = FakeYaloMessageDataSource()

    @Test
    fun sendsWhatThePersonWrote() = runTest {
        repository().send(message(content = "Hello"))

        assertEquals("Hello", sentText())
    }

    @Test
    fun sendsAMessageAsComingFromWhoeverWroteIt() = runTest {
        repository().send(message(role = MessageRole.User))

        assertEquals(WireRole.MESSAGE_ROLE_USER, source.sent.single().textMessageRequest.content.role)
    }

    @Test
    fun sendsAMessageAsComingFromTheChannelWhenThatIsWhoWroteIt() = runTest {
        repository().send(message(role = MessageRole.Agent))

        assertEquals(WireRole.MESSAGE_ROLE_AGENT, source.sent.single().textMessageRequest.content.role)
    }

    // Whatever the stored row says, a message on its way out has not arrived
    // anywhere yet.
    @Test
    fun sendsAMessageAsNotYetArrived() = runTest {
        repository().send(message(status = MessageStatus.Delivered))

        assertEquals(
            WireStatus.MESSAGE_STATUS_IN_PROGRESS,
            source.sent.single().textMessageRequest.content.status,
        )
    }

    @Test
    fun keepsTheTimeTheMessageWasWritten() = runTest {
        repository().send(message(timestamp = WRITTEN_AT))

        assertEquals(
            WRITTEN_AT,
            Timestamps.toMillis(source.sent.single().textMessageRequest.content.timestamp),
        )
    }

    @Test
    fun saysWhenTheMessageWasSentApartFromWhenItWasWritten() = runTest {
        repository().send(message(timestamp = WRITTEN_AT))

        assertEquals(SENT_AT, Timestamps.toMillis(source.sent.single().timestamp))
    }

    // An acknowledgement comes back naming the correlation id, so the row id is
    // what lets the answer find the message it belongs to.
    @Test
    fun namesTheMessageAfterTheRowItWasStoredAs() = runTest {
        repository().send(message(id = 42L))

        assertEquals("42", source.sent.single().correlationId)
    }

    @Test
    fun givesAMessageThatWasNeverStoredAnIdOfItsOwn() = runTest {
        repository().send(message(id = null))

        assertEquals("generated-id", source.sent.single().correlationId)
    }

    @Test
    fun reportsAMessageTheChannelTook() = runTest {
        val result = repository().send(message())

        assertTrue(result.isSuccess)
    }

    @Test
    fun reportsAMessageTheChannelWouldNotTake() = runTest {
        source.failure = IOException("the line is down")

        val result = repository().send(message())

        assertEquals("the line is down", result.exceptionOrNull()?.message)
    }

    @Test
    fun refusesAKindOfMessageItCannotPutOnTheWireYet() = runTest {
        val result = repository().send(message(type = MessageType.Image))

        assertTrue(result.exceptionOrNull() is UnsupportedMessageTypeException)
        assertEquals(emptyList<SdkMessage>(), source.sent)
    }

    @Test
    fun asksTheChannelToOpenTheConversation() = runTest {
        repository().requestGuidanceCard()

        assertEquals(
            SdkMessage.PayloadCase.GUIDANCE_CARD_REQUEST,
            source.sent.single().payloadCase,
        )
        assertEquals(SENT_AT, Timestamps.toMillis(source.sent.single().guidanceCardRequest.timestamp))
    }

    @Test
    fun saysWhatTheChatWasOpenedFrom() = runTest {
        repository().requestGuidanceCard(mapOf("source" to "product-page", "sku" to "123"))

        assertEquals(
            """{"source":"product-page","sku":"123"}""",
            source.sent.single().guidanceCardRequest.context,
        )
    }

    // A context the channel could not read back is worse than none, so what a
    // host puts in a value cannot break out of it.
    @Test
    fun saysAContextWithQuotesAndLineBreaksInItWithoutBreakingTheJson() = runTest {
        repository().requestGuidanceCard(
            mapOf("note" to "a \"quoted\" \\ line\r\n\tand a \u0001 of its own"),
        )

        assertEquals(
            """{"note":"a \"quoted\" \\ line\r\n\tand a \u0001 of its own"}""",
            source.sent.single().guidanceCardRequest.context,
        )
    }

    @Test
    fun leavesTheContextOutWhenTheChatWasOpenedFromNothing() = runTest {
        repository().requestGuidanceCard()

        assertFalse(source.sent.single().guidanceCardRequest.hasContext())
    }

    @Test
    fun reportsAnOpenTheChannelWouldNotTake() = runTest {
        source.failure = IOException("the line is down")

        val result = repository().requestGuidanceCard()

        assertEquals("the line is down", result.exceptionOrNull()?.message)
    }

    @Test
    fun opensTheLineToTheChannel() = runTest {
        repository(this).connect()
        runCurrent()

        assertTrue(source.isOpen)
    }

    @Test
    fun endsTheConversation() = runTest {
        val repository = repository(this)
        repository.connect()
        runCurrent()

        repository.close()
        runCurrent()

        assertFalse(source.isOpen)
    }

    @Test
    fun readsWhatTheChannelSaid() = runTest {
        val received = received(pollItem(textMessage("On its way")))

        assertEquals("On its way", received.single().content)
        assertEquals(MessageRole.Agent, received.single().role)
        assertEquals(MessageType.Text, received.single().type)
    }

    // The backend's id is what tells a repeat from a new message.
    @Test
    fun keepsTheIdTheChannelGaveTheMessage() = runTest {
        val received = received(pollItem(textMessage(), id = "wi-7"))

        assertEquals("wi-7", received.single().wiId)
    }

    @Test
    fun keepsTheTimeTheChannelRecordedTheMessage() = runTest {
        val received = received(pollItem(textMessage(), date = ARRIVED_AT))

        assertEquals(ARRIVED_AT, received.single().timestamp)
    }

    @Test
    fun timesAMessageThatArrivedWithoutADateAsNow() = runTest {
        val received = received(pollItem(textMessage(), date = null))

        assertEquals(SENT_AT, received.single().timestamp)
    }

    @Test
    fun keepsWhatWasWrittenAroundTheMessage() = runTest {
        val message = textMessage(header = "Your order", footer = "Reply to change it")

        val received = received(pollItem(message))

        assertEquals("Your order", received.single().header)
        assertEquals("Reply to change it", received.single().footer)
    }

    @Test
    fun leavesOutAHeaderAndFooterTheChannelDidNotSend() = runTest {
        val received = received(pollItem(textMessage()))

        assertEquals(null, received.single().header)
        assertEquals(null, received.single().footer)
    }

    // A picture the chat cannot draw yet still has to show up as something.
    @Test
    fun readsAKindItCannotDrawYetAsThatKind() = runTest {
        val received = received(pollItem(imageMessage()))

        assertEquals(MessageType.Image, received.single().type)
    }

    @Test
    fun readsAStatusItDoesNotKnowAsArrived() = runTest {
        val received = received(pollItem(textMessage(), status = "SOMETHING_NEWER"))

        assertEquals(MessageStatus.Delivered, received.single().status)
    }

    @Test
    fun takesTheChannelsWordForHowFarTheMessageGot() = runTest {
        val received = received(pollItem(textMessage(), status = "READ"))

        assertEquals(MessageStatus.Read, received.single().status)
    }

    @Test
    fun leavesOutWhatIsNotSomethingAnyoneSaid() = runTest {
        val status = SdkMessage.newBuilder()
            .setChatStatusRequest(ChatStatusRequest.newBuilder().setStatus("typing"))
            .build()

        assertEquals(emptyList<ChatMessage>(), received(pollItem(status)))
    }

    @Test
    fun readsTheAnswersAMessageOffers() = runTest {
        val message = textMessage(buttons = listOf(button("Yes"), button("No")))

        val received = received(pollItem(message))

        assertEquals(listOf("Yes", "No"), received.single().buttons.map { it.text })
    }

    @Test
    fun keepsWhatEachButtonIsForApartFromWhatItSays() = runTest {
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
    fun keepsWhereALinkGoes() = runTest {
        val message = textMessage(
            buttons = listOf(button("Open the store", ButtonType.BUTTON_TYPE_LINK, url = "https://yalo.com")),
        )

        val received = received(pollItem(message))

        assertEquals("https://yalo.com", received.single().buttons.single().url)
    }

    @Test
    fun leavesOutAnAddressAButtonNeverCarried() = runTest {
        val received = received(pollItem(textMessage(buttons = listOf(button("Yes")))))

        assertEquals(null, received.single().buttons.single().url)
    }

    // A button kind only a newer backend knows still has to do something, and
    // answering is the one thing every button can do.
    @Test
    fun readsAButtonKindItDoesNotKnowAsAnAnswer() = runTest {
        val newerKind = Button.newBuilder().setText("Yes").setButtonTypeValue(99).build()

        val received = received(pollItem(textMessage(buttons = listOf(newerKind))))

        assertEquals(MessageButtonType.Reply, received.single().buttons.single().type)
    }

    @Test
    fun readsTheAnswersOfferedWithAMessageItCannotDrawYet() = runTest {
        val received = received(pollItem(imageMessage(buttons = listOf(button("Yes")))))

        assertEquals(listOf("Yes"), received.single().buttons.map { it.text })
    }

    @Test
    fun offersNothingForAMessageWithNoButtons() = runTest {
        val received = received(pollItem(textMessage()))

        assertEquals(emptyList<String>(), received.single().buttons.map { it.text })
    }

    @Test
    fun leavesOutAnAcknowledgement() = runTest {
        val received = received(MessageAcknowledged(SdkMessageAck.getDefaultInstance()))

        assertEquals(emptyList<ChatMessage>(), received)
    }

    private fun sentText(): String = source.sent.single().textMessageRequest.content.text

    /** What the repository makes of [inbound], once the channel has sent it. */
    private fun TestScope.received(vararg inbound: InboundMessage): List<ChatMessage> {
        val received = mutableListOf<ChatMessage>()
        val collector = launch {
            repository(this@received).messages().collect { message -> received.add(message) }
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

    private fun imageMessage(buttons: List<Button> = emptyList()): SdkMessage = SdkMessage.newBuilder()
        .setImageMessageRequest(
            ImageMessageRequest.newBuilder()
                .setContent(ImageMessage.newBuilder().setMediaUrl("https://yalo.com/shirt.png"))
                .addAllButtons(buttons),
        )
        .build()

    private fun TestScope.repository(): YaloMessageRepositoryRemote = repository(this)

    private fun repository(scope: CoroutineScope): YaloMessageRepositoryRemote =
        YaloMessageRepositoryRemote(
            source = source,
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
        var isOpen: Boolean = false
            private set
        var failure: Throwable? = null

        private val incoming = MutableSharedFlow<InboundMessage>(extraBufferCapacity = 8)

        override val messages: Flow<InboundMessage> = incoming

        fun receive(message: InboundMessage) {
            incoming.tryEmit(message)
        }

        override suspend fun connect() {
            isOpen = true
        }

        override suspend fun send(message: SdkMessage): Result<Unit> {
            failure?.let { error -> return Result.failure(error) }
            sent.add(message)
            return Result.success(Unit)
        }

        override suspend fun pause() = Unit

        override suspend fun resume() = Unit

        override suspend fun close() {
            isOpen = false
        }
    }

    private companion object {
        const val WRITTEN_AT = 1_700_000_000_000L
        const val SENT_AT = 1_700_000_005_000L
        const val ARRIVED_AT = 1_700_000_009_000L
    }
}

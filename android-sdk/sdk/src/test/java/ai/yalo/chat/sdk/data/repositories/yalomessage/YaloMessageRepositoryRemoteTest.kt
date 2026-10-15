// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.yalomessage

import ai.yalo.chat.sdk.data.datasources.message.InboundMessage
import ai.yalo.chat.sdk.data.datasources.message.MessageAcknowledged
import ai.yalo.chat.sdk.data.datasources.message.MessageReceived
import ai.yalo.chat.sdk.data.datasources.message.YaloMessageDataSource
import ai.yalo.chat.sdk.data.datasources.message.timestampOf
import ai.yalo.chat.sdk.data.datasources.message.toEpochMillis
import ai.yalo.chat.sdk.data.repositories.token.FakeTokenRepository
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.CommandRequest
import ai.yalo.chat.sdk.domain.models.FeedbackRating
import ai.yalo.chat.sdk.domain.models.ImageAttachment
import ai.yalo.chat.sdk.domain.models.MessageButtonType
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageStatus
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.domain.models.VoiceNote
import ai.yalo.chat.sdk.internal.proto.v2.Button
import ai.yalo.chat.sdk.internal.proto.v2.ButtonType
import ai.yalo.chat.sdk.internal.proto.v2.ChatStatusRequest
import ai.yalo.chat.sdk.internal.proto.v2.CustomCommandRequest
import ai.yalo.chat.sdk.internal.proto.v2.GetCartRequest
import ai.yalo.chat.sdk.internal.proto.v2.ImageMessage
import ai.yalo.chat.sdk.internal.proto.v2.ImageMessageRequest
import ai.yalo.chat.sdk.internal.proto.v2.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.ResponseStatus
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageAck
import ai.yalo.chat.sdk.internal.proto.v2.TextMessage
import ai.yalo.chat.sdk.internal.proto.v2.TextMessageRequest
import ai.yalo.chat.sdk.internal.proto.v2.UpdateCartProductRequest
import ai.yalo.chat.sdk.internal.proto.v2.VoiceMessage
import ai.yalo.chat.sdk.internal.proto.v2.VideoMessageRequest
import ai.yalo.chat.sdk.internal.proto.v2.VoiceNoteMessageRequest
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
import ai.yalo.chat.sdk.internal.proto.v2.FeedbackRating as WireRating
import ai.yalo.chat.sdk.internal.proto.v2.MessageRole as WireRole
import ai.yalo.chat.sdk.internal.proto.v2.MessageStatus as WireStatus

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

        assertEquals(WireRole.MESSAGE_ROLE_USER, source.sent.single().text_message_request!!.content!!.role)
    }

    @Test
    fun sendsAMessageAsComingFromTheChannelWhenThatIsWhoWroteIt() = runTest(scheduler) {
        connected().send(message(role = MessageRole.Agent))

        assertEquals(WireRole.MESSAGE_ROLE_AGENT, source.sent.single().text_message_request!!.content!!.role)
    }

    // Whatever the stored row says, a message on its way out has not arrived
    // anywhere yet.
    @Test
    fun sendsAMessageAsNotYetArrived() = runTest(scheduler) {
        connected().send(message(status = MessageStatus.Delivered))

        assertEquals(
            WireStatus.MESSAGE_STATUS_IN_PROGRESS,
            source.sent.single().text_message_request!!.content!!.status,
        )
    }

    @Test
    fun keepsTheTimeTheMessageWasWritten() = runTest(scheduler) {
        connected().send(message(timestamp = WRITTEN_AT))

        assertEquals(
            WRITTEN_AT,
            source.sent.single().text_message_request!!.content!!.timestamp?.toEpochMillis(),
        )
    }

    @Test
    fun saysWhenTheMessageWasSentApartFromWhenItWasWritten() = runTest(scheduler) {
        connected().send(message(timestamp = WRITTEN_AT))

        assertEquals(SENT_AT, source.sent.single().timestamp?.toEpochMillis())
    }

    // An acknowledgement comes back naming the correlation id, so the row id is
    // what lets the answer find the message it belongs to.
    @Test
    fun namesTheMessageAfterTheRowItWasStoredAs() = runTest(scheduler) {
        connected().send(message(id = 42L))

        assertEquals("42", source.sent.single().correlation_id)
    }

    @Test
    fun givesAMessageThatWasNeverStoredAnIdOfItsOwn() = runTest(scheduler) {
        connected().send(message(id = null))

        assertEquals("generated-id", source.sent.single().correlation_id)
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
        val result = connected().send(message(type = MessageType.Video))

        assertTrue(result.exceptionOrNull() is UnsupportedMessageTypeException)
        assertEquals(emptyList<SdkMessage>(), source.sent)
    }

    @Test
    fun sendsAVoiceNoteUnderTheNameTheUploadGaveIt() = runTest(scheduler) {
        connected().send(voiceMessage(note = recorded(mediaUrl = "media-42")))

        val sent = source.sent.single().voice_note_message_request!!.content!!
        assertEquals("media-42", sent.media_url)
        assertEquals("audio/mp4", sent.media_type)
        assertEquals("voice-1.m4a", sent.file_name)
        assertEquals(2_048L, sent.byte_count)
    }

    @Test
    fun sendsAVoiceNoteLengthInSeconds() = runTest(scheduler) {
        connected().send(voiceMessage(note = recorded(durationMillis = 4_500)))

        assertEquals(4.5, source.sent.single().voice_note_message_request!!.content!!.duration, TOLERANCE)
    }

    @Test
    fun sendsTheWaveformAVoiceNoteIsDrawnFrom() = runTest(scheduler) {
        connected().send(voiceMessage(note = recorded(amplitudes = listOf(0.25f, 1f))))

        assertEquals(
            listOf(0.25f, 1f),
            source.sent.single().voice_note_message_request!!.content!!.amplitudes_preview,
        )
    }

    @Test
    fun sendsAVoiceNoteAsNotHavingArrivedAnywhereYet() = runTest(scheduler) {
        connected().send(voiceMessage(note = recorded()))

        val sent = source.sent.single().voice_note_message_request!!.content!!
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
    fun sendsAPictureUnderTheNameTheUploadGaveIt() = runTest(scheduler) {
        connected().send(pictureMessage(picture = picked(mediaUrl = "media-42")))

        val sent = source.sent.single().image_message_request!!.content!!
        assertEquals("media-42", sent.media_url)
        assertEquals("image/jpeg", sent.media_type)
        assertEquals("holiday.jpg", sent.file_name)
        assertEquals(4_096L, sent.byte_count)
    }

    @Test
    fun sendsTheCaptionWrittenWithAPicture() = runTest(scheduler) {
        connected().send(pictureMessage(picture = picked(), caption = "Look at this"))

        assertEquals("Look at this", source.sent.single().image_message_request!!.content!!.text)
    }

    @Test
    fun sendsAPictureAsNotHavingArrivedAnywhereYet() = runTest(scheduler) {
        connected().send(pictureMessage(picture = picked()))

        val sent = source.sent.single().image_message_request!!.content!!
        assertEquals(WireStatus.MESSAGE_STATUS_IN_PROGRESS, sent.status)
        assertEquals(WireRole.MESSAGE_ROLE_USER, sent.role)
    }

    @Test
    fun refusesAnImageMessageWithNothingToShow() = runTest(scheduler) {
        val result = connected().send(pictureMessage(picture = null))

        assertTrue(result.exceptionOrNull() is UnsupportedMessageTypeException)
        assertEquals(emptyList<SdkMessage>(), source.sent)
    }

    @Test
    fun readsAPictureTheChannelSent() = runTest(scheduler) {
        val received = received(pollItem(imageMessage()))

        val picture = received.single().image
        assertEquals(MessageType.Image, received.single().type)
        assertEquals("https://yalo.com/shirt.png", picture?.mediaUrl)
        assertEquals("image/png", picture?.mediaType)
        assertEquals("shirt.png", picture?.fileName)
        assertEquals(4_096L, picture?.byteCount)
    }

    @Test
    fun readsTheCaptionTheChannelSentWithAPicture() = runTest(scheduler) {
        val received = received(pollItem(imageMessage(caption = "Our best seller")))

        assertEquals("Our best seller", received.single().content)
    }

    @Test
    fun readsAPictureTheChannelSentAsHavingNoFileHere() = runTest(scheduler) {
        val received = received(pollItem(imageMessage()))

        assertNull(received.single().image?.localPath)
    }

    @Test
    fun leavesThePictureOffAMessageThatIsNotAnImage() = runTest(scheduler) {
        val received = received(pollItem(textMessage()))

        assertNull(received.single().image)
    }

    @Test
    fun readsTheLinesAroundAPictureTheChannelSent() = runTest(scheduler) {
        val received = received(
            pollItem(imageMessage(header = "Support", footer = "Powered by Yalo")),
        )

        assertEquals("Support", received.single().header)
        assertEquals("Powered by Yalo", received.single().footer)
    }

    @Test
    fun asksTheChannelToOpenTheConversation() = runTest(scheduler) {
        connected().requestGuidanceCard()

        assertEquals(SENT_AT, source.sent.single().guidance_card_request?.timestamp?.toEpochMillis())
    }

    @Test
    fun saysWhatTheChatWasOpenedFrom() = runTest(scheduler) {
        connected().requestGuidanceCard(mapOf("source" to "product-page", "sku" to "123"))

        assertEquals(
            """{"source":"product-page","sku":"123"}""",
            source.sent.single().guidance_card_request!!.context,
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
            source.sent.single().guidance_card_request!!.context,
        )
    }

    @Test
    fun leavesTheContextOutWhenTheChatWasOpenedFromNothing() = runTest(scheduler) {
        connected().requestGuidanceCard()

        assertNull(source.sent.single().guidance_card_request!!.context)
    }

    @Test
    fun reportsAnOpenTheChannelWouldNotTake() = runTest(scheduler) {
        source.failure = IOException("the line is down")

        val result = connected().requestGuidanceCard()

        assertEquals("the line is down", result.exceptionOrNull()?.message)
    }

    @Test
    fun tellsTheChannelWhatTheMessageWasRated() = runTest(scheduler) {
        connected().sendFeedback("wi-1", FeedbackRating.ThumbsUp)

        val request = source.sent.single().message_feedback_request!!
        assertEquals(
            listOf("wi-1", WireRating.FEEDBACK_RATING_THUMBS_UP, SENT_AT),
            listOf(request.message_id, request.rating, request.timestamp?.toEpochMillis()),
        )
    }

    @Test
    fun tellsTheChannelAboutAThumbsDown() = runTest(scheduler) {
        connected().sendFeedback("wi-1", FeedbackRating.ThumbsDown)

        assertEquals(WireRating.FEEDBACK_RATING_THUMBS_DOWN, source.sent.single().message_feedback_request!!.rating)
    }

    @Test
    fun takesARatingBackByLeavingItUnspecified() = runTest(scheduler) {
        connected().sendFeedback("wi-1", null)

        assertEquals(WireRating.FEEDBACK_RATING_UNSPECIFIED, source.sent.single().message_feedback_request!!.rating)
    }

    @Test
    fun reportsARatingTheChannelWouldNotTake() = runTest(scheduler) {
        source.failure = IOException("the line is down")

        assertTrue(connected().sendFeedback("wi-1", FeedbackRating.ThumbsUp).isFailure)
    }

    @Test
    fun readsACommandTheChannelAsksFor() = runTest(scheduler) {
        val requests = commandRequests(pollItem(commandRequest("getStore", """{"id":1}""", correlationId = "c-1")))

        assertEquals(listOf(CommandRequest("c-1", "getStore", """{"id":1}""")), requests)
    }

    @Test
    fun keepsCommandsOutOfTheConversation() = runTest(scheduler) {
        assertEquals(emptyList<ChatMessage>(), received(pollItem(commandRequest("getStore"))))
    }

    @Test
    fun keepsMessagesOutOfTheCommands() = runTest(scheduler) {
        assertEquals(emptyList<CommandRequest>(), commandRequests(pollItem(textMessage())))
    }

    @Test
    fun answersACommandThatRan() = runTest(scheduler) {
        connected().answerCommand(CommandRequest("c-1", "getStore", ""), Result.success("""{"ok":true}"""))

        val answer = source.sent.single()
        assertEquals("c-1", answer.correlation_id)
        assertEquals(ResponseStatus.RESPONSE_STATUS_SUCCESS, answer.custom_command_response!!.status)
        assertEquals("""{"ok":true}""", answer.custom_command_response!!.payload)
    }

    @Test
    fun answersACommandThatFailed() = runTest(scheduler) {
        connected().answerCommand(CommandRequest("c-1", "getStore", ""), Result.failure(IllegalStateException("no store")))

        val answer = source.sent.single().custom_command_response!!
        assertEquals(ResponseStatus.RESPONSE_STATUS_ERROR, answer.status)
        assertEquals("", answer.payload)
    }

    @Test
    fun handsACartRequestToTheGetCartCommandAsJson() = runTest(scheduler) {
        val cart = SdkMessage(
            correlation_id = "c-1",
            get_cart_request = GetCartRequest(
                cursor = "page-2",
                page_size = 20,
                timestamp = timestampOf(SENT_AT),
            ),
        )

        val request = commandRequests(pollItem(cart)).single()

        assertEquals(listOf("c-1", "getCart"), listOf(request.correlationId, request.commandId))
        assertEquals("""{"cursor":"page-2","pageSize":20}""", request.payload)
    }

    @Test
    fun handsTheFirstCartPageRequestAsAnEmptyObject() = runTest(scheduler) {
        val cart = SdkMessage(get_cart_request = GetCartRequest())

        assertEquals("{}", commandRequests(pollItem(cart)).single().payload)
    }

    @Test
    fun handsACartChangeToTheUpdateCartProductCommandAsJson() = runTest(scheduler) {
        val change = SdkMessage(update_cart_product_request = UpdateCartProductRequest(sku = "WATER-1L", units = 0.0))

        val request = commandRequests(pollItem(change)).single()

        assertEquals("updateCartProduct", request.commandId)
        assertEquals("""{"sku":"WATER-1L","units":0.0}""", request.payload)
    }

    @Test
    fun answersTheCartWithTheProductsTheHostReturned() = runTest(scheduler) {
        val page = """
            {"products":[{"sku":"WATER-1L","name":"Water","price":12.5,"imagesUrl":["https://cdn/w.png"],
            "salePrice":10,"unitsAdded":2}],"pageInfo":{"pageSize":20,"nextCursor":"page-2"},"extra":true}
        """.trimIndent()

        connected().answerCommand(cartRequest(), Result.success(page))

        val answer = source.sent.single()
        assertEquals("c-1", answer.correlation_id)
        val cart = answer.get_cart_response!!
        assertEquals(ResponseStatus.RESPONSE_STATUS_SUCCESS, cart.status)
        val product = cart.products.single()
        assertEquals(listOf("WATER-1L", "Water", 12.5, 10.0, 2.0), listOf(product.sku, product.name, product.price, product.sale_price, product.units_added))
        assertEquals(listOf("https://cdn/w.png"), product.images_url)
        assertEquals(listOf(20, "page-2"), listOf(cart.page_info?.page_size, cart.page_info?.next_cursor))
    }

    @Test
    fun answersTheCartAsFailedWhenTheHostReturnedSomethingThatIsNotJson() = runTest(scheduler) {
        connected().answerCommand(cartRequest(), Result.success("not json"))

        val cart = source.sent.single().get_cart_response!!
        assertEquals(ResponseStatus.RESPONSE_STATUS_ERROR, cart.status)
        assertEquals(0, cart.products.size)
    }

    @Test
    fun answersTheCartAsFailedWhenTheHandlerFailed() = runTest(scheduler) {
        connected().answerCommand(cartRequest(), Result.failure(IllegalStateException("closed")))

        assertEquals(ResponseStatus.RESPONSE_STATUS_ERROR, source.sent.single().get_cart_response!!.status)
    }

    @Test
    fun answersACartChangeWithWhetherItWasApplied() = runTest(scheduler) {
        val change = CommandRequest("c-1", "updateCartProduct", "", CommandRequest.Kind.UpdateCartProduct)
        val repository = connected()

        repository.answerCommand(change, Result.success(""))
        repository.answerCommand(change, Result.failure(IllegalStateException("out of stock")))

        assertEquals(
            listOf(ResponseStatus.RESPONSE_STATUS_SUCCESS, ResponseStatus.RESPONSE_STATUS_ERROR),
            source.sent.map { it.update_cart_product_response?.status },
        )
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

    // A kind the chat cannot draw yet still has to show up as something.
    @Test
    fun readsAKindItCannotDrawYetAsThatKind() = runTest(scheduler) {
        val received = received(pollItem(videoMessage()))

        assertEquals(MessageType.Video, received.single().type)
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
        val status = SdkMessage(chat_status_request = ChatStatusRequest(status = "typing"))

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
    fun leavesOutAnItemThatCarriesNoMessage() = runTest(scheduler) {
        assertEquals(emptyList<ChatMessage>(), received(PollMessageItem(id = "wi-1")))
    }

    @Test
    fun readsAVoiceNoteThatArrivedWithoutItsRecordingAsAnEmptyOne() = runTest(scheduler) {
        val message = SdkMessage(voice_note_message_request = VoiceNoteMessageRequest())

        val received = received(pollItem(message))

        assertEquals("", received.single().voice?.mediaUrl)
    }

    @Test
    fun readsAPictureThatArrivedWithoutItsFileAsAnEmptyOne() = runTest(scheduler) {
        val message = SdkMessage(image_message_request = ImageMessageRequest())

        val received = received(pollItem(message))

        assertEquals("", received.single().image?.mediaUrl)
    }

    @Test
    fun readsTheAnswersOfferedWithAVideo() = runTest(scheduler) {
        val message = SdkMessage(video_message_request = VideoMessageRequest(buttons = listOf(button("Yes"))))

        val received = received(pollItem(message))

        assertEquals(listOf("Yes"), received.single().buttons.map { it.text })
    }

    @Test
    fun leavesOutAnAcknowledgement() = runTest(scheduler) {
        val received = received(MessageAcknowledged(SdkMessageAck()))

        assertEquals(emptyList<ChatMessage>(), received)
    }

    private fun TestScope.commandRequests(vararg items: PollMessageItem): List<CommandRequest> {
        val requests = mutableListOf<CommandRequest>()
        val collector = launch {
            repository().commandRequests().collect { request -> requests.add(request) }
        }
        runCurrent()
        items.forEach { item -> source.receive(MessageReceived(item)) }
        runCurrent()
        collector.cancel()
        return requests
    }

    private fun cartRequest(): CommandRequest =
        CommandRequest("c-1", "getCart", "{}", CommandRequest.Kind.GetCart)

    private fun commandRequest(
        commandId: String,
        payload: String = "",
        correlationId: String = "c-1",
    ): SdkMessage = SdkMessage(
        correlation_id = correlationId,
        custom_command_request = CustomCommandRequest(command_id = commandId, payload = payload),
    )

    private fun sentText(): String = source.sent.single().text_message_request!!.content!!.text

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
    ): PollMessageItem = PollMessageItem(
        id = id,
        message = message,
        status = status,
        date = date?.let(::timestampOf),
    )

    private fun button(
        text: String,
        type: ButtonType = ButtonType.BUTTON_TYPE_REPLY,
        url: String? = null,
    ): Button = Button(text = text, button_type = type, url = url)

    private fun textMessage(
        text: String = "On its way",
        header: String? = null,
        footer: String? = null,
        buttons: List<Button> = emptyList(),
    ): SdkMessage = SdkMessage(
        text_message_request = TextMessageRequest(
            content = TextMessage(text = text, role = WireRole.MESSAGE_ROLE_AGENT),
            header_ = header,
            footer = footer,
            buttons = buttons,
        ),
    )

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

    private fun wireVoiceMessage(): SdkMessage = SdkMessage(
        voice_note_message_request = VoiceNoteMessageRequest(
            content = VoiceMessage(
                media_url = "https://media.example.com/note.m4a",
                media_type = "audio/mp4",
                file_name = "note.m4a",
                byte_count = 4_096,
                duration = 4.5,
                amplitudes_preview = listOf(0.25f, 1f),
                role = WireRole.MESSAGE_ROLE_AGENT,
            ),
        ),
    )

    private fun videoMessage(): SdkMessage = SdkMessage(video_message_request = VideoMessageRequest())

    private fun picked(mediaUrl: String = "media-1"): ImageAttachment = ImageAttachment(
        mediaUrl = mediaUrl,
        mediaType = "image/jpeg",
        fileName = "holiday.jpg",
        byteCount = 4_096,
        localPath = "/files/image-1.jpg",
    )

    private fun pictureMessage(
        picture: ImageAttachment?,
        caption: String = "",
    ): ChatMessage = ChatMessage(
        role = MessageRole.User,
        type = MessageType.Image,
        timestamp = WRITTEN_AT,
        id = 1L,
        content = caption,
        image = picture,
    )

    private fun imageMessage(
        caption: String? = null,
        header: String? = null,
        footer: String? = null,
        buttons: List<Button> = emptyList(),
    ): SdkMessage = SdkMessage(
        image_message_request = ImageMessageRequest(
            content = ImageMessage(
                text = caption,
                media_url = "https://yalo.com/shirt.png",
                media_type = "image/png",
                file_name = "shirt.png",
                byte_count = 4_096,
                role = WireRole.MESSAGE_ROLE_AGENT,
            ),
            header_ = header,
            footer = footer,
            buttons = buttons,
        ),
    )

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

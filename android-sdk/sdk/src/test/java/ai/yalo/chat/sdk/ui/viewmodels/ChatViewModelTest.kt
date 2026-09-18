// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.viewmodels

import ai.yalo.chat.sdk.data.repositories.chatmessage.FakeChatMessageRepository
import ai.yalo.chat.sdk.data.repositories.yalomessage.YaloMessageRepository
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.domain.models.MessageButtonType
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModelStore
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import kotlin.time.Duration.Companion.seconds

@RunWith(RobolectricTestRunner::class)
class ChatViewModelTest {

    private val chatMessageRepository = FakeChatMessageRepository()
    private val yaloMessageRepository = FakeYaloMessageRepository()
    private val scheduler = TestCoroutineScheduler()
    private val hostMessages = MutableSharedFlow<String>(extraBufferCapacity = 8)

    @Before
    fun useATestDispatcher() {
        Dispatchers.setMain(UnconfinedTestDispatcher(scheduler))
    }

    @After
    fun releaseTheTestDispatcher() {
        Dispatchers.resetMain()
    }

    @Test
    fun showsTheChannelNameItWasBuiltWith() {
        val viewModel = chatViewModel(title = "Support")

        assertEquals("Support", viewModel.uiState.title)
    }

    @Test
    fun reportsWhatTheUserIsTyping() {
        val viewModel = chatViewModel()

        viewModel.onDraftChange("Hel")
        viewModel.onDraftChange("Hello")

        assertEquals("Hello", viewModel.uiState.draft)
    }

    @Test
    fun emptiesTheInputOnceTheDraftIsSent() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")

        viewModel.onSend()

        assertEquals("", viewModel.uiState.draft)
    }

    @Test
    fun leavesADraftOfOnlySpaceAlone() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("   ")

        viewModel.onSend()

        assertEquals("   ", viewModel.uiState.draft)
        assertEquals(emptyList<String>(), viewModel.uiState.messages.map { it.content })
    }

    @Test
    fun readsBackAHalfTypedMessageAfterBeingRecreated() {
        val savedState = SavedStateHandle()
        chatViewModel(savedState = savedState).onDraftChange("Half typed")

        val recreated = chatViewModel(savedState = savedState)

        assertEquals("Half typed", recreated.uiState.draft)
    }

    @Test
    fun keepsWhatTheUserSent() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")

        viewModel.onSend()

        val sent = viewModel.uiState.messages.single()
        assertEquals(listOf("Hello", MessageRole.User, MessageType.Text, SENT_AT), listOf(sent.content, sent.role, sent.type, sent.timestamp))
    }

    @Test
    fun sendsWithoutTheSpaceAroundWhatWasTyped() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("  Hello  ")

        viewModel.onSend()

        assertEquals("Hello", viewModel.uiState.messages.single().content)
    }

    @Test
    fun showsTheNewestMessageFirst() {
        val viewModel = chatViewModel()

        viewModel.onDraftChange("First")
        viewModel.onSend()
        viewModel.onDraftChange("Second")
        viewModel.onSend()

        assertEquals(listOf("Second", "First"), viewModel.uiState.messages.map { it.content })
    }

    @Test
    fun startsWithWhatWasAlreadyStored() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")
        viewModel.onSend()

        val reopened = chatViewModel()

        assertEquals(listOf("Hello"), reopened.uiState.messages.map { it.content })
    }

    @Test
    fun showsNoMessagesWhenStorageIsBroken() {
        chatMessageRepository.failure = IllegalStateException("storage is gone")
        val viewModel = chatViewModel()

        viewModel.onDraftChange("Hello")
        viewModel.onSend()

        assertEquals(emptyList<String>(), viewModel.uiState.messages.map { it.content })
        assertEquals("", viewModel.uiState.draft)
    }

    @Test
    fun waitsForAReplyOnceAMessageIsSent() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")

        viewModel.onSend()

        assertTrue(viewModel.uiState.isWaitingForReply)
    }

    @Test
    fun waitsForNoReplyBeforeAnythingIsSent() {
        assertFalse(chatViewModel().uiState.isWaitingForReply)
    }

    @Test
    fun givesUpWaitingWhenNoReplyArrivesInTime() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")
        viewModel.onSend()

        scheduler.advanceTimeBy(45.seconds)
        scheduler.runCurrent()

        assertFalse(viewModel.uiState.isWaitingForReply)
    }

    @Test
    fun keepsWaitingUntilTheTimeIsUp() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")
        viewModel.onSend()

        scheduler.advanceTimeBy(44.seconds)
        scheduler.runCurrent()

        assertTrue(viewModel.uiState.isWaitingForReply)
    }

    @Test
    fun startsTheWaitOverWhenAnotherMessageIsSent() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")
        viewModel.onSend()

        scheduler.advanceTimeBy(40.seconds)
        scheduler.runCurrent()
        viewModel.onDraftChange("Still there?")
        viewModel.onSend()
        scheduler.advanceTimeBy(10.seconds)
        scheduler.runCurrent()

        assertTrue(viewModel.uiState.isWaitingForReply)
    }

    @Test
    fun waitsForNothingWhenTheMessageWasNeverStored() {
        chatMessageRepository.failure = IllegalStateException("storage is gone")
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")

        viewModel.onSend()

        assertFalse(viewModel.uiState.isWaitingForReply)
    }

    @Test
    fun keepsWhatTheHostAskedToSend() {
        val viewModel = chatViewModel()

        hostMessages.tryEmit("Sent by the app")

        val sent = viewModel.uiState.messages.single()
        assertEquals(
            listOf("Sent by the app", MessageRole.User, MessageType.Text),
            listOf(sent.content, sent.role, sent.type),
        )
    }

    @Test
    fun waitsForAReplyToWhatTheHostSent() {
        val viewModel = chatViewModel()

        hostMessages.tryEmit("Sent by the app")

        assertTrue(viewModel.uiState.isWaitingForReply)
    }

    @Test
    fun sendsNothingWhenTheHostAsksForOnlySpace() {
        val viewModel = chatViewModel()

        hostMessages.tryEmit("   ")

        assertEquals(emptyList<String>(), viewModel.uiState.messages.map { it.content })
        assertFalse(viewModel.uiState.isWaitingForReply)
    }

    @Test
    fun leavesAHalfTypedDraftAloneWhenTheHostSends() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Typing this")

        hostMessages.tryEmit("Sent by the app")

        assertEquals("Typing this", viewModel.uiState.draft)
        assertEquals(listOf("Sent by the app"), viewModel.uiState.messages.map { it.content })
    }

    @Test
    fun opensTheLineToTheChannelAsSoonAsTheChatIsShown() {
        chatViewModel()

        assertTrue(yaloMessageRepository.isOpen)
    }

    @Test
    fun endsTheConversationOnceTheChatIsGone() {
        val store = ViewModelStore()
        store.put("chat", chatViewModel())

        store.clear()

        assertFalse(yaloMessageRepository.isOpen)
    }

    @Test
    fun sendsWhatTheUserWroteToTheChannel() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")

        viewModel.onSend()

        assertEquals(listOf("Hello"), yaloMessageRepository.sent.map { it.content })
    }

    @Test
    fun sendsTheStoredMessageSoTheChannelCanBeAnsweredAboutIt() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")

        viewModel.onSend()

        assertEquals(viewModel.uiState.messages.single().id, yaloMessageRepository.sent.single().id)
    }

    @Test
    fun sendsWhatTheHostAskedForToTheChannel() {
        chatViewModel()

        hostMessages.tryEmit("Sent by the app")

        assertEquals(listOf("Sent by the app"), yaloMessageRepository.sent.map { it.content })
    }

    @Test
    fun sendsNothingToTheChannelWhenTheMessageWasNeverStored() {
        chatMessageRepository.failure = IllegalStateException("storage is gone")
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")

        viewModel.onSend()

        assertEquals(emptyList<String>(), yaloMessageRepository.sent.map { it.content })
    }

    // A message that never left the device is not one anybody is about to
    // answer, so the loader has nothing to wait for.
    @Test
    fun waitsForNothingWhenTheChannelWouldNotTakeTheMessage() {
        yaloMessageRepository.failure = IllegalStateException("the line is down")
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")

        viewModel.onSend()

        assertFalse(viewModel.uiState.isWaitingForReply)
    }

    @Test
    fun stillShowsAMessageTheChannelWouldNotTake() {
        yaloMessageRepository.failure = IllegalStateException("the line is down")
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")

        viewModel.onSend()

        assertEquals(listOf("Hello"), viewModel.uiState.messages.map { it.content })
    }

    @Test
    fun showsWhatTheChannelAnswered() {
        val viewModel = chatViewModel()

        yaloMessageRepository.answer(answer("On its way"))

        assertEquals(listOf("On its way"), viewModel.uiState.messages.map { it.content })
        assertEquals(MessageRole.Agent, viewModel.uiState.messages.single().role)
    }

    @Test
    fun keepsWhatTheChannelAnsweredForTheNextTimeTheChatIsOpened() {
        chatViewModel()
        yaloMessageRepository.answer(answer("On its way"))

        val reopened = chatViewModel()

        assertEquals(listOf("On its way"), reopened.uiState.messages.map { it.content })
    }

    @Test
    fun stopsWaitingOnceTheChannelAnswers() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")
        viewModel.onSend()

        yaloMessageRepository.answer(answer("On its way"))

        assertFalse(viewModel.uiState.isWaitingForReply)
    }

    @Test
    fun keepsTheLoaderAwayOnceAnAnswerEndedTheWait() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Hello")
        viewModel.onSend()
        yaloMessageRepository.answer(answer("On its way"))

        scheduler.advanceTimeBy(45.seconds)
        scheduler.runCurrent()

        assertFalse(viewModel.uiState.isWaitingForReply)
    }

    // The channel repeats a message when the line comes back, naming the same id.
    @Test
    fun showsAnAnswerTheChannelRepeatedOnlyOnce() {
        val viewModel = chatViewModel()

        yaloMessageRepository.answer(answer("On its way"))
        yaloMessageRepository.answer(answer("On its way"))

        assertEquals(listOf("On its way"), viewModel.uiState.messages.map { it.content })
    }

    @Test
    fun showsNoAnswerThatStorageWouldNotTake() {
        chatMessageRepository.failure = IllegalStateException("storage is gone")
        val viewModel = chatViewModel()

        yaloMessageRepository.answer(answer("On its way"))

        assertEquals(emptyList<String>(), viewModel.uiState.messages.map { it.content })
    }

    @Test
    fun offersTheAnswersTheChannelSuggested() {
        val viewModel = chatViewModel()

        yaloMessageRepository.answer(answer("Anything else?", buttons = listOf(reply("Yes"), reply("No"))))

        assertEquals(listOf("Yes", "No"), viewModel.uiState.quickReplies.map { it.text })
    }

    @Test
    fun namesTheMessageOfferingTheAnswers() {
        val viewModel = chatViewModel()

        yaloMessageRepository.answer(answer("Anything else?", buttons = listOf(reply("Yes"))))

        assertEquals(
            viewModel.uiState.messages.single().id,
            viewModel.uiState.quickRepliesMessageId,
        )
    }

    @Test
    fun offersNothingBeforeTheChannelSuggestsAnything() {
        val viewModel = chatViewModel()

        yaloMessageRepository.answer(answer("On its way"))

        assertEquals(emptyList<MessageButton>(), viewModel.uiState.quickReplies)
        assertEquals(null, viewModel.uiState.quickRepliesMessageId)
    }

    // Only the answers themselves are worth offering. A link goes somewhere
    // else, which is not the same as answering the question.
    @Test
    fun offersOnlyTheButtonsThatAnswerTheMessage() {
        val viewModel = chatViewModel()

        yaloMessageRepository.answer(
            answer(
                "Anything else?",
                buttons = listOf(
                    reply("Yes"),
                    MessageButton(text = "Open the store", type = MessageButtonType.Link),
                ),
            ),
        )

        assertEquals(listOf("Yes"), viewModel.uiState.quickReplies.map { it.text })
    }

    @Test
    fun offersTheAnswersOfTheLatestSuggestionOnly() {
        val viewModel = chatViewModel()

        yaloMessageRepository.answer(answer("Anything else?", wiId = "wi-1", buttons = listOf(reply("Yes"))))
        yaloMessageRepository.answer(answer("Still there?", wiId = "wi-2", buttons = listOf(reply("Here"))))

        assertEquals(listOf("Here"), viewModel.uiState.quickReplies.map { it.text })
    }

    @Test
    fun keepsOfferingTheAnswersWhenTheChannelSaysSomethingElseAfterThem() {
        val viewModel = chatViewModel()

        yaloMessageRepository.answer(answer("Anything else?", wiId = "wi-1", buttons = listOf(reply("Yes"))))
        yaloMessageRepository.answer(answer("Take your time", wiId = "wi-2"))

        assertEquals(listOf("Yes"), viewModel.uiState.quickReplies.map { it.text })
    }

    @Test
    fun stopsOfferingTheAnswersOnceThePersonAnswers() {
        val viewModel = chatViewModel()
        yaloMessageRepository.answer(answer("Anything else?", buttons = listOf(reply("Yes"))))

        viewModel.onDraftChange("No thanks")
        viewModel.onSend()

        assertEquals(emptyList<MessageButton>(), viewModel.uiState.quickReplies)
        assertEquals(null, viewModel.uiState.quickRepliesMessageId)
    }

    @Test
    fun saysAChosenAnswerBackToTheChannel() {
        val viewModel = chatViewModel()
        yaloMessageRepository.answer(answer("Anything else?", buttons = listOf(reply("Yes"))))

        viewModel.onQuickReply("Yes")

        assertEquals(listOf("Yes"), yaloMessageRepository.sent.map { it.content })
        assertEquals(MessageRole.User, viewModel.uiState.messages.first().role)
    }

    @Test
    fun waitsForAReplyToAChosenAnswer() {
        val viewModel = chatViewModel()

        viewModel.onQuickReply("Yes")

        assertTrue(viewModel.uiState.isWaitingForReply)
    }

    @Test
    fun leavesAHalfTypedDraftAloneWhenAnAnswerIsChosen() {
        val viewModel = chatViewModel()
        viewModel.onDraftChange("Typing this")

        viewModel.onQuickReply("Yes")

        assertEquals("Typing this", viewModel.uiState.draft)
    }

    private fun reply(text: String): MessageButton = MessageButton(text = text)

    private fun answer(
        content: String,
        wiId: String = "wi-1",
        buttons: List<MessageButton> = emptyList(),
    ): ChatMessage = ChatMessage(
        role = MessageRole.Agent,
        type = MessageType.Text,
        timestamp = SENT_AT,
        wiId = wiId,
        content = content,
        buttons = buttons,
    )

    private fun chatViewModel(
        title: String = "Support",
        savedState: SavedStateHandle = SavedStateHandle(),
    ): ChatViewModel = ChatViewModel(
        title = title,
        chatMessageRepository = chatMessageRepository,
        yaloMessageRepository = yaloMessageRepository,
        savedState = savedState,
        hostMessages = hostMessages,
        now = { SENT_AT },
    )

    /**
     * Stands in for the channel so a test can say what it does without a socket.
     *
     * Set [failure] to make every send come back failed, which is how a test
     * asks what the screen does when the message never leaves the device.
     */
    private class FakeYaloMessageRepository(
        var failure: Throwable? = null,
    ) : YaloMessageRepository {

        val sent: MutableList<ChatMessage> = mutableListOf()

        var isOpen: Boolean = false
            private set

        private val incoming = MutableSharedFlow<ChatMessage>(extraBufferCapacity = 8)

        override fun connect() {
            isOpen = true
        }

        override fun messages(): Flow<ChatMessage> = incoming

        /** Has the channel say [message], the way the socket would. */
        fun answer(message: ChatMessage) {
            incoming.tryEmit(message)
        }

        override suspend fun send(message: ChatMessage): Result<Unit> {
            failure?.let { error -> return Result.failure(error) }
            sent.add(message)
            return Result.success(Unit)
        }

        override fun close() {
            isOpen = false
        }
    }

    private companion object {
        const val SENT_AT = 1_700_000_000_000L
    }
}

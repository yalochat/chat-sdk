// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.viewmodels

import ai.yalo.chat.sdk.data.repositories.chatmessage.FakeChatMessageRepository
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import androidx.lifecycle.SavedStateHandle
import kotlinx.coroutines.Dispatchers
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

    private val chatMessages = FakeChatMessageRepository()
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
        chatMessages.failure = IllegalStateException("storage is gone")
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
        chatMessages.failure = IllegalStateException("storage is gone")
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

    private fun chatViewModel(
        title: String = "Support",
        savedState: SavedStateHandle = SavedStateHandle(),
    ): ChatViewModel = ChatViewModel(
        title = title,
        chatMessages = chatMessages,
        savedState = savedState,
        hostMessages = hostMessages,
        now = { SENT_AT },
    )

    private companion object {
        const val SENT_AT = 1_700_000_000_000L
    }
}

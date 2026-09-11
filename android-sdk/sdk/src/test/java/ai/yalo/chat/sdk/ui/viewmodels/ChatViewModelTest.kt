// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.viewmodels

import androidx.lifecycle.SavedStateHandle
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatViewModelTest {

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
    }

    @Test
    fun readsBackAHalfTypedMessageAfterBeingRecreated() {
        val savedState = SavedStateHandle()
        chatViewModel(savedState = savedState).onDraftChange("Half typed")

        val recreated = chatViewModel(savedState = savedState)

        assertEquals("Half typed", recreated.uiState.draft)
    }

    private fun chatViewModel(
        title: String = "Support",
        savedState: SavedStateHandle = SavedStateHandle(),
    ): ChatViewModel = ChatViewModel(title = title, savedState = savedState)
}

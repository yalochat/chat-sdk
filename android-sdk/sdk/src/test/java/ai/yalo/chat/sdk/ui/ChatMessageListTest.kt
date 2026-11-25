// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.AvatarDisplay
import ai.yalo.chat.sdk.TypingIndicatorAvatarPosition
import ai.yalo.chat.sdk.TypingIndicatorType
import ai.yalo.chat.sdk.YaloChatMessageAvatar
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import android.content.Context
import android.text.format.DateUtils
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.activity.ComponentActivity
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.getUnclippedBoundsInRoot
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipeDown
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import ai.yalo.chat.sdk.ui.messages.CHAT_ASSISTANT_AVATAR_TAG
import ai.yalo.chat.sdk.ui.messages.CHAT_USER_AVATAR_TAG
import ai.yalo.chat.sdk.ui.messages.CHAT_TYPING_INDICATOR_TAG
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatMessageListTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun keepsADragFromTheParentEvenWhenTheListCannotScroll() {
        val parent = RecordingParent(composeRule.activity)
        composeRule.runOnUiThread {
            parent.addView(
                ComposeView(composeRule.activity).apply {
                    setContent { ChatMessageList(messages = listOf(message())) }
                },
                ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT),
            )
            composeRule.activity.setContentView(parent)
        }

        composeRule.onNodeWithTag(CHAT_MESSAGE_LIST_TAG).performTouchInput { swipeDown() }

        assertEquals(listOf(true), parent.requests.distinct())
    }

    @Test
    fun showsOneAvatarPerRunOfMessagesFromTheSameSide() {
        showConversation(AvatarDisplay.LastInGroup)

        composeRule.onAllNodesWithTag(CHAT_USER_AVATAR_TAG).assertCountEquals(1)
        composeRule.onAllNodesWithTag(CHAT_ASSISTANT_AVATAR_TAG).assertCountEquals(2)
    }

    @Test
    fun showsAnAvatarOnEveryMessageWhenAskedTo() {
        showConversation(AvatarDisplay.EveryMessage)

        composeRule.onAllNodesWithTag(CHAT_USER_AVATAR_TAG).assertCountEquals(2)
        composeRule.onAllNodesWithTag(CHAT_ASSISTANT_AVATAR_TAG).assertCountEquals(3)
    }

    @Test
    fun showsNoAvatarWhenNoneIsConfigured() {
        composeRule.setContent {
            ChatMessageList(messages = conversation())
        }

        composeRule.onAllNodesWithTag(CHAT_USER_AVATAR_TAG).assertCountEquals(0)
        composeRule.onAllNodesWithTag(CHAT_ASSISTANT_AVATAR_TAG).assertCountEquals(0)
    }

    @Test
    fun showsThreeDotsWhileWaitingForAReplyByDefault() {
        composeRule.setContent {
            ChatMessageList(messages = listOf(message()), isWaitingForReply = true)
        }

        composeRule.onNodeWithTag(CHAT_TYPING_INDICATOR_TAG).assertIsDisplayed()
        composeRule.onNodeWithText("Writing…").assertDoesNotExist()
    }

    @Test
    fun showsWritingWhenTheTypingIndicatorIsText() {
        composeRule.setContent {
            ChatMessageList(
                messages = listOf(message()),
                isWaitingForReply = true,
                typingIndicatorType = TypingIndicatorType.Text,
            )
        }

        composeRule.onNodeWithText("Writing…").assertIsDisplayed()
    }

    @Test
    fun showsTheWritingTextTheAppGave() {
        composeRule.setContent {
            ChatMessageList(
                messages = listOf(message()),
                isWaitingForReply = true,
                typingIndicatorType = TypingIndicatorType.Text,
                writingIndicatorText = "Thinking",
            )
        }

        composeRule.onNodeWithText("Thinking").assertIsDisplayed()
    }

    @Test
    fun fadesTheWritingTextOutWhenTheReplyLands() {
        var waiting by mutableStateOf(true)
        composeRule.setContent {
            ChatMessageList(
                messages = listOf(message()),
                isWaitingForReply = waiting,
                typingIndicatorType = TypingIndicatorType.Text,
            )
        }
        composeRule.waitForIdle()

        composeRule.mainClock.autoAdvance = false
        waiting = false
        composeRule.mainClock.advanceTimeByFrame()
        composeRule.onNodeWithText("Writing…").assertExists()

        composeRule.mainClock.autoAdvance = true
        composeRule.onNodeWithText("Writing…").assertDoesNotExist()
    }

    @Test
    fun showsTheAssistantAvatarBesideEitherTypingIndicator() {
        var type by mutableStateOf(TypingIndicatorType.ThreeDots)
        composeRule.setContent {
            ChatMessageList(
                messages = listOf(message(role = MessageRole.User)),
                isWaitingForReply = true,
                assistantAvatar = YaloChatMessageAvatar.Text("YA"),
                typingIndicatorType = type,
            )
        }
        composeRule.onAllNodesWithTag(CHAT_ASSISTANT_AVATAR_TAG).assertCountEquals(1)

        type = TypingIndicatorType.Text

        composeRule.onAllNodesWithTag(CHAT_ASSISTANT_AVATAR_TAG).assertCountEquals(1)
    }

    @Test
    fun movesTheAvatarFromTheNewestAssistantMessageToTheTypingIndicator() {
        composeRule.setContent {
            ChatMessageList(
                messages = conversation(),
                isWaitingForReply = true,
                assistantAvatar = YaloChatMessageAvatar.Text("YA"),
            )
        }

        // The indicator and the older assistant run, not the newest message.
        composeRule.onAllNodesWithTag(CHAT_ASSISTANT_AVATAR_TAG).assertCountEquals(2)
    }

    @Test
    fun leavesTheAvatarOutOfTheTypingIndicatorWhenNoneIsConfigured() {
        composeRule.setContent {
            ChatMessageList(messages = listOf(message()), isWaitingForReply = true)
        }

        composeRule.onAllNodesWithTag(CHAT_ASSISTANT_AVATAR_TAG).assertCountEquals(0)
    }

    @Test
    fun placesTheTypingIndicatorAvatarWhereAsked() {
        var position by mutableStateOf(TypingIndicatorAvatarPosition.Center)
        composeRule.setContent {
            ChatMessageList(
                messages = listOf(message(role = MessageRole.User)),
                isWaitingForReply = true,
                assistantAvatar = YaloChatMessageAvatar.Text("YA"),
                typingIndicatorAvatarPosition = position,
            )
        }
        fun avatarIsBelow(): Boolean {
            val avatar = composeRule.onNodeWithTag(CHAT_ASSISTANT_AVATAR_TAG).getUnclippedBoundsInRoot()
            val indicator = composeRule.onNodeWithTag(CHAT_TYPING_INDICATOR_TAG).getUnclippedBoundsInRoot()
            return avatar.top >= indicator.bottom
        }
        assertEquals(false, avatarIsBelow())

        position = TypingIndicatorAvatarPosition.Below
        composeRule.waitForIdle()

        assertEquals(true, avatarIsBelow())
    }

    @Test
    fun startsEachDayWithItsDayWhenTimestampsAreOn() {
        val today = System.currentTimeMillis()
        val yesterday = today - DateUtils.DAY_IN_MILLIS
        composeRule.setContent {
            ChatMessageList(
                messages = listOf(
                    message(id = 3L).copy(timestamp = today),
                    message(id = 2L).copy(timestamp = yesterday),
                    message(id = 1L).copy(timestamp = yesterday),
                ),
                showTimestamps = true,
            )
        }

        composeRule.onAllNodesWithTag(CHAT_DAY_SEPARATOR_TAG).assertCountEquals(2)
    }

    @Test
    fun leavesTheDaysOutWhenTimestampsAreOff() {
        composeRule.setContent {
            ChatMessageList(messages = conversation())
        }

        composeRule.onAllNodesWithTag(CHAT_DAY_SEPARATOR_TAG).assertCountEquals(0)
    }

    private fun showConversation(display: AvatarDisplay) {
        composeRule.setContent {
            ChatMessageList(
                messages = conversation(),
                userAvatar = YaloChatMessageAvatar.Text("JR"),
                assistantAvatar = YaloChatMessageAvatar.Text("YA"),
                avatarDisplay = display,
            )
        }
    }

    // Newest first: an assistant run of two, a user run of two, then one more assistant message.
    private fun conversation() = listOf(
        message(id = 5L, role = MessageRole.Agent),
        message(id = 4L, role = MessageRole.Agent),
        message(id = 3L, role = MessageRole.User),
        message(id = 2L, role = MessageRole.User),
        message(id = 1L, role = MessageRole.Agent),
    )

    private fun message(id: Long = 1L, role: MessageRole = MessageRole.Agent) = ChatMessage(
        role = role,
        type = MessageType.Text,
        timestamp = 1_000L,
        id = id,
        content = "Hello $id",
    )

    private class RecordingParent(context: Context) : FrameLayout(context) {
        val requests = mutableListOf<Boolean>()

        override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
            requests += disallowIntercept
            super.requestDisallowInterceptTouchEvent(disallowIntercept)
        }
    }
}

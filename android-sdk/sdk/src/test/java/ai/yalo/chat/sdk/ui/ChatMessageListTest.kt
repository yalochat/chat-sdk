// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.AvatarDisplay
import ai.yalo.chat.sdk.YaloChatMessageAvatar
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.activity.ComponentActivity
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipeDown
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import ai.yalo.chat.sdk.ui.messages.CHAT_ASSISTANT_AVATAR_TAG
import ai.yalo.chat.sdk.ui.messages.CHAT_USER_AVATAR_TAG
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

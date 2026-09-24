// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageStatus
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.ui.messages.CHAT_TYPING_INDICATOR_TAG
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatMessageListTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun showsThatAReplyIsOnItsWay() {
        composeRule.setContent {
            ChatMessageList(messages = listOf(message()), isWaitingForReply = true)
        }

        composeRule.onNodeWithTag(CHAT_TYPING_INDICATOR_TAG).assertIsDisplayed()
    }

    @Test
    fun showsNothingWhileNoReplyIsExpected() {
        composeRule.setContent {
            ChatMessageList(messages = listOf(message()), isWaitingForReply = false)
        }

        composeRule.onNodeWithTag(CHAT_TYPING_INDICATOR_TAG).assertDoesNotExist()
    }

    private fun message(): ChatMessage = ChatMessage(
        role = MessageRole.User,
        type = MessageType.Text,
        timestamp = 1_700_000_000_000L,
        id = 1L,
        content = "Hello",
        status = MessageStatus.Sent,
    )
}

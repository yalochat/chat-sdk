// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatLayoutTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun showsHeaderMessageListAndFooter() {
        composeRule.setContent {
            ChatLayout(
                title = "Support",
                text = "",
                onTextChange = {},
                onSend = {},
                messages = listOf(
                    ChatMessage(
                        role = MessageRole.Agent,
                        type = MessageType.Text,
                        timestamp = 1_000L,
                        content = "How can I help?",
                    ),
                ),
            )
        }

        composeRule.onNodeWithTag(CHAT_HEADER_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_MESSAGE_LIST_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_FOOTER_TAG).assertIsDisplayed()
    }

    @Test
    fun showsTheConversationBetweenTheHeaderAndTheFooter() {
        composeRule.setContent {
            ChatLayout(
                title = "Support",
                text = "",
                onTextChange = {},
                onSend = {},
                messages = listOf(
                    ChatMessage(
                        role = MessageRole.Agent,
                        type = MessageType.Text,
                        timestamp = 1_000L,
                        content = "How can I help?",
                    ),
                ),
            )
        }

        composeRule.onNodeWithText("How can I help?").assertIsDisplayed()
    }

    @Test
    fun ordersHeaderAboveMessageListAboveFooter() {
        composeRule.setContent {
            ChatLayout(
                title = "Support",
                text = "",
                onTextChange = {},
                onSend = {},
                messages = listOf(
                    ChatMessage(
                        role = MessageRole.Agent,
                        type = MessageType.Text,
                        timestamp = 1_000L,
                        content = "How can I help?",
                    ),
                ),
            )
        }

        val header = composeRule.onNodeWithTag(CHAT_HEADER_TAG).fetchSemanticsNode()
        val messageList = composeRule.onNodeWithTag(CHAT_MESSAGE_LIST_TAG).fetchSemanticsNode()
        val footer = composeRule.onNodeWithTag(CHAT_FOOTER_TAG).fetchSemanticsNode()

        assertEquals(true, header.boundsInRoot.bottom <= messageList.boundsInRoot.top)
        assertEquals(true, messageList.boundsInRoot.bottom <= footer.boundsInRoot.top)
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import androidx.compose.foundation.layout.Column
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatMessageItemTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun showsWhatTheUserWrote() {
        composeRule.setContent {
            ChatMessageItem(message(role = MessageRole.User, content = "Hello"))
        }

        composeRule.onNodeWithText("Hello").assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_USER_MESSAGE_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_AGENT_MESSAGE_TAG).assertDoesNotExist()
    }

    @Test
    fun showsWhatTheAgentAnswered() {
        composeRule.setContent {
            ChatMessageItem(message(role = MessageRole.Agent, content = "How can I help?"))
        }

        composeRule.onNodeWithText("How can I help?").assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_AGENT_MESSAGE_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_USER_MESSAGE_TAG).assertDoesNotExist()
    }

    @Test
    fun readsWhatTheAgentAnsweredAsMarkdown() {
        composeRule.setContent {
            ChatMessageItem(message(role = MessageRole.Agent, content = "**Shipped** today"))
        }

        composeRule.onNodeWithText("Shipped today").assertIsDisplayed()
    }

    @Test
    fun showsWhatThePersonTypedTheWayTheyTypedIt() {
        composeRule.setContent {
            ChatMessageItem(message(role = MessageRole.User, content = "**Shipped** today"))
        }

        composeRule.onNodeWithText("**Shipped** today").assertIsDisplayed()
    }

    @Test
    fun saysSoRatherThanDroppingAMessageItCannotDraw() {
        composeRule.setContent {
            ChatMessageItem(
                message(role = MessageRole.Agent, content = "").copy(type = MessageType.Voice),
            )
        }

        composeRule.onNodeWithTag(CHAT_UNSUPPORTED_MESSAGE_TAG).assertIsDisplayed()
    }

    @Test
    fun keepsTheUnsupportedNoticeForEveryKindItCannotDraw() {
        val undrawable = MessageType.entries - MessageType.Text
        composeRule.setContent {
            Column {
                MessageRole.entries.forEach { role ->
                    undrawable.forEach { type ->
                        ChatMessageItem(message(role = role, content = "raw").copy(type = type))
                    }
                }
            }
        }

        composeRule.onAllNodesWithTag(CHAT_UNSUPPORTED_MESSAGE_TAG)
            .assertCountEquals(undrawable.size * MessageRole.entries.size)
        composeRule.onAllNodesWithText("raw").assertCountEquals(0)
    }

    @Test
    fun offersTheAnswersItWasGiven() {
        composeRule.setContent {
            ChatMessageItem(
                message = message(role = MessageRole.Agent, content = "Anything else?"),
                quickReplies = listOf(MessageButton(text = "Yes"), MessageButton(text = "No")),
            )
        }

        composeRule.onNodeWithText("Yes").assertIsDisplayed()
        composeRule.onNodeWithText("No").assertIsDisplayed()
        composeRule.onAllNodesWithTag(CHAT_QUICK_REPLY_TAG).assertCountEquals(2)
    }

    @Test
    fun offersNothingWhenItWasGivenNoAnswers() {
        composeRule.setContent {
            ChatMessageItem(message(role = MessageRole.Agent, content = "Anything else?"))
        }

        composeRule.onNodeWithTag(CHAT_QUICK_REPLY_TAG).assertDoesNotExist()
    }

    @Test
    fun saysTheAnswerThatWasTapped() {
        val chosen = mutableListOf<String>()
        composeRule.setContent {
            ChatMessageItem(
                message = message(role = MessageRole.Agent, content = "Anything else?"),
                quickReplies = listOf(MessageButton(text = "Yes"), MessageButton(text = "No")),
                onQuickReply = { text -> chosen.add(text) },
            )
        }

        composeRule.onNodeWithText("No").performClick()

        assertEquals(listOf("No"), chosen)
    }

    private fun message(role: MessageRole, content: String) = ChatMessage(
        role = role,
        type = MessageType.Text,
        timestamp = 1_000L,
        content = content,
    )
}

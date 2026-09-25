// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.domain.models.VoiceNote
import ai.yalo.chat.sdk.ui.voice.CHAT_VOICE_MESSAGE_TAG
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/**
 * What each body draws on its own, with nothing playing, which is how a message
 * is drawn everywhere except the one bubble somebody is listening to.
 */
@RunWith(RobolectricTestRunner::class)
class MessageBodyTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun showsWhatTheUserTypedExactlyAsTheyTypedIt() {
        composeRule.setContent {
            UserMessageBody(message(MessageRole.User, MessageType.Text, content = "**bold**"))
        }

        composeRule.onNodeWithText("**bold**").assertIsDisplayed()
    }

    @Test
    fun showsAVoiceNoteTheUserRecordedWithNothingPlaying() {
        composeRule.setContent {
            UserMessageBody(voiceMessage(MessageRole.User))
        }

        composeRule.onNodeWithTag(CHAT_VOICE_MESSAGE_TAG).assertIsDisplayed()
    }

    @Test
    fun standsInForAKindTheUserCannotBeShownYet() {
        composeRule.setContent {
            UserMessageBody(message(MessageRole.User, MessageType.Video))
        }

        composeRule.onNodeWithTag(CHAT_UNSUPPORTED_MESSAGE_TAG).assertIsDisplayed()
    }

    @Test
    fun readsWhatTheAgentAnsweredAsMarkdown() {
        composeRule.setContent {
            AgentMessageBody(message(MessageRole.Agent, MessageType.Text, content = "**bold**"))
        }

        composeRule.onNodeWithText("bold").assertIsDisplayed()
    }

    @Test
    fun showsAVoiceNoteTheAgentSentWithNothingPlaying() {
        composeRule.setContent {
            AgentMessageBody(voiceMessage(MessageRole.Agent))
        }

        composeRule.onNodeWithTag(CHAT_VOICE_MESSAGE_TAG).assertIsDisplayed()
    }

    @Test
    fun standsInForAKindTheAgentSentThatCannotBeShownYet() {
        composeRule.setContent {
            AgentMessageBody(message(MessageRole.Agent, MessageType.Video))
        }

        composeRule.onNodeWithTag(CHAT_UNSUPPORTED_MESSAGE_TAG).assertIsDisplayed()
    }

    private fun message(
        role: MessageRole,
        type: MessageType,
        content: String = "",
    ) = ChatMessage(role = role, type = type, timestamp = 1_000L, id = 1L, content = content)

    private fun voiceMessage(role: MessageRole) = ChatMessage(
        role = role,
        type = MessageType.Voice,
        timestamp = 1_000L,
        id = 1L,
        voice = VoiceNote(durationMillis = 4_000, amplitudes = listOf(0.2f, 0.9f)),
    )
}

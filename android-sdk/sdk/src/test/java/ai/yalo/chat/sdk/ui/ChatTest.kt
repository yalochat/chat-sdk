// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.data.services.chatmessage.ChatMessageDatabaseService
import ai.yalo.chat.sdk.ui.messages.CHAT_TYPING_INDICATOR_TAG
import ai.yalo.chat.sdk.ui.messages.CHAT_USER_MESSAGE_TAG
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.junit4.ComposeContentTestRule
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import org.junit.After
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatTest {

    @get:Rule
    val composeRule = createComposeRule()

    // Every chat in an app shares one database, so a test has to hand the next
    // one back a clean instance rather than the one it just wrote through.
    @After
    fun forgetTheSharedDatabase() {
        ChatMessageDatabaseService.reset()
    }

    private val client = YaloChatClient(
        YaloChatClientConfig(
            channelId = "channel-id",
            organizationId = "organization-id",
            channelName = "Support",
            userId = "user-id",
        ),
    )

    @Test
    fun showsTheConfiguredChannelNameInTheHeader() {
        composeRule.setContent {
            Chat(client)
        }

        composeRule.onNodeWithText("Support").assertIsDisplayed()
    }

    @Test
    fun appliesTheModifierTheHostPassesIn() {
        composeRule.setContent {
            Chat(client, Modifier.testTag(HOST_TAG))
        }

        composeRule.onNodeWithTag(HOST_TAG).assertIsDisplayed()
    }

    @Test
    fun enablesSendOnceTheUserTypes() {
        composeRule.setContent {
            Chat(client)
        }

        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsNotEnabled()
        composeRule.onNodeWithTag(CHAT_INPUT_TAG).performTextInput("Hello")

        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsEnabled()
    }

    @Test
    fun movesWhatWasTypedIntoTheConversation() {
        composeRule.setContent {
            Chat(client)
        }

        composeRule.onNodeWithTag(CHAT_INPUT_TAG).performTextInput("Hello")
        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).performClick()

        composeRule.awaitTag(CHAT_USER_MESSAGE_TAG)
        // An empty input is what leaves nothing to send, so the disabled button
        // is the visible proof the draft was cleared.
        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsNotEnabled()
    }

    @Test
    fun waitsForAReplyOnceSomethingIsSent() {
        composeRule.setContent {
            Chat(client)
        }

        composeRule.onNodeWithTag(CHAT_INPUT_TAG).performTextInput("Hello")
        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).performClick()

        composeRule.awaitTag(CHAT_TYPING_INDICATOR_TAG)
    }

    @Test
    fun showsWhatTheHostSentThroughTheClient() {
        composeRule.setContent {
            Chat(client)
        }

        client.sendTextMessage("Sent by the app")

        composeRule.waitUntil(CATCH_UP_TIMEOUT) {
            composeRule.onAllNodesWithText("Sent by the app")
                .fetchSemanticsNodes()
                .isNotEmpty()
        }
    }

    @Test
    fun sharesOneChatBetweenClientsOnTheSameSession() {
        val sameSession = YaloChatClient(client.config.copy())
        composeRule.setContent {
            Column {
                Box(modifier = Modifier.weight(1f)) {
                    Chat(client)
                }
                Box(modifier = Modifier.weight(1f)) {
                    Chat(sameSession)
                }
            }
        }

        composeRule.onAllNodesWithTag(CHAT_INPUT_TAG)[0].performTextInput("Hello")

        composeRule.onAllNodesWithText("Hello").assertCountEquals(2)
    }

    @Test
    fun keepsChatsOnDifferentSessionsApart() {
        val otherClient = YaloChatClient(client.config.copy(userId = "other-user-id"))
        composeRule.setContent {
            Column {
                Box(modifier = Modifier.weight(1f)) {
                    Chat(client)
                }
                Box(modifier = Modifier.weight(1f)) {
                    Chat(otherClient)
                }
            }
        }

        composeRule.onAllNodesWithTag(CHAT_INPUT_TAG)[0].performTextInput("Hello")

        composeRule.onAllNodesWithText("Hello").assertCountEquals(1)
    }

    // A sent message is stored before it is shown, and the storing happens off
    // the main thread, so the node turns up after the click rather than with it.
    private fun ComposeContentTestRule.awaitTag(tag: String) {
        waitUntil(CATCH_UP_TIMEOUT) {
            onAllNodesWithTag(tag).fetchSemanticsNodes().isNotEmpty()
        }
    }

    private companion object {
        const val HOST_TAG = "host-modifier"

        // Long enough for a loaded build machine to get round to the storage.
        const val CATCH_UP_TIMEOUT = 10_000L
    }
}

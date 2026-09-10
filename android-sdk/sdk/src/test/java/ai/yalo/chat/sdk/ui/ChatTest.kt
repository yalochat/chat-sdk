// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatTest {

    @get:Rule
    val composeRule = createComposeRule()

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
    fun clearsTheInputAfterSending() {
        composeRule.setContent {
            Chat(client)
        }

        composeRule.onNodeWithTag(CHAT_INPUT_TAG).performTextInput("Hello")
        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).performClick()

        composeRule.onNodeWithText("Hello").assertDoesNotExist()
        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsNotEnabled()
    }

    private companion object {
        const val HOST_TAG = "host-modifier"
    }
}

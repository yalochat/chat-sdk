// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.data.datasources.chatmessage.ChatMessageDatabaseDataSource
import androidx.activity.ComponentActivity
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatViewTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @After
    fun forgetTheSharedDatabase() {
        ChatMessageDatabaseDataSource.reset()
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
    fun showsTheChatOnceItHasAClient() {
        val view = ChatView(composeRule.activity)
        show(view)

        composeRule.onNodeWithText("Support").assertDoesNotExist()

        composeRule.runOnUiThread {
            view.client = client
        }

        composeRule.onNodeWithText("Support").assertIsDisplayed()
    }

    @Test
    fun appliesTheThemeAdjustment() {
        var adjusted = 0
        show(
            ChatView(composeRule.activity).apply {
                client = this@ChatViewTest.client
                theme = { default ->
                    adjusted++
                    default
                }
            },
        )

        composeRule.waitForIdle()

        assertTrue(adjusted > 0)
    }

    @Test
    fun callsOnBackFromTheHeader() {
        var backs = 0
        show(
            ChatView(composeRule.activity).apply {
                client = this@ChatViewTest.client
                onBack = { backs++ }
            },
        )

        composeRule.onNodeWithContentDescription(backDescription()).performClick()

        assertEquals(1, backs)
    }

    private fun show(view: ChatView) {
        composeRule.runOnUiThread {
            composeRule.activity.setContentView(view)
        }
    }

    private fun backDescription(): String =
        composeRule.activity.getString(R.string.yalo_chat_back_button_description)
}

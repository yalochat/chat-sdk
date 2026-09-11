// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.R
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment

@RunWith(RobolectricTestRunner::class)
class ChatFooterTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun showsAnInputAndASendButton() {
        setFooter(text = "")

        composeRule.onNodeWithTag(CHAT_INPUT_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsDisplayed()
    }

    @Test
    fun reportsWhatTheUserTypes() {
        val typed = mutableListOf<String>()
        setFooter(text = "", onTextChange = { value -> typed.add(value) })

        composeRule.onNodeWithTag(CHAT_INPUT_TAG).performTextInput("Hi")

        assertEquals(listOf("Hi"), typed)
    }

    @Test
    fun offersToRecordWhileThereIsNothingToSend() {
        setFooter(text = "")

        composeRule.onNodeWithContentDescription(micDescription()).assertIsDisplayed()
        composeRule.onNodeWithContentDescription(sendDescription()).assertDoesNotExist()
    }

    @Test
    fun turnsIntoTheSendButtonOnceThereIsSomethingToSend() {
        setFooter(text = "Hello")

        composeRule.onNodeWithContentDescription(sendDescription()).assertIsDisplayed()
        composeRule.onNodeWithContentDescription(micDescription()).assertDoesNotExist()
    }

    @Test
    fun keepsSendDisabledWhileTheInputIsBlank() {
        setFooter(text = "   ")

        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsNotEnabled()
    }

    @Test
    fun sendsWhenTheButtonIsClickedWithText() {
        var sendCount = 0
        setFooter(text = "Hello", onSend = { sendCount++ })

        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsEnabled().performClick()

        assertEquals(1, sendCount)
    }

    private fun micDescription(): String =
        RuntimeEnvironment.getApplication().getString(R.string.yalo_chat_mic_button_description)

    private fun sendDescription(): String =
        RuntimeEnvironment.getApplication().getString(R.string.yalo_chat_send_button_description)

    private fun setFooter(
        text: String,
        onTextChange: (String) -> Unit = {},
        onSend: () -> Unit = {},
    ) {
        composeRule.setContent {
            ChatFooter(text = text, onTextChange = onTextChange, onSend = onSend)
        }
    }
}

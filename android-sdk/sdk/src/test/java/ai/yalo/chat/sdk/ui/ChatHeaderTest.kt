// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatHeaderTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun showsTheGivenTitle() {
        composeRule.setContent {
            ChatHeader(title = "Support")
        }

        composeRule.onNodeWithText("Support").assertIsDisplayed()
    }
}

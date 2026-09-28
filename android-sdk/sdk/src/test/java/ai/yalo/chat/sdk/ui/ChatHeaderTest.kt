// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import androidx.compose.material3.Text
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
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

    @Test
    fun creditsYaloUnderTheTitle() {
        composeRule.setContent {
            ChatHeader(title = "Support")
        }

        composeRule.onNodeWithTag(CHAT_WATERMARK_TAG).assertIsDisplayed()
        composeRule.onNodeWithText("By Yalo").assertIsDisplayed()
    }

    @Test
    fun leavesTheCreditOutWhenTheWatermarkIsHidden() {
        composeRule.setContent {
            ChatHeader(title = "Support", hideWatermark = true)
        }

        composeRule.onNodeWithTag(CHAT_WATERMARK_TAG).assertDoesNotExist()
        composeRule.onNodeWithText("Support").assertIsDisplayed()
    }

    @Test
    fun showsTheStatusOnlyWhenThereIsOne() {
        composeRule.setContent {
            ChatHeader(title = "Support")
        }

        composeRule.onNodeWithTag(CHAT_STATUS_TAG).assertDoesNotExist()
    }

    @Test
    fun showsTheStatusUnderTheTitle() {
        composeRule.setContent {
            ChatHeader(title = "Support", status = "typing...")
        }

        composeRule.onNodeWithTag(CHAT_STATUS_TAG).assertIsDisplayed()
        composeRule.onNodeWithText("typing...").assertIsDisplayed()
    }

    @Test
    fun showsTheAvatarTheHostDrew() {
        composeRule.setContent {
            ChatHeader(title = "Support", avatar = { Text("avatar") })
        }

        composeRule.onNodeWithText("avatar").assertIsDisplayed()
    }

    @Test
    fun leavesTheBackButtonOutUnlessThereIsSomewhereToGo() {
        composeRule.setContent {
            ChatHeader(title = "Support")
        }

        composeRule.onNodeWithTag(CHAT_BACK_BUTTON_TAG).assertDoesNotExist()
    }

    @Test
    fun goesBackWhenTheBackButtonIsClicked() {
        var backCount = 0
        composeRule.setContent {
            ChatHeader(title = "Support", onBack = { backCount++ })
        }

        composeRule.onNodeWithTag(CHAT_BACK_BUTTON_TAG).assertIsDisplayed().performClick()

        assertEquals(1, backCount)
    }
}

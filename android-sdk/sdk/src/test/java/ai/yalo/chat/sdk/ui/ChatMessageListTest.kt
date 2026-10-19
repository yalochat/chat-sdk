// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.activity.ComponentActivity
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipeDown
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatMessageListTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun keepsADragFromTheParentEvenWhenTheListCannotScroll() {
        val parent = RecordingParent(composeRule.activity)
        composeRule.runOnUiThread {
            parent.addView(
                ComposeView(composeRule.activity).apply {
                    setContent { ChatMessageList(messages = listOf(message())) }
                },
                ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT),
            )
            composeRule.activity.setContentView(parent)
        }

        composeRule.onNodeWithTag(CHAT_MESSAGE_LIST_TAG).performTouchInput { swipeDown() }

        assertEquals(listOf(true), parent.requests.distinct())
    }

    private fun message() = ChatMessage(
        role = MessageRole.Agent,
        type = MessageType.Text,
        timestamp = 1_000L,
        id = 1L,
        content = "Hello",
    )

    private class RecordingParent(context: Context) : FrameLayout(context) {
        val requests = mutableListOf<Boolean>()

        override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
            requests += disallowIntercept
            super.requestDisallowInterceptTouchEvent(disallowIntercept)
        }
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.unit.dp
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatThemeAliasTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    @Suppress("DEPRECATION")
    fun oldAgentNamesReadTheAssistantValues() {
        lateinit var theme: ChatTheme
        composeRule.setContent {
            theme = ChatTheme.default().copy(
                assistantMessageBackground = Color.White,
                onAssistantMessageBackground = Color.Black,
                assistantMessageShape = RoundedCornerShape(16.dp),
                assistantMessageBorderColor = Color.Gray,
            )
        }

        assertEquals(Color.White, theme.agentMessageBackground)
        assertEquals(Color.Black, theme.onAgentMessageBackground)
        assertEquals(RoundedCornerShape(16.dp), theme.agentMessageShape)
        assertEquals(Color.Gray, theme.agentMessageBorderColor)
    }
}

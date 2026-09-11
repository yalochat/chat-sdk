// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.theme

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.ui.CHAT_FOOTER_TAG
import ai.yalo.chat.sdk.ui.CHAT_HEADER_TAG
import ai.yalo.chat.sdk.ui.CHAT_MESSAGE_LIST_TAG
import ai.yalo.chat.sdk.ui.Chat
import androidx.compose.foundation.layout.Box
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/**
 * A host styles the chat by handing a theme to [Chat]. The theme has to reach
 * every part of the chat however deep it sits, and a host that does not care
 * about styling has to get something sensible for free.
 */
@RunWith(RobolectricTestRunner::class)
class ChatThemeTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val client = YaloChatClient(
        YaloChatClientConfig(
            channelId = "channel-id",
            organizationId = "organization-id",
            channelName = "Support",
        ),
    )

    @Test
    fun followsTheHostMaterialThemeWhenNoThemeIsGiven() {
        val scheme = darkColorScheme()
        var theme: ChatTheme? = null
        composeRule.setContent {
            MaterialTheme(colorScheme = scheme) {
                theme = currentChatTheme
            }
        }

        assertEquals(
            listOf(scheme.surface, scheme.surfaceContainer, scheme.onSurface),
            listOf(theme?.background, theme?.headerBackground, theme?.onHeaderBackground),
        )
    }

    @Test
    fun reachesNestedContentWithoutBeingPassedDown() {
        var theme: ChatTheme? = null
        composeRule.setContent {
            ProvideChatTheme(CUSTOM) {
                Box {
                    Box {
                        theme = currentChatTheme
                    }
                }
            }
        }

        assertEquals(CUSTOM, theme)
    }

    @Test
    fun rendersTheWholeChatWithTheThemeTheHostGave() {
        composeRule.setContent {
            Chat(client, theme = CUSTOM)
        }

        composeRule.onNodeWithTag(CHAT_HEADER_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_MESSAGE_LIST_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_FOOTER_TAG).assertIsDisplayed()
    }

    private companion object {
        val CUSTOM = ChatTheme(
            background = Color(0xFF101010),
            onBackground = Color(0xFFFAFAFA),
            headerBackground = Color(0xFF123456),
            onHeaderBackground = Color(0xFFFFFFFF),
            footerBackground = Color(0xFF654321),
            onFooterBackground = Color(0xFFFFFFFF),
        )
    }
}

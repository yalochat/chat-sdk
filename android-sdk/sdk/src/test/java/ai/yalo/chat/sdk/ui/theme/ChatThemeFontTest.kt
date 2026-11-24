// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.theme

import ai.yalo.chat.sdk.ui.ChatHeader
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.Typography
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.sp
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChatThemeFontTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun drawsTheChatInTheThemeFont() {
        composeRule.setContent {
            ProvideChatTheme(ChatTheme.default().copy(fontFamily = FontFamily.Serif)) {
                ChatHeader(title = "Support")
            }
        }

        assertEquals(FontFamily.Serif, fontFamilyOf("Support"))
    }

    @Test
    fun reachesTextThatSetsOnlyItsSize() {
        composeRule.setContent {
            ProvideChatTheme(ChatTheme.default().copy(fontFamily = FontFamily.Serif)) {
                Text(text = "AB", fontSize = 13.sp)
            }
        }

        assertEquals(FontFamily.Serif, fontFamilyOf("AB"))
    }

    @Test
    fun keepsTheHostFontWhenTheThemeHasNone() {
        val hostTypography = Typography().let { typography ->
            typography.copy(titleMedium = typography.titleMedium.copy(fontFamily = FontFamily.Cursive))
        }
        composeRule.setContent {
            MaterialTheme(typography = hostTypography) {
                ProvideChatTheme(ChatTheme.default()) {
                    ChatHeader(title = "Support")
                }
            }
        }

        assertEquals(FontFamily.Cursive, fontFamilyOf("Support"))
    }

    private fun fontFamilyOf(text: String): FontFamily? {
        val results = mutableListOf<TextLayoutResult>()
        composeRule.onNodeWithText(text).fetchSemanticsNode()
            .config[SemanticsActions.GetTextLayoutResult].action?.invoke(results)
        return results.first().layoutInput.style.fontFamily
    }
}

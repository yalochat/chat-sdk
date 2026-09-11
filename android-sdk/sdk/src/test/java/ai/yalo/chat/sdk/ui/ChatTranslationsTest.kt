// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.R
import android.content.Context
import android.content.res.Configuration
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import java.util.Locale

/**
 * A user in any supported locale must read the chat in their own language rather
 * than in the English default. Regional locales are covered by the language
 * translation, so es-MX reads the Spanish strings and pt-BR the Portuguese ones.
 */
@RunWith(RobolectricTestRunner::class)
class ChatTranslationsTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun translatesEveryChatStringForEverySupportedLocale() {
        val english = chatStrings(Locale.ENGLISH)

        for (locale in SUPPORTED_LOCALES) {
            val translated = chatStrings(Locale.forLanguageTag(locale))

            assertTrue("$locale has a blank string", translated.none { it.isBlank() })
            assertNotEquals("$locale falls back to English", english, translated)
        }
    }

    @Test
    @Config(qualifiers = "ar")
    fun rendersTheChatInRightToLeftLanguages() {
        composeRule.setContent {
            ChatLayout(title = "الدعم", text = "", onTextChange = {}, onSend = {})
        }

        composeRule.onNodeWithTag(CHAT_HEADER_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_MESSAGE_LIST_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_FOOTER_TAG).assertIsDisplayed()
    }

    private fun chatStrings(locale: Locale): List<String> {
        val context = localizedContext(locale)
        return listOf(
            context.getString(R.string.yalo_chat_input_placeholder),
            context.getString(R.string.yalo_chat_send_button_description),
            context.getString(R.string.yalo_chat_back_button_description),
            context.getString(R.string.yalo_chat_mic_button_description),
            context.getString(R.string.yalo_chat_watermark, "Yalo"),
        )
    }

    private fun localizedContext(locale: Locale): Context {
        val application = RuntimeEnvironment.getApplication()
        val configuration = Configuration(application.resources.configuration)
        configuration.setLocale(locale)
        return application.createConfigurationContext(configuration)
    }

    private companion object {
        val SUPPORTED_LOCALES = listOf("ar", "es", "es-MX", "pt", "pt-BR", "zh", "zh-CN")
    }
}

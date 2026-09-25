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

    /**
     * Every string the SDK ships, read in [locale].
     *
     * Found rather than listed, so a string added to the SDK is translated
     * everywhere or this test says so, without anybody having to remember to
     * add it here. The brand name is passed to all of them because the ones
     * that take no argument ignore it.
     */
    private fun chatStrings(locale: Locale): List<String> {
        val context = localizedContext(locale)
        return chatStringIds().map { id -> context.getString(id, "Yalo") }
    }

    private fun chatStringIds(): List<Int> = R.string::class.java.fields
        .filter { field -> field.name.startsWith(STRING_PREFIX) }
        .map { field -> field.getInt(null) }
        .also { ids -> assertTrue("no strings were found at all", ids.isNotEmpty()) }

    private fun localizedContext(locale: Locale): Context {
        val application = RuntimeEnvironment.getApplication()
        val configuration = Configuration(application.resources.configuration)
        configuration.setLocale(locale)
        return application.createConfigurationContext(configuration)
    }

    private companion object {
        const val STRING_PREFIX = "yalo_chat_"

        val SUPPORTED_LOCALES = listOf("ar", "es", "es-MX", "pt", "pt-BR", "zh", "zh-CN")
    }
}

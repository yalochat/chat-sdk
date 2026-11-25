// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.AvatarDisplay
import ai.yalo.chat.sdk.ImageSource
import ai.yalo.chat.sdk.MessageButtonsPosition
import ai.yalo.chat.sdk.TypingIndicatorAvatarPosition
import ai.yalo.chat.sdk.TypingIndicatorType
import ai.yalo.chat.sdk.YaloChatMessageAvatar
import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.QuickReplyType
import ai.yalo.chat.sdk.SessionMode
import ai.yalo.chat.sdk.WelcomeMessageType
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.YaloChatTexts
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

class ClientConfigTest {

    private val required: String = """"channelId":"channel","organizationId":"org","channelName":"Support""""

    @Test
    fun `keeps the SDK defaults for what was left out`() {
        val config = clientConfigOf(JSONObject("{$required}"))

        assertEquals(YaloChatClientConfig(channelId = "channel", organizationId = "org", channelName = "Support"), config)
    }

    @Test
    fun `reads every option that was set`() {
        val config = clientConfigOf(
            JSONObject(
                """
                {$required,
                 "userId":"user",
                 "quickReplyType":"inline",
                 "welcomeMessageType":"verticalQuickReplies",
                 "logLevel":"debug",
                 "openContext":{"sku":"123"},
                 "sessionMode":"perContext",
                 "hideVoiceButton":true,
                 "hideAttachmentButton":true,
                 "hideWatermark":true,
                 "hideFeedbackButtons":true,
                 "texts":{"inputPlaceholder":"Ask us anything",
                          "imageNotAllowed":"Only screenshots",
                          "invalidImageAlertButtonText":"Got it"},
                 "imageSource":"screenshots",
                 "screenshotFolders":["Download"],
                 "allowedImageNames":["SCR_\\d+\\.png"]}
                """,
            ),
        )

        assertEquals(
            YaloChatClientConfig(
                channelId = "channel",
                organizationId = "org",
                channelName = "Support",
                userId = "user",
                quickReplyType = QuickReplyType.Inline,
                welcomeMessageType = WelcomeMessageType.VerticalQuickReplies,
                logLevel = LogLevel.Debug,
                openContext = mapOf("sku" to "123"),
                sessionMode = SessionMode.PerContext,
                hideVoiceButton = true,
                hideAttachmentButton = true,
                hideWatermark = true,
                hideFeedbackButtons = true,
                texts = YaloChatTexts(
                    inputPlaceholder = "Ask us anything",
                    imageNotAllowed = "Only screenshots",
                    invalidImageAlertButtonText = "Got it",
                ),
                imageSource = ImageSource.Screenshots,
                screenshotFolders = listOf("Download"),
                allowedImageNames = listOf("SCR_\\d+\\.png"),
            ),
            config,
        )
    }

    @Test
    fun `reads every log level`() {
        val levels = mapOf(
            "debug" to LogLevel.Debug,
            "info" to LogLevel.Info,
            "warn" to LogLevel.Warn,
            "error" to LogLevel.Error,
            "silent" to LogLevel.Silent,
        )

        levels.forEach { (name, level) ->
            assertEquals(level, clientConfigOf(JSONObject("""{$required,"logLevel":"$name"}""")).logLevel)
        }
    }

    @Test
    fun `reads every session mode`() {
        val modes = mapOf(
            "shared" to SessionMode.Shared,
            "perContext" to SessionMode.PerContext,
            "ephemeral" to SessionMode.Ephemeral,
        )

        modes.forEach { (name, mode) ->
            assertEquals(mode, clientConfigOf(JSONObject("""{$required,"sessionMode":"$name"}""")).sessionMode)
        }
    }

    @Test
    fun `keeps the built-in texts for what was left out`() {
        val config = clientConfigOf(JSONObject("""{$required,"texts":{}}"""))

        assertEquals(YaloChatTexts(), config.texts)
    }

    @Test
    fun `uses the token provider when JavaScript has one`() {
        val provider: suspend () -> String? = { "token" }

        val config = clientConfigOf(JSONObject("{$required,\"hasUserAuthTokenProvider\":true}"), provider)

        assertSame(provider, config.userAuthTokenProvider)
    }

    @Test
    fun `leaves the token provider out when JavaScript has none`() {
        val config = clientConfigOf(JSONObject("{$required}"), userAuthTokenProvider = { "token" })

        assertNull(config.userAuthTokenProvider)
    }

    @Test
    fun `reads the avatar, typing indicator, timestamp and button options`() {
        val config = clientConfigOf(
            JSONObject(
                """
                {$required,
                 "userMessageAvatar":{"text":"JL"},
                 "avatarDisplay":"everyMessage",
                 "typingIndicatorType":"text",
                 "typingIndicatorAvatarPosition":"below",
                 "texts":{"writingIndicator":"Typing"},
                 "showTimestamps":true,
                 "messageButtonsPosition":"insideMessage"}
                """,
            ),
        )

        assertEquals(YaloChatMessageAvatar.Text("JL"), config.userMessageAvatar)
        assertEquals(AvatarDisplay.EveryMessage, config.avatarDisplay)
        assertEquals(TypingIndicatorType.Text, config.typingIndicatorType)
        assertEquals(TypingIndicatorAvatarPosition.Below, config.typingIndicatorAvatarPosition)
        assertEquals("Typing", config.texts.writingIndicator)
        assertTrue(config.showTimestamps)
        assertEquals(MessageButtonsPosition.InsideMessage, config.messageButtonsPosition)
    }

    @Test
    fun `lists the image avatars to load`() {
        val json = JSONObject(
            """{$required,"userMessageAvatar":{"text":"JL"},"assistantMessageAvatar":{"image":"https://example.com/bot.png"}}""",
        )

        assertEquals(listOf("https://example.com/bot.png"), avatarImageUrisOf(json))
    }

    @Test
    fun `leaves out an image avatar whose picture did not load`() {
        val config = clientConfigOf(
            JSONObject("""{$required,"assistantMessageAvatar":{"image":"https://example.com/bot.png"}}"""),
        )

        assertEquals(YaloChatMessageAvatar.None, config.assistantMessageAvatar)
    }
}

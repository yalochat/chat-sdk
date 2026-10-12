// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.QuickReplyType
import ai.yalo.chat.sdk.SessionMode
import ai.yalo.chat.sdk.YaloChatClientConfig
import org.json.JSONObject
import org.junit.Assert.assertEquals
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
                 "logLevel":"debug",
                 "openContext":{"sku":"123"},
                 "sessionMode":"perContext",
                 "hideVoiceButton":true,
                 "hideAttachmentButton":true,
                 "hideWatermark":true}
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
                logLevel = LogLevel.Debug,
                openContext = mapOf("sku" to "123"),
                sessionMode = SessionMode.PerContext,
                hideVoiceButton = true,
                hideAttachmentButton = true,
                hideWatermark = true,
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
}

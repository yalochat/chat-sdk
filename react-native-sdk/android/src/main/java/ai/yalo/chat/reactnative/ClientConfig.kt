// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.QuickReplyType
import ai.yalo.chat.sdk.SessionMode
import ai.yalo.chat.sdk.YaloChatClientConfig
import org.json.JSONObject

/** The client config React Native sent, with anything left out at its SDK default. */
internal fun clientConfigOf(config: JSONObject): YaloChatClientConfig = YaloChatClientConfig(
    channelId = config.getString("channelId"),
    organizationId = config.getString("organizationId"),
    channelName = config.getString("channelName"),
    userId = if (config.isNull("userId")) null else config.getString("userId"),
    quickReplyType = quickReplyTypeOf(config.optString("quickReplyType")),
    logLevel = logLevelOf(config.optString("logLevel")),
    openContext = openContextOf(config.optJSONObject("openContext")),
    sessionMode = sessionModeOf(config.optString("sessionMode")),
    hideVoiceButton = config.optBoolean("hideVoiceButton"),
    hideAttachmentButton = config.optBoolean("hideAttachmentButton"),
    hideWatermark = config.optBoolean("hideWatermark"),
)

private fun quickReplyTypeOf(value: String): QuickReplyType = when (value) {
    "inline" -> QuickReplyType.Inline
    else -> QuickReplyType.Modal
}

private fun logLevelOf(value: String): LogLevel = when (value) {
    "debug" -> LogLevel.Debug
    "info" -> LogLevel.Info
    "error" -> LogLevel.Error
    "silent" -> LogLevel.Silent
    else -> LogLevel.Warn
}

private fun sessionModeOf(value: String): SessionMode = when (value) {
    "perContext" -> SessionMode.PerContext
    "ephemeral" -> SessionMode.Ephemeral
    else -> SessionMode.Shared
}

private fun openContextOf(context: JSONObject?): Map<String, String> {
    if (context == null) {
        return emptyMap()
    }
    return context.keys().asSequence().associateWith { key -> context.getString(key) }
}

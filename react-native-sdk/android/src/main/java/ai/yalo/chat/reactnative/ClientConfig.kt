// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.ImageSource
import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.QuickReplyType
import ai.yalo.chat.sdk.SessionMode
import ai.yalo.chat.sdk.WelcomeMessageType
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.YaloChatTexts
import org.json.JSONArray
import org.json.JSONObject

/**
 * The client config React Native sent, with anything left out at its SDK
 * default. [userAuthTokenProvider] is only used when JavaScript has one.
 */
internal fun clientConfigOf(
    config: JSONObject,
    userAuthTokenProvider: (suspend () -> String?)? = null,
): YaloChatClientConfig = YaloChatClientConfig(
    channelId = config.getString("channelId"),
    organizationId = config.getString("organizationId"),
    channelName = config.getString("channelName"),
    userId = if (config.isNull("userId")) null else config.getString("userId"),
    userAuthTokenProvider = userAuthTokenProvider.takeIf { config.optBoolean("hasUserAuthTokenProvider") },
    quickReplyType = quickReplyTypeOf(config.optString("quickReplyType")),
    welcomeMessageType = welcomeMessageTypeOf(config.optString("welcomeMessageType")),
    logLevel = logLevelOf(config.optString("logLevel")),
    openContext = openContextOf(config.optJSONObject("openContext")),
    sessionMode = sessionModeOf(config.optString("sessionMode")),
    hideVoiceButton = config.optBoolean("hideVoiceButton"),
    hideAttachmentButton = config.optBoolean("hideAttachmentButton"),
    hideWatermark = config.optBoolean("hideWatermark"),
    hideFeedbackButtons = config.optBoolean("hideFeedbackButtons"),
    texts = textsOf(config.optJSONObject("texts")),
    imageSource = imageSourceOf(config.optString("imageSource")),
    allowedImageNames = stringsOf(config.optJSONArray("allowedImageNames")),
).run {
    if (config.has("screenshotFolders")) {
        copy(screenshotFolders = stringsOf(config.optJSONArray("screenshotFolders")))
    } else {
        this
    }
}

private fun quickReplyTypeOf(value: String): QuickReplyType = when (value) {
    "inline" -> QuickReplyType.Inline
    else -> QuickReplyType.Modal
}

private fun welcomeMessageTypeOf(value: String): WelcomeMessageType = when (value) {
    "verticalQuickReplies" -> WelcomeMessageType.VerticalQuickReplies
    else -> WelcomeMessageType.None
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

private fun imageSourceOf(value: String): ImageSource = when (value) {
    "screenshots" -> ImageSource.Screenshots
    else -> ImageSource.All
}

private fun stringsOf(values: JSONArray?): List<String> {
    if (values == null) {
        return emptyList()
    }
    return List(values.length()) { index -> values.getString(index) }
}

private fun textsOf(texts: JSONObject?): YaloChatTexts {
    if (texts == null) {
        return YaloChatTexts()
    }
    return YaloChatTexts(
        inputPlaceholder = textOf(texts, "inputPlaceholder"),
        imageNotAllowed = textOf(texts, "imageNotAllowed"),
        invalidImageAlertButtonText = textOf(texts, "invalidImageAlertButtonText"),
    )
}

private fun textOf(texts: JSONObject, key: String): String? =
    if (texts.isNull(key)) null else texts.getString(key)

private fun openContextOf(context: JSONObject?): Map<String, String> {
    if (context == null) {
        return emptyMap()
    }
    return context.keys().asSequence().associateWith { key -> context.getString(key) }
}

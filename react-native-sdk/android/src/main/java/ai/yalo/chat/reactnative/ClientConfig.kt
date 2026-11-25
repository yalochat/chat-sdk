// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.AvatarDisplay
import ai.yalo.chat.sdk.ImageSource
import ai.yalo.chat.sdk.MessageButtonsPosition
import ai.yalo.chat.sdk.TypingIndicatorAvatarPosition
import ai.yalo.chat.sdk.TypingIndicatorType
import ai.yalo.chat.sdk.YaloChatMessageAvatar
import android.graphics.Bitmap
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
 * [avatarImages] are the loaded pictures of the image avatars, by the URI
 * [avatarImageUrisOf] lists. An image avatar whose picture is not there is
 * left out.
 */
internal fun clientConfigOf(
    config: JSONObject,
    userAuthTokenProvider: (suspend () -> String?)? = null,
    avatarImages: Map<String, Bitmap> = emptyMap(),
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
    typingIndicatorType = typingIndicatorTypeOf(config.optString("typingIndicatorType")),
    typingIndicatorAvatarPosition = typingIndicatorAvatarPositionOf(config.optString("typingIndicatorAvatarPosition")),
    userMessageAvatar = messageAvatarOf(config.optJSONObject("userMessageAvatar"), avatarImages),
    assistantMessageAvatar = messageAvatarOf(config.optJSONObject("assistantMessageAvatar"), avatarImages),
    avatarDisplay = avatarDisplayOf(config.optString("avatarDisplay")),
    showTimestamps = config.optBoolean("showTimestamps"),
    messageButtonsPosition = messageButtonsPositionOf(config.optString("messageButtonsPosition")),
).run {
    if (config.has("screenshotFolders")) {
        copy(screenshotFolders = stringsOf(config.optJSONArray("screenshotFolders")))
    } else {
        this
    }
}

/** The URIs of the image avatars in [config], to load before building it. */
internal fun avatarImageUrisOf(config: JSONObject): List<String> =
    listOf("userMessageAvatar", "assistantMessageAvatar").mapNotNull { key ->
        config.optJSONObject(key)?.optString("image")?.takeIf { it.isNotEmpty() }
    }

private fun messageAvatarOf(avatar: JSONObject?, images: Map<String, Bitmap>): YaloChatMessageAvatar {
    if (avatar == null) {
        return YaloChatMessageAvatar.None
    }
    if (avatar.has("text")) {
        return YaloChatMessageAvatar.Text(avatar.getString("text"))
    }
    val image = images[avatar.optString("image")] ?: return YaloChatMessageAvatar.None
    return YaloChatMessageAvatar.Image(image)
}

private fun typingIndicatorTypeOf(value: String): TypingIndicatorType = when (value) {
    "text" -> TypingIndicatorType.Text
    else -> TypingIndicatorType.ThreeDots
}

private fun typingIndicatorAvatarPositionOf(value: String): TypingIndicatorAvatarPosition = when (value) {
    "below" -> TypingIndicatorAvatarPosition.Below
    else -> TypingIndicatorAvatarPosition.Center
}

private fun avatarDisplayOf(value: String): AvatarDisplay = when (value) {
    "everyMessage" -> AvatarDisplay.EveryMessage
    else -> AvatarDisplay.LastInGroup
}

private fun messageButtonsPositionOf(value: String): MessageButtonsPosition = when (value) {
    "insideMessage" -> MessageButtonsPosition.InsideMessage
    else -> MessageButtonsPosition.BelowMessage
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
        writingIndicator = textOf(texts, "writingIndicator"),
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

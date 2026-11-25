// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.ui.theme.ChatTheme
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import org.json.JSONObject

/**
 * This theme with whatever React Native set laid over it. Colors arrive as
 * ARGB numbers, shapes as four corner radii and sizes as points. [fontFamilyOf]
 * turns the font family name into the font, and is null when it has none.
 */
internal fun ChatTheme.overriddenBy(
    theme: JSONObject,
    fontFamilyOf: (String) -> FontFamily? = { null },
): ChatTheme = copy(
    background = theme.color("background") ?: background,
    onBackground = theme.color("onBackground") ?: onBackground,
    headerBackground = theme.color("headerBackground") ?: headerBackground,
    onHeaderBackground = theme.color("onHeaderBackground") ?: onHeaderBackground,
    footerBackground = theme.color("footerBackground") ?: footerBackground,
    onFooterBackground = theme.color("onFooterBackground") ?: onFooterBackground,
    userMessageBackground = theme.color("userMessageBackground") ?: userMessageBackground,
    onUserMessageBackground = theme.color("onUserMessageBackground") ?: onUserMessageBackground,
    assistantMessageBackground = theme.color("assistantMessageBackground") ?: assistantMessageBackground,
    onAssistantMessageBackground = theme.color("onAssistantMessageBackground") ?: onAssistantMessageBackground,
    assistantMessageBorderColor = theme.color("assistantMessageBorderColor") ?: assistantMessageBorderColor,
    userMessagePadding = theme.size("userMessagePadding")?.let(::PaddingValues) ?: userMessagePadding,
    assistantMessagePadding = theme.size("assistantMessagePadding")?.let(::PaddingValues) ?: assistantMessagePadding,
    typingIndicatorDotColor = theme.color("typingIndicatorDotColor") ?: typingIndicatorDotColor,
    linkColor = theme.color("linkColor") ?: linkColor,
    quickReplyBackground = theme.color("quickReplyBackground") ?: quickReplyBackground,
    onQuickReplyBackground = theme.color("onQuickReplyBackground") ?: onQuickReplyBackground,
    quickReplyBorderColor = theme.color("quickReplyBorderColor") ?: quickReplyBorderColor,
    postbackBackground = theme.color("postbackBackground") ?: postbackBackground,
    onPostbackBackground = theme.color("onPostbackBackground") ?: onPostbackBackground,
    postbackBorderColor = theme.color("postbackBorderColor") ?: postbackBorderColor,
    selectedPostbackBackground = theme.color("selectedPostbackBackground") ?: selectedPostbackBackground,
    onSelectedPostbackBackground = theme.color("onSelectedPostbackBackground") ?: onSelectedPostbackBackground,
    inputBorderColor = theme.color("inputBorderColor") ?: inputBorderColor,
    inputFieldBorderColor = theme.color("inputFieldBorderColor") ?: inputFieldBorderColor,
    inputBackground = theme.color("inputBackground") ?: inputBackground,
    sendButtonBackground = theme.color("sendButtonBackground") ?: sendButtonBackground,
    onSendButtonBackground = theme.color("onSendButtonBackground") ?: onSendButtonBackground,
    inputShape = theme.shape("inputShape") ?: inputShape,
    userMessageShape = theme.shape("userMessageShape") ?: userMessageShape,
    assistantMessageShape = theme.shape("assistantMessageShape") ?: assistantMessageShape,
    imageShape = theme.shape("imageShape") ?: imageShape,
    quickReplyShape = theme.shape("quickReplyShape") ?: quickReplyShape,
    postbackShape = theme.shape("postbackShape") ?: postbackShape,
    inputScrollbarColor = theme.color("inputScrollbarColor") ?: inputScrollbarColor,
    inputScrollbarWidth = theme.size("inputScrollbarWidth") ?: inputScrollbarWidth,
    selectedPostbackBorderColor = theme.color("selectedPostbackBorderColor") ?: selectedPostbackBorderColor,
    disabledSendButtonBackground = theme.color("disabledSendButtonBackground") ?: disabledSendButtonBackground,
    onDisabledSendButtonBackground = theme.color("onDisabledSendButtonBackground") ?: onDisabledSendButtonBackground,
    inputPlaceholderColor = theme.color("inputPlaceholderColor") ?: inputPlaceholderColor,
    timestampColor = theme.color("timestampColor") ?: timestampColor,
    feedbackButtonColor = theme.color("feedbackButtonColor") ?: feedbackButtonColor,
    userAvatarBackground = theme.color("userAvatarBackground") ?: userAvatarBackground,
    onUserAvatarBackground = theme.color("onUserAvatarBackground") ?: onUserAvatarBackground,
    assistantAvatarBackground = theme.color("assistantAvatarBackground") ?: assistantAvatarBackground,
    onAssistantAvatarBackground = theme.color("onAssistantAvatarBackground") ?: onAssistantAvatarBackground,
    messageTailSize = theme.dpSize("messageTailSize") ?: messageTailSize,
    fontFamily = theme.optString("fontFamily").takeIf { it.isNotEmpty() }?.let(fontFamilyOf) ?: fontFamily,
)

private fun JSONObject.dpSize(key: String): DpSize? {
    val size = optJSONObject(key) ?: return null
    return DpSize(size.getDouble("width").dp, size.getDouble("height").dp)
}

private fun JSONObject.color(key: String): Color? {
    if (!has(key)) {
        return null
    }
    return Color(getLong(key).toInt())
}

private fun JSONObject.size(key: String): Dp? {
    if (!has(key)) {
        return null
    }
    return getDouble(key).dp
}

private fun JSONObject.shape(key: String): Shape? {
    val corners = optJSONObject(key) ?: return null
    return RoundedCornerShape(
        topStart = corners.getDouble("topStart").dp,
        topEnd = corners.getDouble("topEnd").dp,
        bottomEnd = corners.getDouble("bottomEnd").dp,
        bottomStart = corners.getDouble("bottomStart").dp,
    )
}

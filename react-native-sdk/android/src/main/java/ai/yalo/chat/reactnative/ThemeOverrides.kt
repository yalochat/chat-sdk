// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.ui.theme.ChatTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.dp
import org.json.JSONObject

/**
 * This theme with whatever React Native set laid over it. Colors arrive as
 * ARGB numbers and shapes as four corner radii.
 */
internal fun ChatTheme.overriddenBy(theme: JSONObject): ChatTheme = copy(
    background = theme.color("background") ?: background,
    onBackground = theme.color("onBackground") ?: onBackground,
    headerBackground = theme.color("headerBackground") ?: headerBackground,
    onHeaderBackground = theme.color("onHeaderBackground") ?: onHeaderBackground,
    footerBackground = theme.color("footerBackground") ?: footerBackground,
    onFooterBackground = theme.color("onFooterBackground") ?: onFooterBackground,
    userMessageBackground = theme.color("userMessageBackground") ?: userMessageBackground,
    onUserMessageBackground = theme.color("onUserMessageBackground") ?: onUserMessageBackground,
    agentMessageBackground = theme.color("agentMessageBackground") ?: agentMessageBackground,
    onAgentMessageBackground = theme.color("onAgentMessageBackground") ?: onAgentMessageBackground,
    typingIndicatorDotColor = theme.color("typingIndicatorDotColor") ?: typingIndicatorDotColor,
    linkColor = theme.color("linkColor") ?: linkColor,
    quickReplyBackground = theme.color("quickReplyBackground") ?: quickReplyBackground,
    onQuickReplyBackground = theme.color("onQuickReplyBackground") ?: onQuickReplyBackground,
    quickReplyBorderColor = theme.color("quickReplyBorderColor") ?: quickReplyBorderColor,
    postbackBackground = theme.color("postbackBackground") ?: postbackBackground,
    onPostbackBackground = theme.color("onPostbackBackground") ?: onPostbackBackground,
    postbackBorderColor = theme.color("postbackBorderColor") ?: postbackBorderColor,
    inputBorderColor = theme.color("inputBorderColor") ?: inputBorderColor,
    inputFieldBorderColor = theme.color("inputFieldBorderColor") ?: inputFieldBorderColor,
    inputShape = theme.shape("inputShape") ?: inputShape,
    userMessageShape = theme.shape("userMessageShape") ?: userMessageShape,
    agentMessageShape = theme.shape("agentMessageShape") ?: agentMessageShape,
    imageShape = theme.shape("imageShape") ?: imageShape,
    quickReplyShape = theme.shape("quickReplyShape") ?: quickReplyShape,
    postbackShape = theme.shape("postbackShape") ?: postbackShape,
)

private fun JSONObject.color(key: String): Color? {
    if (!has(key)) {
        return null
    }
    return Color(getLong(key).toInt())
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

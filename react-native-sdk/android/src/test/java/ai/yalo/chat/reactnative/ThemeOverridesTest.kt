// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.ui.theme.ChatTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.unit.dp
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Test

class ThemeOverridesTest {

    private val base: ChatTheme = ChatTheme(
        background = Color.White,
        onBackground = Color.White,
        headerBackground = Color.White,
        onHeaderBackground = Color.White,
        footerBackground = Color.White,
        onFooterBackground = Color.White,
        userMessageBackground = Color.White,
        onUserMessageBackground = Color.White,
        agentMessageBackground = Color.White,
        onAgentMessageBackground = Color.White,
        agentMessageBorderColor = Color.White,
        agentMessagePadding = 0.dp,
        typingIndicatorDotColor = Color.White,
        linkColor = Color.White,
        quickReplyBackground = Color.White,
        onQuickReplyBackground = Color.White,
        quickReplyBorderColor = Color.White,
        postbackBackground = Color.White,
        onPostbackBackground = Color.White,
        postbackBorderColor = Color.White,
        selectedPostbackBackground = Color.White,
        onSelectedPostbackBackground = Color.White,
        inputBorderColor = Color.White,
        inputFieldBorderColor = Color.White,
        inputBackground = Color.White,
        sendButtonBackground = Color.White,
        onSendButtonBackground = Color.White,
        inputShape = RectangleShape,
        userMessageShape = RectangleShape,
        agentMessageShape = RectangleShape,
        imageShape = RectangleShape,
        quickReplyShape = RectangleShape,
        postbackShape = RectangleShape,
    )

    @Test
    fun `keeps the base theme when nothing was set`() {
        assertEquals(base, base.overriddenBy(JSONObject()))
    }

    @Test
    fun `reads colors sent as signed or unsigned ARGB numbers`() {
        val theme = base.overriddenBy(JSONObject("""{"background":-65536,"linkColor":4278190335}"""))

        assertEquals(base.copy(background = Color.Red, linkColor = Color.Blue), theme)
    }

    @Test
    fun `reads every color`() {
        val keys = listOf(
            "background", "onBackground", "headerBackground", "onHeaderBackground", "footerBackground",
            "onFooterBackground", "userMessageBackground", "onUserMessageBackground", "agentMessageBackground",
            "onAgentMessageBackground", "agentMessageBorderColor", "typingIndicatorDotColor", "linkColor", "quickReplyBackground",
            "onQuickReplyBackground", "quickReplyBorderColor", "postbackBackground", "onPostbackBackground",
            "postbackBorderColor", "selectedPostbackBackground", "onSelectedPostbackBackground",
            "inputBorderColor", "inputFieldBorderColor",
            "inputBackground", "sendButtonBackground", "onSendButtonBackground",
        )
        val json = JSONObject()
        keys.forEach { key -> json.put(key, -16777216) }

        val theme = base.overriddenBy(json)

        assertEquals(
            ChatTheme(
                background = Color.Black,
                onBackground = Color.Black,
                headerBackground = Color.Black,
                onHeaderBackground = Color.Black,
                footerBackground = Color.Black,
                onFooterBackground = Color.Black,
                userMessageBackground = Color.Black,
                onUserMessageBackground = Color.Black,
                agentMessageBackground = Color.Black,
                onAgentMessageBackground = Color.Black,
                agentMessageBorderColor = Color.Black,
                agentMessagePadding = 0.dp,
                typingIndicatorDotColor = Color.Black,
                linkColor = Color.Black,
                quickReplyBackground = Color.Black,
                onQuickReplyBackground = Color.Black,
                quickReplyBorderColor = Color.Black,
                postbackBackground = Color.Black,
                onPostbackBackground = Color.Black,
                postbackBorderColor = Color.Black,
                selectedPostbackBackground = Color.Black,
                onSelectedPostbackBackground = Color.Black,
                inputBorderColor = Color.Black,
                inputFieldBorderColor = Color.Black,
                inputBackground = Color.Black,
                sendButtonBackground = Color.Black,
                onSendButtonBackground = Color.Black,
                inputShape = RectangleShape,
                userMessageShape = RectangleShape,
                agentMessageShape = RectangleShape,
                imageShape = RectangleShape,
                quickReplyShape = RectangleShape,
                postbackShape = RectangleShape,
            ),
            theme,
        )
    }

    @Test
    fun `reads sizes as points`() {
        val theme = base.overriddenBy(JSONObject("""{"agentMessagePadding":12.5}"""))

        assertEquals(base.copy(agentMessagePadding = 12.5.dp), theme)
    }

    @Test
    fun `reads every shape as four corners`() {
        val keys = listOf(
            "inputShape", "userMessageShape", "agentMessageShape", "imageShape", "quickReplyShape", "postbackShape",
        )
        val json = JSONObject()
        keys.forEach { key ->
            json.put(key, JSONObject("""{"topStart":1,"topEnd":2,"bottomEnd":3,"bottomStart":4.5}"""))
        }
        val shape = RoundedCornerShape(topStart = 1.dp, topEnd = 2.dp, bottomEnd = 3.dp, bottomStart = 4.5.dp)

        val theme = base.overriddenBy(json)

        assertEquals(
            base.copy(
                inputShape = shape,
                userMessageShape = shape,
                agentMessageShape = shape,
                imageShape = shape,
                quickReplyShape = shape,
                postbackShape = shape,
            ),
            theme,
        )
    }
}

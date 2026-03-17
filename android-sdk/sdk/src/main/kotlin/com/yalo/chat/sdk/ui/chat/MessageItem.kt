// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.takeOrElse
import androidx.compose.ui.graphics.painter.ColorPainter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

@Composable
internal fun MessageItem(
    message: ChatMessage,
    playingMessage: ChatMessage? = null,
    onPlayAudio: (ChatMessage) -> Unit = {},
    onStopAudio: () -> Unit = {},
) {
    val theme = LocalChatTheme.current
    val isUser = message.role == MessageRole.USER

    val bubbleColor = if (isUser) theme.userBubbleColor else theme.agentBubbleColor
    // contentColor drives LocalContentColor inside the Surface — Waveform uses it for bar color.
    val contentColor = if (isUser) {
        theme.userMessageTextStyle.color.takeOrElse { theme.actionIconColor }
    } else {
        theme.assistantMessageTextStyle.color.takeOrElse { theme.actionIconColor }
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 4.dp),
        horizontalArrangement = if (isUser) Arrangement.End else Arrangement.Start,
    ) {
        Surface(
            shape = theme.bubbleShape,
            color = bubbleColor,
            contentColor = contentColor,
            modifier = Modifier.widthIn(max = 280.dp),
        ) {
            Box(modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp)) {
                when (message.type) {
                    MessageType.Text -> Text(
                        text = message.content,
                        style = if (isUser) theme.userMessageTextStyle else theme.assistantMessageTextStyle,
                    )
                    MessageType.Image -> AsyncImage(
                        // fileName holds the local file path for user-sent images (set by
                        // sendImageMessage). content holds the URL for agent/server images.
                        // Fall back to content so both cases render correctly.
                        model = message.fileName ?: message.content,
                        contentDescription = "Image message",
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.size(200.dp),
                        placeholder = ColorPainter(theme.imagePlaceholderBackgroundColor),
                        error = ColorPainter(theme.imagePlaceholderBackgroundColor),
                    )
                    MessageType.Voice -> AudioMessageItem(
                        message = message,
                        playingMessage = playingMessage,
                        onPlay = onPlayAudio,
                        onStop = onStopAudio,
                    )
                    MessageType.Unknown -> Text(
                        text = "Unsupported message",
                        style = if (isUser) theme.userMessageTextStyle else theme.assistantMessageTextStyle,
                    )
                    else -> Text(
                        text = "[${message.type.value}]",
                        style = if (isUser) theme.userMessageTextStyle else theme.assistantMessageTextStyle,
                    )
                }
            }
        }
    }
}

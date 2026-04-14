// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import android.content.Intent
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.widget.VideoView
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayCircle
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.takeOrElse
import androidx.compose.ui.graphics.painter.ColorPainter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import coil3.compose.AsyncImage
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.ui.theme.LocalChatTheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@Composable
internal fun MessageItem(
    message: ChatMessage,
    playingMessage: ChatMessage? = null,
    onPlayAudio: (ChatMessage) -> Unit = {},
    onStopAudio: () -> Unit = {},
    onEvent: (MessagesEvent) -> Unit = {},
) {
    val theme = LocalChatTheme.current
    val isUser = message.role == MessageRole.USER

    // Product messages render their own card borders/backgrounds, so they bypass the bubble
    // Surface. This mirrors Flutter's AssistantMessage which uses a padding Container rather
    // than a colored bubble for product types.
    if (message.type == MessageType.Product || message.type == MessageType.ProductCarousel) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp, vertical = 4.dp),
            horizontalArrangement = Arrangement.Start,
        ) {
            Box(modifier = Modifier.fillMaxWidth()) {
                when (message.type) {
                    MessageType.Product -> ProductListMessage(
                        message = message,
                        onEvent = onEvent,
                    )
                    MessageType.ProductCarousel -> ProductCarouselMessage(
                        message = message,
                        onEvent = onEvent,
                    )
                    else -> Unit
                }
            }
        }
        return
    }

    val bubbleColor = if (isUser) theme.userBubbleColor else theme.agentBubbleColor
    val roleTextStyle = if (isUser) theme.userMessageTextStyle else theme.assistantMessageTextStyle
    // Merge with bodyMedium so a partial override (e.g. only color) preserves base font
    // size and weight — consistent with how timerTextStyle and modalHeaderStyle are merged.
    val messageTextStyle = MaterialTheme.typography.bodyMedium.merge(roleTextStyle)
    // contentColor drives LocalContentColor inside the Surface — Waveform uses it for bar color.
    val contentColor = roleTextStyle.color.takeOrElse { theme.actionIconColor }

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
                    MessageType.Text,
                    MessageType.QuickReply -> Text(
                        text = message.content,
                        style = messageTextStyle,
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
                    MessageType.Video -> VideoMessageItem(
                        message = message,
                        messageTextStyle = messageTextStyle,
                    )
                    MessageType.Buttons -> ButtonsMessage(
                        message = message,
                        onEvent = onEvent,
                    )
                    MessageType.CTA -> CtaMessage(message = message)
                    MessageType.Unknown -> Text(
                        text = "Unsupported message",
                        style = messageTextStyle,
                    )
                    else -> Text(
                        text = "[${message.type.value}]",
                        style = messageTextStyle,
                    )
                }
            }
        }
    }
}

// Port of flutter-sdk video_message.dart — VideoMessage widget.
//
// Thumbnail: extracted from the local file using MediaMetadataRetriever (built-in Android,
// no extra dependency). Falls back to a dark placeholder if extraction fails.
//
// Playback: tapping the thumbnail shows an in-process VideoView via AndroidView.
// VideoView reads from the local file path directly (no FileProvider needed since
// both the SDK and VideoView run in the same process and the file is private to the app).
//
// Caption: if message.content is non-empty it is shown below the video — mirrors Flutter.
@Composable
private fun VideoMessageItem(
    message: ChatMessage,
    messageTextStyle: androidx.compose.ui.text.TextStyle,
) {
    var thumbnail by remember { mutableStateOf<ImageBitmap?>(null) }
    var showPlayer by remember { mutableStateOf(false) }

    LaunchedEffect(message.fileName) {
        val path = message.fileName ?: return@LaunchedEffect
        withContext(Dispatchers.IO) {
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(path)
                retriever.getFrameAtTime(0)?.asImageBitmap()?.let { thumbnail = it }
            } catch (_: Exception) {
                // Extraction failed — thumbnail stays null; dark placeholder shown instead.
            } finally {
                retriever.release()
            }
        }
    }

    Column {
        Box(
            modifier = Modifier
                .size(200.dp)
                .clickable { showPlayer = !showPlayer },
            contentAlignment = Alignment.Center,
        ) {
            if (showPlayer && message.fileName != null) {
                // In-process VideoView — no FileProvider needed (same-process file access).
                AndroidView(
                    factory = { ctx ->
                        VideoView(ctx).apply {
                            setVideoPath(message.fileName)
                            setOnPreparedListener { it.start() }
                        }
                    },
                    modifier = Modifier.matchParentSize(),
                )
            } else {
                if (thumbnail != null) {
                    Image(
                        bitmap = thumbnail!!,
                        contentDescription = "Video thumbnail",
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.matchParentSize(),
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .matchParentSize()
                            .background(Color(0xFF1A1A1A)),
                    )
                }
                androidx.compose.material3.Icon(
                    imageVector = Icons.Filled.PlayCircle,
                    contentDescription = "Play video",
                    modifier = Modifier.size(48.dp),
                    tint = Color.White.copy(alpha = 0.85f),
                )
            }
        }
        // Caption — mirrors Flutter's SelectableText below the video when content is non-empty.
        if (message.content.isNotEmpty()) {
            Text(
                text = message.content,
                style = messageTextStyle,
                modifier = Modifier.padding(top = 4.dp),
            )
        }
    }
}

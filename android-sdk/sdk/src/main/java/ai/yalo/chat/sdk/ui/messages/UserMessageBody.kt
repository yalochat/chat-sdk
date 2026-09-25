// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.data.repositories.voice.VoicePlayback
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.ui.images.ImageMessageBody
import ai.yalo.chat.sdk.ui.voice.VoiceMessageBody
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ImageBitmap

/**
 * What the person using the app wrote.
 *
 * Shown exactly as they typed it. Markdown is left alone here on purpose, the
 * way the web SDK only runs what the assistant says through its renderer:
 * asterisks someone typed are asterisks they meant.
 */
@Composable
internal fun UserMessageBody(
    message: ChatMessage,
    modifier: Modifier = Modifier,
    playback: () -> VoicePlayback? = { null },
    onVoiceMessageToggled: () -> Unit = {},
    loadImage: suspend (ChatMessage) -> ImageBitmap? = { null },
) {
    when (message.type) {
        MessageType.Text -> Text(
            text = message.content,
            modifier = modifier,
            style = MaterialTheme.typography.bodyLarge,
        )

        MessageType.Voice -> VoiceMessageBody(
            message = message,
            playback = playback,
            onToggle = onVoiceMessageToggled,
            modifier = modifier,
        )

        MessageType.Image -> ImageMessageBody(
            message = message,
            loadImage = loadImage,
            modifier = modifier,
        )

        else -> UnsupportedMessageBody(modifier = modifier)
    }
}

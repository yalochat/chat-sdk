// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.images

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.ui.messages.UnsupportedMessageBody
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp

internal const val CHAT_IMAGE_MESSAGE_TAG: String = "yalo-chat-image-message"
internal const val CHAT_IMAGE_LOADING_TAG: String = "yalo-chat-image-loading"

/** Room for the spinner while a picture is on its way, so the bubble does not jump. */
private val PLACEHOLDER_SIZE = 72.dp

/**
 * How narrow a picture is allowed to be drawn.
 *
 * A portrait photograph fills the bubble, and anything taller than this is
 * drawn at this shape with room to spare rather than running off the screen.
 */
private const val MIN_ASPECT_RATIO = 0.75f

/**
 * A picture in the conversation, with its caption under it when it has one.
 *
 * [loadImage] reads the picture, from the device for one the person sent and
 * from the backend for one the channel sent. It is asked once per message, so
 * scrolling a conversation does not read the same picture over and over while
 * it is on screen.
 */
@Composable
internal fun ImageMessageBody(
    message: ChatMessage,
    loadImage: suspend (ChatMessage) -> ImageBitmap?,
    modifier: Modifier = Modifier,
) {
    if (message.image == null) {
        // The channel named an image message but sent nothing to show, which is
        // a hole in the conversation rather than something to draw a frame for.
        UnsupportedMessageBody(modifier = modifier)
        return
    }
    val state: ImageState by produceState<ImageState>(ImageState.Loading, message.id) {
        val read = loadImage(message)
        value = if (read == null) ImageState.Missing else ImageState.Shown(read)
    }
    val theme = currentChatTheme
    Column(
        modifier = modifier.testTag(CHAT_IMAGE_MESSAGE_TAG),
        verticalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        when (val current = state) {
            ImageState.Loading -> Box(
                modifier = Modifier
                    .size(PLACEHOLDER_SIZE)
                    .clip(theme.imageShape)
                    .testTag(CHAT_IMAGE_LOADING_TAG),
                contentAlignment = Alignment.Center,
            ) {
                CircularProgressIndicator()
            }

            is ImageState.Shown -> Image(
                bitmap = current.picture,
                contentDescription = stringResource(R.string.yalo_chat_image_message_description),
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(aspectRatioOf(current.picture))
                    .clip(theme.imageShape),
                contentScale = ContentScale.Crop,
            )

            // Nowhere to read the picture from, which is what a download that
            // got nowhere leaves behind.
            ImageState.Missing -> UnsupportedMessageBody()
        }
        if (message.content.isNotBlank()) {
            Text(text = message.content, style = MaterialTheme.typography.bodyLarge)
        }
    }
}

/** How far a picture has got on its way into the conversation. */
private sealed interface ImageState {

    data object Loading : ImageState

    data class Shown(val picture: ImageBitmap) : ImageState

    data object Missing : ImageState
}

/** How wide a picture is drawn against its height, kept off the extremes. */
internal fun aspectRatioOf(picture: ImageBitmap): Float {
    if (picture.width <= 0 || picture.height <= 0) {
        return 1f
    }
    return (picture.width.toFloat() / picture.height).coerceAtLeast(MIN_ASPECT_RATIO)
}

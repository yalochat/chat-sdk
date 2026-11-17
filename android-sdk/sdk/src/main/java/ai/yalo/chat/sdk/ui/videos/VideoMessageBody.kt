// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.videos

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.ui.images.aspectRatioOf
import ai.yalo.chat.sdk.ui.messages.UnsupportedMessageBody
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import ai.yalo.chat.sdk.ui.voice.formatDuration
import android.widget.MediaController
import android.widget.VideoView
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import java.io.File

internal const val CHAT_VIDEO_MESSAGE_TAG: String = "yalo-chat-video-message"
internal const val CHAT_VIDEO_LOADING_TAG: String = "yalo-chat-video-loading"
internal const val CHAT_VIDEO_PLAYER_TAG: String = "yalo-chat-video-player"

private val PLACEHOLDER_SIZE = 72.dp
private val PLAY_BUTTON_SIZE = 56.dp
private val SCRIM = Color.Black.copy(alpha = 0.55f)

/** A downloaded video and what its bubble shows before it is played. */
internal class VideoPreview(val file: File, val poster: ImageBitmap, val durationMillis: Long)

/**
 * A video the channel sent: its first frame with a play button and its length,
 * and its caption under it. Tapping it plays the video full screen.
 *
 * [loadVideo] downloads the video and reads its first frame. It is asked once
 * per message.
 */
@Composable
internal fun VideoMessageBody(
    message: ChatMessage,
    loadVideo: suspend (ChatMessage) -> VideoPreview?,
    modifier: Modifier = Modifier,
) {
    if (message.video == null) {
        UnsupportedMessageBody(modifier = modifier)
        return
    }
    val state: VideoState by produceState<VideoState>(VideoState.Loading, message.id) {
        val read = loadVideo(message)
        value = if (read == null) VideoState.Missing else VideoState.Shown(read)
    }
    var isPlaying by rememberSaveable(message.id) { mutableStateOf(false) }
    val theme = currentChatTheme
    Column(
        modifier = modifier.testTag(CHAT_VIDEO_MESSAGE_TAG),
        verticalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        when (val current = state) {
            VideoState.Loading -> Box(
                modifier = Modifier
                    .size(PLACEHOLDER_SIZE)
                    .clip(theme.imageShape)
                    .testTag(CHAT_VIDEO_LOADING_TAG),
                contentAlignment = Alignment.Center,
            ) {
                CircularProgressIndicator()
            }

            is VideoState.Shown -> VideoPoster(preview = current.preview, onPlay = { isPlaying = true })

            VideoState.Missing -> Text(
                text = stringResource(R.string.yalo_chat_video_unavailable),
                style = MaterialTheme.typography.bodyMedium,
            )
        }
        if (message.content.isNotBlank()) {
            Text(text = message.content, style = MaterialTheme.typography.bodyLarge)
        }
    }
    val shown = state as? VideoState.Shown
    if (isPlaying && shown != null) {
        VideoPlayer(file = shown.preview.file, onClose = { isPlaying = false })
    }
}

@Composable
private fun VideoPoster(preview: VideoPreview, onPlay: () -> Unit) {
    val description = stringResource(R.string.yalo_chat_play_video_description)
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(aspectRatioOf(preview.poster))
            .clip(currentChatTheme.imageShape)
            .clickable(onClickLabel = description, onClick = onPlay),
        contentAlignment = Alignment.Center,
    ) {
        Image(
            bitmap = preview.poster,
            contentDescription = null,
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop,
        )
        Box(
            modifier = Modifier
                .size(PLAY_BUTTON_SIZE)
                .background(SCRIM, CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.yalo_chat_ic_play),
                contentDescription = description,
                tint = Color.White,
            )
        }
        if (preview.durationMillis > 0) {
            Text(
                text = formatDuration(preview.durationMillis),
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(8.dp)
                    .background(SCRIM, RoundedCornerShape(4.dp))
                    .padding(horizontal = 6.dp, vertical = 2.dp),
                color = Color.White,
                style = MaterialTheme.typography.labelMedium,
            )
        }
    }
}

/** Plays [file] full screen with the system controls, from the start. */
@Composable
private fun VideoPlayer(file: File, onClose: () -> Unit) {
    Dialog(
        onDismissRequest = onClose,
        properties = DialogProperties(usePlatformDefaultWidth = false),
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black)
                .testTag(CHAT_VIDEO_PLAYER_TAG),
        ) {
            AndroidView(
                factory = { context ->
                    VideoView(context).apply {
                        setMediaController(MediaController(context).also { controller -> controller.setAnchorView(this) })
                        setOnPreparedListener { start() }
                        setVideoPath(file.absolutePath)
                    }
                },
                modifier = Modifier
                    .align(Alignment.Center)
                    .fillMaxWidth(),
                onRelease = { view -> view.stopPlayback() },
            )
            IconButton(
                onClick = onClose,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .safeDrawingPadding(),
            ) {
                Icon(
                    painter = painterResource(R.drawable.yalo_chat_ic_close),
                    contentDescription = stringResource(R.string.yalo_chat_close_video_description),
                    tint = Color.White,
                )
            }
        }
    }
}

private sealed interface VideoState {

    data object Loading : VideoState

    data class Shown(val preview: VideoPreview) : VideoState

    data object Missing : VideoState
}

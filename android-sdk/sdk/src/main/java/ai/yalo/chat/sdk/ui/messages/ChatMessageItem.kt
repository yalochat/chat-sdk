// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.YaloChatMessageAvatar
import ai.yalo.chat.sdk.data.repositories.voice.VoicePlayback
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.FeedbackRating
import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.domain.models.actions
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import ai.yalo.chat.sdk.ui.videos.VideoPreview
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.layout
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.hideFromAccessibility
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.roundToInt

internal const val CHAT_USER_MESSAGE_TAG: String = "yalo-chat-user-message"
internal const val CHAT_AGENT_MESSAGE_TAG: String = "yalo-chat-agent-message"
internal const val CHAT_USER_AVATAR_TAG: String = "yalo-chat-user-avatar"
internal const val CHAT_ASSISTANT_AVATAR_TAG: String = "yalo-chat-assistant-avatar"

/**
 * One message in the conversation, drawn for whoever sent it.
 *
 * [quickReplies] are the answers drawn under the message. They are passed in
 * rather than read off the message, because only the latest offer is live and
 * only the chat knows which message that is. The buttons a message keeps are
 * read off it instead, since those never stop being on offer.
 *
 * [isWelcome] centers an agent message and stacks its quick replies one per
 * line.
 *
 * [playback] is a lambda so that a voice note being listened to redraws its own
 * waveform rather than the conversation around it. [loadImage] hands back the
 * file a picture is in, and [loadVideo] a video with its first frame. Each is
 * asked only for the messages that carry one.
 *
 * [onFeedback] adds the thumbs up and thumbs down under an agent text message
 * the channel knows, and is null when the chat leaves them out.
 *
 * [userAvatar] and [assistantAvatar] are drawn beside the bubble of their side.
 * Without [showsAvatar] the room is kept but nothing is drawn, so the bubbles of
 * a run stay lined up.
 */
@Composable
internal fun ChatMessageItem(
    message: ChatMessage,
    modifier: Modifier = Modifier,
    quickReplies: List<MessageButton> = emptyList(),
    isWelcome: Boolean = false,
    onQuickReply: (String) -> Unit = {},
    onPostback: (ChatMessage, MessageButton) -> Unit = { _, _ -> },
    playback: () -> VoicePlayback? = { null },
    onVoiceMessageToggled: (ChatMessage) -> Unit = {},
    loadImage: suspend (ChatMessage) -> ImageBitmap? = { null },
    loadVideo: suspend (ChatMessage) -> VideoPreview? = { null },
    onFeedback: ((ChatMessage, FeedbackRating) -> Unit)? = null,
    userAvatar: YaloChatMessageAvatar = YaloChatMessageAvatar.None,
    assistantAvatar: YaloChatMessageAvatar = YaloChatMessageAvatar.None,
    showsAvatar: Boolean = true,
) {
    when (message.role) {
        MessageRole.User -> UserMessage(
            message = message,
            modifier = modifier,
            avatar = userAvatar,
            showsAvatar = showsAvatar,
            playback = playback,
            onVoiceMessageToggled = onVoiceMessageToggled,
            loadImage = loadImage,
        )

        MessageRole.Agent -> AgentMessage(
            message = message,
            quickReplies = quickReplies,
            isWelcome = isWelcome,
            onQuickReply = onQuickReply,
            onPostback = onPostback,
            modifier = modifier,
            playback = playback,
            onVoiceMessageToggled = onVoiceMessageToggled,
            loadImage = loadImage,
            loadVideo = loadVideo,
            onFeedback = onFeedback,
            avatar = if (isWelcome) YaloChatMessageAvatar.None else assistantAvatar,
            showsAvatar = showsAvatar,
        )
    }
}

/**
 * What the person using the app wrote.
 *
 * Sits against the end of the row in a bubble, with the corner nearest the
 * conversation squared off so a run of messages reads as one side speaking.
 */
@Composable
private fun UserMessage(
    message: ChatMessage,
    modifier: Modifier,
    avatar: YaloChatMessageAvatar,
    showsAvatar: Boolean,
    playback: () -> VoicePlayback?,
    onVoiceMessageToggled: (ChatMessage) -> Unit,
    loadImage: suspend (ChatMessage) -> ImageBitmap?,
) {
    val theme = currentChatTheme
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(AVATAR_GAP, Alignment.End),
        verticalAlignment = Alignment.Bottom,
    ) {
        Surface(
            modifier = Modifier
                .widthAtMost(USER_MESSAGE_WIDTH)
                .testTag(CHAT_USER_MESSAGE_TAG),
            shape = theme.userMessageShape,
            color = theme.userMessageBackground,
            contentColor = theme.onUserMessageBackground,
        ) {
            UserMessageBody(
                message = message,
                modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                playback = playback,
                onVoiceMessageToggled = { onVoiceMessageToggled(message) },
                loadImage = loadImage,
            )
        }
        MessageAvatar(
            avatar = avatar,
            visible = showsAvatar,
            background = theme.userAvatarBackground,
            contentColor = theme.onUserAvatarBackground,
            modifier = Modifier.testTag(CHAT_USER_AVATAR_TAG),
        )
    }
}

/**
 * What the channel answered.
 *
 * Left alone against the background rather than bubbled, following the web SDK,
 * so the reply reads as the conversation rather than as a card.
 */
@Composable
private fun AgentMessage(
    message: ChatMessage,
    quickReplies: List<MessageButton>,
    isWelcome: Boolean,
    onQuickReply: (String) -> Unit,
    onPostback: (ChatMessage, MessageButton) -> Unit,
    modifier: Modifier,
    playback: () -> VoicePlayback?,
    onVoiceMessageToggled: (ChatMessage) -> Unit,
    loadImage: suspend (ChatMessage) -> ImageBitmap?,
    loadVideo: suspend (ChatMessage) -> VideoPreview?,
    onFeedback: ((ChatMessage, FeedbackRating) -> Unit)?,
    avatar: YaloChatMessageAvatar,
    showsAvatar: Boolean,
) {
    val theme = currentChatTheme
    // The avatar sits beside the whole message, level with whatever comes last
    // under it: the bubble, its buttons, its quick replies or its rating.
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(AVATAR_GAP),
        verticalAlignment = Alignment.Bottom,
    ) {
        MessageAvatar(
            avatar = avatar,
            visible = showsAvatar,
            background = theme.assistantAvatarBackground,
            contentColor = theme.onAssistantAvatarBackground,
            modifier = Modifier.testTag(CHAT_ASSISTANT_AVATAR_TAG),
        )
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            horizontalAlignment = if (isWelcome) Alignment.CenterHorizontally else Alignment.Start,
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = if (isWelcome) Arrangement.Center else Arrangement.Start,
            ) {
                Surface(
                    modifier = Modifier
                        .widthAtMost(AGENT_MESSAGE_WIDTH)
                        .testTag(CHAT_AGENT_MESSAGE_TAG),
                    shape = theme.agentMessageShape,
                    color = theme.agentMessageBackground,
                    contentColor = theme.onAgentMessageBackground,
                    border = BorderStroke(1.dp, theme.agentMessageBorderColor),
                ) {
                    AgentMessageBody(
                        message = message,
                        modifier = Modifier.padding(theme.agentMessagePadding),
                        playback = playback,
                        onVoiceMessageToggled = { onVoiceMessageToggled(message) },
                        loadImage = loadImage,
                        loadVideo = loadVideo,
                        textAlign = if (isWelcome) TextAlign.Center else TextAlign.Unspecified,
                    )
                }
            }
            val actions: List<MessageButton> = message.actions
            if (actions.isNotEmpty()) {
                MessageButtons(
                    buttons = actions,
                    onButtonClick = { button -> onPostback(message, button) },
                    modifier = Modifier.widthAtMost(AGENT_MESSAGE_WIDTH),
                )
            }
            if (quickReplies.isNotEmpty()) {
                QuickReplies(replies = quickReplies, onReplyClick = onQuickReply, vertical = isWelcome)
            }
            if (onFeedback != null && message.type == MessageType.Text && message.wiId != null) {
                FeedbackButtons(
                    selected = message.feedback,
                    onRate = { rating -> onFeedback(message, rating) },
                )
            }
        }
    }
}

/**
 * What shows while a reply is being written, in the same bubble as an
 * assistant message, with the assistant avatar beside it so it reads as the
 * assistant writing. With [avatarBelow] the avatar sits below the bubble, the
 * way it does beside a message. With no avatar only the bubble is drawn.
 */
@Composable
internal fun AssistantWriting(
    avatar: YaloChatMessageAvatar,
    avatarBelow: Boolean,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    val theme = currentChatTheme
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(AVATAR_GAP),
        verticalAlignment = if (avatarBelow) Alignment.Bottom else Alignment.CenterVertically,
    ) {
        MessageAvatar(
            avatar = avatar,
            visible = true,
            background = theme.assistantAvatarBackground,
            contentColor = theme.onAssistantAvatarBackground,
            modifier = Modifier.testTag(CHAT_ASSISTANT_AVATAR_TAG),
        )
        Surface(
            modifier = if (avatarBelow && avatar != YaloChatMessageAvatar.None) {
                Modifier.padding(bottom = AVATAR_SIZE)
            } else {
                Modifier
            },
            shape = theme.agentMessageShape,
            color = theme.agentMessageBackground,
            contentColor = theme.onAgentMessageBackground,
            border = BorderStroke(1.dp, theme.agentMessageBorderColor),
        ) {
            Box(modifier = Modifier.padding(theme.agentMessagePadding)) {
                content()
            }
        }
    }
}

/**
 * The round picture a bubble comes from. Decorative, so screen readers skip it.
 * [YaloChatMessageAvatar.None] draws nothing, and when not [visible] only its
 * room is kept.
 */
@Composable
private fun MessageAvatar(
    avatar: YaloChatMessageAvatar,
    visible: Boolean,
    background: Color,
    contentColor: Color,
    modifier: Modifier = Modifier,
) {
    if (avatar == YaloChatMessageAvatar.None) {
        return
    }
    if (!visible) {
        Spacer(modifier = Modifier.size(AVATAR_SIZE))
        return
    }
    Box(
        modifier = modifier
            .size(AVATAR_SIZE)
            .clip(CircleShape)
            .background(background)
            .semantics { hideFromAccessibility() },
        contentAlignment = Alignment.Center,
    ) {
        when (avatar) {
            is YaloChatMessageAvatar.Image -> {
                val image = remember(avatar.image) { avatar.image.asImageBitmap() }
                Image(
                    bitmap = image,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.size(AVATAR_SIZE),
                )
            }
            is YaloChatMessageAvatar.Text -> {
                Text(
                    text = avatar.text.take(2),
                    color = contentColor,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                    maxLines = 1,
                )
            }
            YaloChatMessageAvatar.None -> {}
        }
    }
}

/**
 * Lets the content be as wide as it needs and no wider than [fraction] of the
 * room it was offered.
 *
 * A bubble hugs its text this way instead of stretching to a fixed share of the
 * row. `BoxWithConstraints` would answer the same question, but it subcomposes,
 * and this runs for every message in the list.
 */
private fun Modifier.widthAtMost(fraction: Float): Modifier = layout { measurable, constraints ->
    val ceiling = if (constraints.hasBoundedWidth) {
        (constraints.maxWidth * fraction).roundToInt()
    } else {
        constraints.maxWidth
    }
    val placeable = measurable.measure(constraints.copy(minWidth = 0, maxWidth = ceiling))
    layout(placeable.width, placeable.height) {
        placeable.placeRelative(0, 0)
    }
}

private const val USER_MESSAGE_WIDTH = 0.8f
private const val AGENT_MESSAGE_WIDTH = 0.9f
private val AVATAR_SIZE = 32.dp
private val AVATAR_GAP = 8.dp

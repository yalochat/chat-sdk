// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.data.repositories.voice.VoicePlayback
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.FeedbackRating
import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.quickReplies
import ai.yalo.chat.sdk.ui.messages.ChatMessageItem
import ai.yalo.chat.sdk.ui.messages.TypingIndicator
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import android.view.View
import androidx.compose.animation.core.tween
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

internal const val CHAT_MESSAGE_LIST_TAG: String = "yalo-chat-message-list"
internal const val CHAT_WELCOME_AVATAR_TAG: String = "yalo-chat-welcome-avatar"

private const val TYPING_INDICATOR_KEY = "yalo-chat-typing-indicator-item"
private const val WELCOME_AVATAR_KEY = "yalo-chat-welcome-avatar-item"

/**
 * How long a message takes to fade in, whoever sent it.
 *
 * Short enough that a message never feels held back, and long enough that one
 * arriving is noticed rather than found already there.
 */
private const val MESSAGE_FADE_MILLIS = 220

/**
 * The conversation, newest message at the bottom.
 *
 * [quickRepliesMessageId] names the message whose answers are drawn under it,
 * and is null when the chat shows them in a bar of their own instead.
 * [isWelcome] draws the messages centered, with one quick reply per line, and
 * [avatar] centered above them. [onFeedback] is null when the chat leaves the
 * thumbs up and thumbs down out. Only replies after the person's first message
 * can be rated, so the welcome message never is.
 */
@Composable
internal fun ChatMessageList(
    messages: List<ChatMessage>,
    modifier: Modifier = Modifier,
    isWaitingForReply: Boolean = false,
    quickRepliesMessageId: Long? = null,
    isWelcome: Boolean = false,
    avatar: (@Composable () -> Unit)? = null,
    onQuickReply: (String) -> Unit = {},
    onPostback: (ChatMessage, MessageButton) -> Unit = { _, _ -> },
    playback: () -> VoicePlayback? = { null },
    onVoiceMessageToggled: (ChatMessage) -> Unit = {},
    loadImage: suspend (ChatMessage) -> ImageBitmap? = { null },
    onFeedback: ((ChatMessage, FeedbackRating) -> Unit)? = null,
    listState: LazyListState = rememberLazyListState(),
) {
    val theme = currentChatTheme
    val view = LocalView.current

    // Index 0 is the newest message, since the layout is reversed. Keying on it
    // means the jump happens when the conversation actually gains a message,
    // not on every recomposition.
    val newest: Long? = messages.firstOrNull()?.id
    val firstUserMessageIndex = messages.indexOfLast { it.role == MessageRole.User }
    LaunchedEffect(newest) {
        if (messages.isNotEmpty()) {
            listState.animateScrollToItem(0)
        }
    }

    Surface(
        modifier = modifier.testTag(CHAT_MESSAGE_LIST_TAG),
        color = theme.background,
        contentColor = theme.onBackground,
    ) {
        // The newest message comes first and the layout is reversed, so the
        // conversation sits at the bottom and stays there as it grows.
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .claimDrags(view),
            state = listState,
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            reverseLayout = true,
        ) {
            if (isWaitingForReply) {
                item(key = TYPING_INDICATOR_KEY) {
                    TypingIndicator()
                }
            }
            itemsIndexed(
                items = messages,
                key = { _, message -> message.id ?: message.timestamp },
            ) { index, message ->
                ChatMessageItem(
                    message = message,
                    // A message fades in where it lands. Rows do not slide: in a
                    // reversed list pinned to the top, a row that grows, such as
                    // a picture that finished loading, would slide down from above.
                    modifier = Modifier.animateItem(
                        fadeInSpec = tween(durationMillis = MESSAGE_FADE_MILLIS),
                        placementSpec = null,
                    ),
                    quickReplies = if (quickRepliesMessageId != null && message.id == quickRepliesMessageId) {
                        message.quickReplies
                    } else {
                        emptyList()
                    },
                    isWelcome = isWelcome,
                    onQuickReply = onQuickReply,
                    onPostback = onPostback,
                    playback = playback,
                    onVoiceMessageToggled = onVoiceMessageToggled,
                    loadImage = loadImage,
                    onFeedback = onFeedback.takeIf { index < firstUserMessageIndex },
                )
            }
            // Last in a reversed list, so it sits above the welcome message.
            if (isWelcome && avatar != null) {
                item(key = WELCOME_AVATAR_KEY) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .animateItem(
                                fadeInSpec = tween(durationMillis = MESSAGE_FADE_MILLIS),
                                placementSpec = null,
                            )
                            .testTag(CHAT_WELCOME_AVATAR_TAG),
                        contentAlignment = Alignment.Center,
                    ) {
                        avatar()
                    }
                }
            }
        }
    }
}

/**
 * Keeps every drag on the list away from a parent that drags too, such as a
 * bottom sheet, which would otherwise take it before the list scrolls.
 */
private fun Modifier.claimDrags(view: View): Modifier =
    pointerInput(view) {
        awaitEachGesture {
            awaitFirstDown(requireUnconsumed = false, pass = PointerEventPass.Initial)
            view.parent?.requestDisallowInterceptTouchEvent(true)
        }
    }

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.layout
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt

internal const val CHAT_USER_MESSAGE_TAG: String = "yalo-chat-user-message"
internal const val CHAT_AGENT_MESSAGE_TAG: String = "yalo-chat-agent-message"

/** One message in the conversation, drawn for whoever sent it. */
@Composable
internal fun ChatMessageItem(message: ChatMessage, modifier: Modifier = Modifier) {
    when (message.role) {
        MessageRole.User -> UserMessage(message = message, modifier = modifier)
        MessageRole.Agent -> AgentMessage(message = message, modifier = modifier)
    }
}

/**
 * What the person using the app wrote.
 *
 * Sits against the end of the row in a bubble, with the corner nearest the
 * conversation squared off so a run of messages reads as one side speaking.
 */
@Composable
private fun UserMessage(message: ChatMessage, modifier: Modifier = Modifier) {
    val theme = currentChatTheme
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.End,
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
            )
        }
    }
}

/**
 * What the channel answered.
 *
 * Left alone against the background rather than bubbled, following the web SDK,
 * so the reply reads as the conversation rather than as a card.
 */
@Composable
private fun AgentMessage(message: ChatMessage, modifier: Modifier = Modifier) {
    val theme = currentChatTheme
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.Start,
    ) {
        Surface(
            modifier = Modifier
                .widthAtMost(AGENT_MESSAGE_WIDTH)
                .testTag(CHAT_AGENT_MESSAGE_TAG),
            shape = theme.agentMessageShape,
            color = theme.agentMessageBackground,
            contentColor = theme.onAgentMessageBackground,
        ) {
            AgentMessageBody(message = message)
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

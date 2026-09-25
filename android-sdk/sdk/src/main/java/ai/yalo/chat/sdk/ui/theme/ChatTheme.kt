// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.dp

/**
 * How the chat paints itself.
 *
 * Every value defaults to the host `MaterialTheme`, so a chat dropped into an
 * app follows that app's light and dark schemes with no setup. Override only
 * what you need:
 *
 * ```
 * Chat(
 *     client,
 *     theme = ChatTheme.default().copy(
 *         headerBackground = Color.Red,
 *         inputShape = RoundedCornerShape(8.dp),
 *     ),
 * )
 * ```
 */
@Immutable
public data class ChatTheme(
    public val background: Color,
    public val onBackground: Color,
    public val headerBackground: Color,
    public val onHeaderBackground: Color,
    public val footerBackground: Color,
    public val onFooterBackground: Color,
    public val userMessageBackground: Color,
    public val onUserMessageBackground: Color,
    public val agentMessageBackground: Color,
    public val onAgentMessageBackground: Color,
    public val typingIndicatorDotColor: Color,
    public val linkColor: Color,
    public val quickReplyBackground: Color,
    public val onQuickReplyBackground: Color,
    public val quickReplyBorderColor: Color,
    public val inputShape: Shape,
    public val userMessageShape: Shape,
    public val agentMessageShape: Shape,
    public val imageShape: Shape,
    public val quickReplyShape: Shape,
) {

    public companion object {

        private val BUBBLE_CORNER = 18.dp
        private val BUBBLE_TAIL_CORNER = 4.dp
        private val IMAGE_CORNER = 12.dp
        private val CHIP_CORNER = 18.dp

        /** The theme derived from the host `MaterialTheme`. */
        @Composable
        @ReadOnlyComposable
        public fun default(): ChatTheme = ChatTheme(
            background = MaterialTheme.colorScheme.surface,
            onBackground = MaterialTheme.colorScheme.onSurface,
            headerBackground = MaterialTheme.colorScheme.surfaceContainer,
            onHeaderBackground = MaterialTheme.colorScheme.onSurface,
            footerBackground = MaterialTheme.colorScheme.surfaceContainer,
            onFooterBackground = MaterialTheme.colorScheme.onSurface,
            userMessageBackground = MaterialTheme.colorScheme.surfaceContainerHigh,
            onUserMessageBackground = MaterialTheme.colorScheme.onSurface,
            // The web SDK leaves what the agent says unbubbled, so it reads as
            // the conversation itself rather than as a reply.
            agentMessageBackground = Color.Transparent,
            onAgentMessageBackground = MaterialTheme.colorScheme.onSurface,
            typingIndicatorDotColor = MaterialTheme.colorScheme.onSurfaceVariant,
            linkColor = MaterialTheme.colorScheme.primary,
            // Outlined rather than filled, the way the web SDK draws them, so a
            // quick reply reads as an offer rather than as something said.
            quickReplyBackground = Color.Transparent,
            onQuickReplyBackground = MaterialTheme.colorScheme.onSurface,
            quickReplyBorderColor = MaterialTheme.colorScheme.outline,
            inputShape = MaterialTheme.shapes.extraLarge,
            userMessageShape = RoundedCornerShape(
                topStart = BUBBLE_CORNER,
                topEnd = BUBBLE_CORNER,
                bottomEnd = BUBBLE_TAIL_CORNER,
                bottomStart = BUBBLE_CORNER,
            ),
            agentMessageShape = RectangleShape,
            imageShape = RoundedCornerShape(IMAGE_CORNER),
            quickReplyShape = RoundedCornerShape(CHIP_CORNER),
        )
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
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
 *         fontFamily = FontFamily(Font(R.font.brand_regular)),
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
    public val assistantMessageBackground: Color,
    public val onAssistantMessageBackground: Color,
    public val assistantMessageBorderColor: Color,
    public val typingIndicatorDotColor: Color,
    public val linkColor: Color,
    public val quickReplyBackground: Color,
    public val onQuickReplyBackground: Color,
    public val quickReplyBorderColor: Color,
    public val postbackBackground: Color,
    public val onPostbackBackground: Color,
    public val postbackBorderColor: Color,
    public val selectedPostbackBackground: Color,
    public val onSelectedPostbackBackground: Color,
    public val inputBorderColor: Color,
    public val inputFieldBorderColor: Color,
    public val inputBackground: Color,
    public val sendButtonBackground: Color,
    public val onSendButtonBackground: Color,
    public val inputShape: Shape,
    public val userMessageShape: Shape,
    public val assistantMessageShape: Shape,
    public val imageShape: Shape,
    public val quickReplyShape: Shape,
    public val postbackShape: Shape,
    public val inputScrollbarColor: Color = Color.Unspecified,
    public val inputScrollbarWidth: Dp = 3.dp,
    public val userAvatarBackground: Color = Color.Unspecified,
    public val onUserAvatarBackground: Color = Color.Unspecified,
    public val assistantAvatarBackground: Color = Color.Unspecified,
    public val onAssistantAvatarBackground: Color = Color.Unspecified,
    public val fontFamily: FontFamily? = null,
    public val messageTailSize: DpSize = DpSize.Zero,
    public val timestampColor: Color = Color.Unspecified,
    public val selectedPostbackBorderColor: Color = Color.Unspecified,
    public val disabledSendButtonBackground: Color = Color.Unspecified,
    public val onDisabledSendButtonBackground: Color = Color.Unspecified,
    public val inputPlaceholderColor: Color = Color.Unspecified,
    public val userMessagePadding: PaddingValues = PaddingValues(horizontal = 12.dp, vertical = 8.dp),
    public val assistantMessagePadding: PaddingValues = PaddingValues(0.dp),
    public val feedbackButtonColor: Color = Color.Unspecified,
) {

    @Deprecated("Use assistantMessageBackground.", ReplaceWith("assistantMessageBackground"))
    public val agentMessageBackground: Color
        get() = assistantMessageBackground

    @Deprecated("Use onAssistantMessageBackground.", ReplaceWith("onAssistantMessageBackground"))
    public val onAgentMessageBackground: Color
        get() = onAssistantMessageBackground

    @Deprecated("Use assistantMessageShape.", ReplaceWith("assistantMessageShape"))
    public val agentMessageShape: Shape
        get() = assistantMessageShape

    @Deprecated("Use assistantMessageBorderColor.", ReplaceWith("assistantMessageBorderColor"))
    public val agentMessageBorderColor: Color
        get() = assistantMessageBorderColor

    public companion object {

        private val BUBBLE_CORNER = 18.dp
        private val BUBBLE_TAIL_CORNER = 4.dp
        private val IMAGE_CORNER = 12.dp
        private val CHIP_CORNER = 18.dp
        private val BUTTON_CORNER = 8.dp

        /**
         * The theme derived from the host `MaterialTheme`. Its [fontFamily] is
         * null, so text keeps the host typography.
         */
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
            assistantMessageBackground = Color.Transparent,
            onAssistantMessageBackground = MaterialTheme.colorScheme.onSurface,
            assistantMessageBorderColor = Color.Transparent,
            typingIndicatorDotColor = MaterialTheme.colorScheme.onSurfaceVariant,
            linkColor = MaterialTheme.colorScheme.primary,
            // Outlined rather than filled, the way the web SDK draws them, so a
            // quick reply reads as an offer rather than as something said.
            quickReplyBackground = Color.Transparent,
            onQuickReplyBackground = MaterialTheme.colorScheme.onSurface,
            quickReplyBorderColor = MaterialTheme.colorScheme.outline,
            // A button that stays is drawn like a quick reply rather than like
            // something said, since tapping it does the same thing.
            postbackBackground = Color.Transparent,
            onPostbackBackground = MaterialTheme.colorScheme.onSurface,
            postbackBorderColor = MaterialTheme.colorScheme.outline,
            selectedPostbackBackground = MaterialTheme.colorScheme.secondaryContainer,
            onSelectedPostbackBackground = MaterialTheme.colorScheme.onSecondaryContainer,
            inputBorderColor = MaterialTheme.colorScheme.outline,
            // The place text is typed and the plus beside it share the one
            // outline around them, so the field draws none of its own.
            inputFieldBorderColor = Color.Transparent,
            inputBackground = Color.Transparent,
            sendButtonBackground = MaterialTheme.colorScheme.primary,
            onSendButtonBackground = MaterialTheme.colorScheme.onPrimary,
            inputShape = MaterialTheme.shapes.extraLarge,
            userMessageShape = RoundedCornerShape(
                topStart = BUBBLE_CORNER,
                topEnd = BUBBLE_CORNER,
                bottomEnd = BUBBLE_TAIL_CORNER,
                bottomStart = BUBBLE_CORNER,
            ),
            assistantMessageShape = RectangleShape,
            imageShape = RoundedCornerShape(IMAGE_CORNER),
            quickReplyShape = RoundedCornerShape(CHIP_CORNER),
            postbackShape = RoundedCornerShape(BUTTON_CORNER),
            // The thumb that shows the typed text runs past the input, as faint
            // as the line around the input so it reads as part of it.
            inputScrollbarColor = MaterialTheme.colorScheme.outline,
            inputScrollbarWidth = 3.dp,
            userAvatarBackground = MaterialTheme.colorScheme.secondaryContainer,
            onUserAvatarBackground = MaterialTheme.colorScheme.onSecondaryContainer,
            assistantAvatarBackground = MaterialTheme.colorScheme.primaryContainer,
            onAssistantAvatarBackground = MaterialTheme.colorScheme.onPrimaryContainer,
            timestampColor = MaterialTheme.colorScheme.onSurfaceVariant,
            inputPlaceholderColor = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}


// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.theme

import androidx.compose.foundation.shape.CornerBasedShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.ColorScheme
import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Full theme contract for the Yalo Chat SDK — mirrors Flutter SDK's ChatTheme.
 *
 * All properties have defaults matching the Flutter SDK's built-in light theme, so
 * partial construction works out of the box:
 * ```
 * ChatTheme(sendButtonColor = Color(0xFF00AA00))
 * ```
 * For larger overrides, use [ChatTheme.fromMaterialTheme] to inherit the host app's
 * Material color scheme automatically.
 *
 * Only properties that are consumed by current SDK composables are included here.
 * Theme properties for future composables (product carousel, quick reply, etc.) will
 * be added when those composables are implemented.
 */
@Immutable
data class ChatTheme(
    // ── Colors ────────────────────────────────────────────────────────────────
    val backgroundColor: Color = Color(0xFFFFFFFF),
    val appBarBackgroundColor: Color = Color(0xFFF1F5FC),
    /** Background of the user's outgoing message bubble. */
    val userBubbleColor: Color = Color(0xFFF9FAFC),
    /** Background of the agent's incoming message bubble. */
    val agentBubbleColor: Color = Color(0xFFFFFFFF),
    val inputTextFieldColor: Color = Color(0xFFFFFFFF),
    val inputTextFieldBorderColor: Color = Color(0xFFE8E8E8),
    val sendButtonColor: Color = Color(0xFF2207F1),
    /** Waveform bar color during live recording. */
    val waveColor: Color = Color(0xFF5C5EE8),
    val actionIconColor: Color = Color(0xFF000000),
    val cancelRecordingIconColor: Color = Color(0xFF7C8086),
    /** Close icon color in ImagePreview. Defaults to white for contrast on the dark scrim. */
    val closeModalIconColor: Color = Color(0xFFFFFFFF),
    val playAudioIconColor: Color = Color(0xFF7C8086),
    val pauseAudioIconColor: Color = Color(0xFF7C8086),
    val attachIconColor: Color = Color(0xFF7C8086),
    val imagePlaceholderBackgroundColor: Color = Color(0xFFF9FAFC),
    // ── Text styles ───────────────────────────────────────────────────────────
    val userMessageTextStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontSize = 16.sp),
    val assistantMessageTextStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontSize = 16.sp),
    val modalHeaderStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontSize = 18.sp, fontWeight = FontWeight.Bold),
    val hintTextStyle: TextStyle = TextStyle(color = Color(0xFFBEBEBE)),
    val timerTextStyle: TextStyle = TextStyle(color = Color(0xFF7C8086)),
    // ── Shape ─────────────────────────────────────────────────────────────────
    /**
     * Corner radius applied to both user and agent message bubbles.
     * Declared as [CornerBasedShape] (covers [RoundedCornerShape], [CutCornerShape], etc.)
     * so that Compose's stability analysis can verify the field is immutable.
     */
    val bubbleShape: CornerBasedShape = RoundedCornerShape(12.dp),
    // ── Icons ─────────────────────────────────────────────────────────────────
    val sendButtonIcon: ImageVector = Icons.AutoMirrored.Filled.Send,
    val recordAudioIcon: ImageVector = Icons.Filled.Mic,
    val cancelRecordingIcon: ImageVector = Icons.Filled.Close,
    val closeModalIcon: ImageVector = Icons.Filled.Close,
    val playAudioIcon: ImageVector = Icons.Filled.PlayArrow,
    val pauseAudioIcon: ImageVector = Icons.Filled.Pause,
    /** Opens the attachment picker (gallery / camera). */
    val attachIcon: ImageVector = Icons.Filled.Add,
) {
    companion object {
        /**
         * Default theme matching the Flutter SDK's built-in light theme values.
         * Equivalent to `ChatTheme()` — provided as a named constant for readability.
         */
        val Default = ChatTheme()

        /**
         * Derives a ChatTheme from the host app's Material [colorScheme], using the same
         * color-slot mapping as Flutter SDK's ChatTheme.fromThemeData. Properties not
         * covered by Material color tokens fall back to [Default] values.
         */
        fun fromMaterialTheme(colorScheme: ColorScheme): ChatTheme = Default.copy(
            backgroundColor = colorScheme.surface,
            appBarBackgroundColor = colorScheme.surfaceContainer,
            sendButtonColor = colorScheme.primary,
            waveColor = colorScheme.primary,
            actionIconColor = colorScheme.onSurface,
            userMessageTextStyle = TextStyle(color = colorScheme.onSurface, fontSize = 16.sp),
            assistantMessageTextStyle = TextStyle(color = colorScheme.onSurface, fontSize = 16.sp),
            hintTextStyle = TextStyle(color = colorScheme.onSurfaceVariant.copy(alpha = 0.6f)),
            inputTextFieldColor = colorScheme.surface,
            inputTextFieldBorderColor = colorScheme.outline,
            cancelRecordingIconColor = colorScheme.onSurfaceVariant,
            attachIconColor = colorScheme.onSurfaceVariant,
            playAudioIconColor = colorScheme.onSurfaceVariant,
            pauseAudioIconColor = colorScheme.onSurfaceVariant,
            userBubbleColor = colorScheme.surfaceVariant,
            agentBubbleColor = colorScheme.surfaceContainerHighest,
            imagePlaceholderBackgroundColor = colorScheme.surfaceVariant,
        )
    }
}

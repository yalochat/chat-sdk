// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material.icons.filled.Storefront
import androidx.compose.material.icons.filled.Toll
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.InsertPhoto
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.material3.ColorScheme
import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
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
 */
@Immutable
data class ChatTheme(
    // ── Colors ────────────────────────────────────────────────────────────────
    val backgroundColor: Color = Color(0xFFFFFFFF),
    val cardBackgroundColor: Color = Color(0xFFFFFFFF),
    val cardBorderColor: Color = Color(0xFFDDE4EC),
    val appBarBackgroundColor: Color = Color(0xFFF1F5FC),
    /** Background of the user's outgoing message bubble. */
    val userBubbleColor: Color = Color(0xFFF9FAFC),
    /** Background of the agent's incoming message bubble. */
    val agentBubbleColor: Color = Color(0xFFFFFFFF),
    val inputTextFieldColor: Color = Color(0xFFFFFFFF),
    val inputTextFieldBorderColor: Color = Color(0xFFE8E8E8),
    val sendButtonColor: Color = Color(0xFF2207F1),
    val sendButtonForegroundColor: Color = Color(0xFFEFF4FF),
    /** Waveform bar color during live recording. */
    val waveColor: Color = Color(0xFF5C5EE8),
    val attachmentPickerBackgroundColor: Color = Color(0xFFFFFFFF),
    val actionIconColor: Color = Color(0xFF000000),
    val cancelRecordingIconColor: Color = Color(0xFF7C8086),
    val closeModalIconColor: Color = Color(0xFF7C8086),
    val playAudioIconColor: Color = Color(0xFF7C8086),
    val pauseAudioIconColor: Color = Color(0xFF7C8086),
    val attachIconColor: Color = Color(0xFF7C8086),
    val cameraIconColor: Color = Color(0xFF7C8086),
    val galleryIconColor: Color = Color(0xFF7C8086),
    val trashIconColor: Color = Color(0xFFFFFFFF),
    val currencyIconColor: Color = Color(0xFF186C54),
    val numericControlIconColor: Color = Color(0xFF7C8086),
    val imagePlaceholderBackgroundColor: Color = Color(0xFFF9FAFC),
    val imagePlaceholderIconColor: Color = Color(0xFF7C8086),
    val productPriceBackgroundColor: Color = Color(0xFFECFDF5),
    val pricePerSubunitColor: Color = Color(0xFF334155),
    val pickerButtonBorderColor: Color = Color(0xFFE6E6E6),
    val quickReplyColor: Color = Color(0xFFF9FAFC),
    val quickReplyBorderColor: Color = Color(0xFFECEDEF),
    // ── Text styles ───────────────────────────────────────────────────────────
    val quickReplyStyle: TextStyle = TextStyle(color = Color(0xFF000000)),
    val userMessageTextStyle: TextStyle = TextStyle(color = Color(0xFF000000)),
    val assistantMessageTextStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontSize = 18.sp),
    val modalHeaderStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontSize = 18.sp, fontWeight = FontWeight.Bold),
    val hintTextStyle: TextStyle = TextStyle(color = Color(0xFFBEBEBE)),
    val timerTextStyle: TextStyle = TextStyle(color = Color(0xFF7C8086)),
    val productTitleStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontSize = 16.sp, fontWeight = FontWeight.Bold),
    val productSubunitsStyle: TextStyle = TextStyle(color = Color(0xFF334155), fontSize = 14.sp),
    val productPriceStyle: TextStyle = TextStyle(color = Color(0xFF186C54), fontWeight = FontWeight.Bold),
    val productSalePriceStrikeStyle: TextStyle = TextStyle(color = Color(0xFF7C8086), textDecoration = TextDecoration.LineThrough),
    val pricePerSubunitStyle: TextStyle = TextStyle(color = Color(0xFF334155)),
    val expandControlsStyle: TextStyle = TextStyle(color = Color(0xFF2207F1)),
    // ── Shapes ────────────────────────────────────────────────────────────────
    /** Corner radius applied to both user and agent message bubbles. */
    val bubbleShape: Shape = RoundedCornerShape(12.dp),
    // ── Icons ─────────────────────────────────────────────────────────────────
    val sendButtonIcon: ImageVector = Icons.AutoMirrored.Filled.Send,
    val recordAudioIcon: ImageVector = Icons.Filled.Mic,
    val shopIcon: ImageVector = Icons.Filled.Storefront,
    val cartIcon: ImageVector = Icons.Outlined.ShoppingCart,
    val cancelRecordingIcon: ImageVector = Icons.Filled.Close,
    val closeModalIcon: ImageVector = Icons.Filled.Close,
    val playAudioIcon: ImageVector = Icons.Filled.PlayArrow,
    val pauseAudioIcon: ImageVector = Icons.Filled.Pause,
    /** Opens the attachment picker (gallery / camera). Different from [addIcon], which increments product quantity. */
    val attachIcon: ImageVector = Icons.Filled.Add,
    val cameraIcon: ImageVector = Icons.Filled.PhotoCamera,
    val galleryIcon: ImageVector = Icons.Outlined.InsertPhoto,
    val trashIcon: ImageVector = Icons.Outlined.Delete,
    val imagePlaceholderIcon: ImageVector = Icons.Filled.Image,
    val currencyIcon: ImageVector = Icons.Filled.Toll,
    /** Increments product quantity in product carousel messages. Different from [attachIcon]. */
    val addIcon: ImageVector = Icons.Filled.Add,
    val removeIcon: ImageVector = Icons.Filled.Remove,
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
            cardBackgroundColor = colorScheme.surface,
            inputTextFieldColor = colorScheme.surface,
            attachmentPickerBackgroundColor = colorScheme.surface,
            appBarBackgroundColor = colorScheme.surfaceContainer,
            sendButtonColor = colorScheme.primary,
            waveColor = colorScheme.primary,
            sendButtonForegroundColor = colorScheme.onPrimary,
            actionIconColor = colorScheme.onSurface,
            userMessageTextStyle = TextStyle(color = colorScheme.onSurface),
            assistantMessageTextStyle = TextStyle(color = colorScheme.onSurface, fontSize = 18.sp),
            inputTextFieldBorderColor = colorScheme.outline,
            cardBorderColor = colorScheme.outline,
            pickerButtonBorderColor = colorScheme.outline,
            quickReplyBorderColor = colorScheme.outline,
            cancelRecordingIconColor = colorScheme.onSurfaceVariant,
            attachIconColor = colorScheme.onSurfaceVariant,
            cameraIconColor = colorScheme.onSurfaceVariant,
            galleryIconColor = colorScheme.onSurfaceVariant,
            playAudioIconColor = colorScheme.onSurfaceVariant,
            pauseAudioIconColor = colorScheme.onSurfaceVariant,
            numericControlIconColor = colorScheme.onSurfaceVariant,
            imagePlaceholderIconColor = colorScheme.onSurfaceVariant,
            pricePerSubunitColor = colorScheme.onSurfaceVariant,
            userBubbleColor = colorScheme.surfaceVariant,
            agentBubbleColor = colorScheme.surfaceContainerHighest,
            quickReplyColor = colorScheme.surfaceVariant,
            imagePlaceholderBackgroundColor = colorScheme.surfaceVariant,
            productPriceBackgroundColor = colorScheme.tertiaryContainer,
            productPriceStyle = TextStyle(color = colorScheme.onTertiaryContainer, fontWeight = FontWeight.Bold),
        )
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.theme

import androidx.compose.foundation.shape.CornerBasedShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.AttachMoney
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.filled.Storefront
import androidx.compose.material3.ColorScheme
import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color
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
    val appBarBackgroundColor: Color = Color(0xFFF1F5FC),
    /** Background of the user's outgoing message bubble. */
    val userBubbleColor: Color = Color(0xFFF9FAFC),
    /** Background of the agent's incoming message bubble. */
    val agentBubbleColor: Color = Color(0xFFFFFFFF),
    val inputTextFieldColor: Color = Color(0xFFFFFFFF),
    val inputTextFieldBorderColor: Color = Color(0xFFE8E8E8),
    val sendButtonColor: Color = Color(0xFF2207F1),
    /** Foreground (icon/text) color on the send button. */
    val sendButtonForegroundColor: Color = Color(0xFFFFFFFF),
    /** Waveform bar color during live recording. */
    val waveColor: Color = Color(0xFF5C5EE8),
    val actionIconColor: Color = Color(0xFF000000),
    val cancelRecordingIconColor: Color = Color(0xFF7C8086),
    /** Close icon color in ImagePreview. Defaults to white for contrast on the dark scrim. */
    val closeModalIconColor: Color = Color(0xFFFFFFFF),
    val playAudioIconColor: Color = Color(0xFF7C8086),
    val pauseAudioIconColor: Color = Color(0xFF7C8086),
    val attachIconColor: Color = Color(0xFF7C8086),
    val cameraIconColor: Color = Color(0xFF7C8086),
    val galleryIconColor: Color = Color(0xFF7C8086),
    val trashIconColor: Color = Color(0xFF7C8086),
    val currencyIconColor: Color = Color(0xFF2207F1),
    val numericControlIconColor: Color = Color(0xFF7C8086),
    val imagePlaceholderIconColor: Color = Color(0xFF7C8086),
    val imagePlaceholderBackgroundColor: Color = Color(0xFFF9FAFC),
    /** Background of product cards in the product carousel. */
    val cardBackgroundColor: Color = Color(0xFFFFFFFF),
    /** Border color of product cards. */
    val cardBorderColor: Color = Color(0xFFE8E8E8),
    /** Background of the attachment picker bottom sheet. */
    val attachmentPickerBackgroundColor: Color = Color(0xFFF1F5FC),
    /** Background color for sale/discount price chips on product cards. */
    val productPriceBackgroundColor: Color = Color(0xFFEEF0FF),
    /** Text color for the per-subunit price label on product cards. */
    val pricePerSubunitColor: Color = Color(0xFF7C8086),
    /** Border color of the picker buttons in the attachment sheet. */
    val pickerButtonBorderColor: Color = Color(0xFFE8E8E8),
    /** Background of quick reply chip buttons. */
    val quickReplyColor: Color = Color(0xFFF9FAFC),
    /** Border color of quick reply chip buttons. */
    val quickReplyBorderColor: Color = Color(0xFFE8E8E8),
    // Buttons message — port of Flutter SdkColors.buttonsMessage* light defaults.
    /** Background of buttons in a ButtonsMessage bubble (transparent by default). */
    val buttonsMessageButtonColor: Color = Color(0x00000000),
    /** Border color of buttons in a ButtonsMessage bubble. */
    val buttonsMessageButtonBorderColor: Color = Color(0xFFDDE4EC),
    /** Foreground (text/icon) color of buttons in a ButtonsMessage bubble. */
    val buttonsMessageButtonForegroundColor: Color = Color(0xFF111111),
    // CTA message — port of Flutter SdkColors.ctaButton* light defaults.
    /** Background of CTA buttons (transparent by default). */
    val ctaButtonColor: Color = Color(0x00000000),
    /** Border color of CTA buttons. */
    val ctaButtonBorderColor: Color = Color(0xFFDDE4EC),
    /** Foreground (text/icon) color of CTA buttons. */
    val ctaButtonForegroundColor: Color = Color(0xFF111111),
    // ── Text styles ───────────────────────────────────────────────────────────
    val userMessageTextStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontSize = 16.sp),
    val assistantMessageTextStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontSize = 16.sp),
    val modalHeaderStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontSize = 18.sp, fontWeight = FontWeight.Bold),
    val hintTextStyle: TextStyle = TextStyle(color = Color(0xFFBEBEBE)),
    val timerTextStyle: TextStyle = TextStyle(color = Color(0xFF7C8086)),
    val quickReplyStyle: TextStyle = TextStyle(color = Color(0xFF000000)),
    // Port of Flutter ChatTheme.messageHeaderStyle / messageFooterStyle.
    /** Bold header text shown above the body of a buttons or CTA message. */
    val messageHeaderStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontWeight = FontWeight.Bold),
    /** Subdued footer text shown below the body of a buttons or CTA message. */
    val messageFooterStyle: TextStyle = TextStyle(color = Color(0xFF7C8086), fontSize = 12.sp),
    /** Text style for labels inside CTA buttons. */
    val ctaButtonTextStyle: TextStyle = TextStyle(color = Color(0xFF111111)),
    /** Text style for labels inside ButtonsMessage buttons. */
    val buttonsMessageButtonTextStyle: TextStyle = TextStyle(color = Color(0xFF111111)),
    val productTitleStyle: TextStyle = TextStyle(color = Color(0xFF000000), fontSize = 16.sp, fontWeight = FontWeight.Bold),
    val productSubunitsStyle: TextStyle = TextStyle(color = Color(0xFF7C8086), fontSize = 12.sp),
    val productPriceStyle: TextStyle = TextStyle(color = Color(0xFF2207F1), fontWeight = FontWeight.Bold),
    val productSalePriceStrikeStyle: TextStyle = TextStyle(color = Color(0xFFBEBEBE), textDecoration = TextDecoration.LineThrough),
    val pricePerSubunitStyle: TextStyle = TextStyle(color = Color(0xFF7C8086)),
    val expandControlsStyle: TextStyle = TextStyle(color = Color(0xFF2207F1)),
    // ── Shape ─────────────────────────────────────────────────────────────────
    /**
     * Corner radius applied to both user and agent message bubbles.
     * Declared as [CornerBasedShape] (covers [RoundedCornerShape], `CutCornerShape`, etc.)
     * so that Compose's stability analysis can verify the field is immutable.
     */
    val bubbleShape: CornerBasedShape = RoundedCornerShape(12.dp),
    // ── Image ─────────────────────────────────────────────────────────────────
    /** Optional URL for the channel avatar displayed in the app bar. Loaded by Coil. */
    val chatIconImage: String? = null,
    // ── Icons ─────────────────────────────────────────────────────────────────
    val sendButtonIcon: ImageVector = Icons.AutoMirrored.Filled.Send,
    val recordAudioIcon: ImageVector = Icons.Filled.Mic,
    val cancelRecordingIcon: ImageVector = Icons.Filled.Close,
    val closeModalIcon: ImageVector = Icons.Filled.Close,
    val playAudioIcon: ImageVector = Icons.Filled.PlayArrow,
    val pauseAudioIcon: ImageVector = Icons.Filled.Pause,
    /** Opens the attachment picker (gallery / camera). */
    val attachIcon: ImageVector = Icons.Filled.Add,
    val cameraIcon: ImageVector = Icons.Filled.CameraAlt,
    val galleryIcon: ImageVector = Icons.Filled.Image,
    val trashIcon: ImageVector = Icons.Filled.Delete,
    val imagePlaceholderIcon: ImageVector = Icons.Filled.Image,
    val shopIcon: ImageVector = Icons.Filled.Storefront,
    val cartIcon: ImageVector = Icons.Filled.ShoppingCart,
    val currencyIcon: ImageVector = Icons.Filled.AttachMoney,
    val addIcon: ImageVector = Icons.Filled.Add,
    val removeIcon: ImageVector = Icons.Filled.Remove,
    /** Arrow icon rendered on CTA buttons — port of Flutter ChatTheme.ctaArrowForwardIcon. */
    val ctaArrowForwardIcon: ImageVector = Icons.AutoMirrored.Filled.ArrowForward,
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
            sendButtonForegroundColor = colorScheme.onPrimary,
            waveColor = colorScheme.primary,
            actionIconColor = colorScheme.onSurface,
            userMessageTextStyle = TextStyle(color = colorScheme.onSurface, fontSize = 16.sp),
            assistantMessageTextStyle = TextStyle(color = colorScheme.onSurface, fontSize = 16.sp),
            hintTextStyle = TextStyle(color = colorScheme.onSurfaceVariant.copy(alpha = 0.6f)),
            inputTextFieldColor = colorScheme.surface,
            inputTextFieldBorderColor = colorScheme.outline,
            cancelRecordingIconColor = colorScheme.onSurfaceVariant,
            attachIconColor = colorScheme.onSurfaceVariant,
            cameraIconColor = colorScheme.onSurfaceVariant,
            galleryIconColor = colorScheme.onSurfaceVariant,
            playAudioIconColor = colorScheme.onSurfaceVariant,
            pauseAudioIconColor = colorScheme.onSurfaceVariant,
            userBubbleColor = colorScheme.surfaceVariant,
            agentBubbleColor = colorScheme.surfaceContainerHighest,
            imagePlaceholderBackgroundColor = colorScheme.surfaceVariant,
            cardBackgroundColor = colorScheme.surface,
            cardBorderColor = colorScheme.outlineVariant,
            attachmentPickerBackgroundColor = colorScheme.surfaceContainerHigh,
            quickReplyColor = colorScheme.surfaceVariant,
            quickReplyBorderColor = colorScheme.outline,
        )
    }
}

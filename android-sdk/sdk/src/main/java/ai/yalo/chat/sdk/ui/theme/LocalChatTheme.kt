// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.text.font.FontFamily

/**
 * The [ChatTheme] the host provided, if any.
 *
 * A theme is set once at the top of the chat and read wherever it is needed,
 * so it never has to travel down through composable parameters. It is static
 * because the host picks a theme and then it stays put.
 *
 * Read [currentChatTheme] instead of this local so that a composable rendered
 * on its own, in a preview or a test, still gets the default theme.
 */
internal val LocalChatTheme = staticCompositionLocalOf<ChatTheme?> { null }

/** The theme in scope, falling back to [ChatTheme.default] when none was provided. */
internal val currentChatTheme: ChatTheme
    @Composable
    @ReadOnlyComposable
    get() = LocalChatTheme.current ?: ChatTheme.default()

/** Puts [theme] in scope for [content] and everything below it. */
@Composable
internal fun ProvideChatTheme(
    theme: ChatTheme = ChatTheme.default(),
    content: @Composable () -> Unit,
) {
    val fontFamily = theme.fontFamily
    if (fontFamily == null) {
        CompositionLocalProvider(LocalChatTheme provides theme, content = content)
        return
    }
    // Every text in the chat reads the Material typography, so swapping the
    // family there reaches all of it at once.
    MaterialTheme(typography = MaterialTheme.typography.withFontFamily(fontFamily)) {
        CompositionLocalProvider(LocalChatTheme provides theme, content = content)
    }
}

private fun Typography.withFontFamily(fontFamily: FontFamily): Typography = copy(
    displayLarge = displayLarge.copy(fontFamily = fontFamily),
    displayMedium = displayMedium.copy(fontFamily = fontFamily),
    displaySmall = displaySmall.copy(fontFamily = fontFamily),
    headlineLarge = headlineLarge.copy(fontFamily = fontFamily),
    headlineMedium = headlineMedium.copy(fontFamily = fontFamily),
    headlineSmall = headlineSmall.copy(fontFamily = fontFamily),
    titleLarge = titleLarge.copy(fontFamily = fontFamily),
    titleMedium = titleMedium.copy(fontFamily = fontFamily),
    titleSmall = titleSmall.copy(fontFamily = fontFamily),
    bodyLarge = bodyLarge.copy(fontFamily = fontFamily),
    bodyMedium = bodyMedium.copy(fontFamily = fontFamily),
    bodySmall = bodySmall.copy(fontFamily = fontFamily),
    labelLarge = labelLarge.copy(fontFamily = fontFamily),
    labelMedium = labelMedium.copy(fontFamily = fontFamily),
    labelSmall = labelSmall.copy(fontFamily = fontFamily),
)

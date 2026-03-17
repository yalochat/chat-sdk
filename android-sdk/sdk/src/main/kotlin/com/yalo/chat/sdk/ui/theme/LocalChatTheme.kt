// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf

// CompositionLocal carrying the active ChatTheme down the composition tree.
// staticCompositionLocalOf is used because the theme is set once at init and never changes
// dynamically — avoids per-composable read tracking overhead of compositionLocalOf.
// Access via LocalChatTheme.current inside any SDK composable.
internal val LocalChatTheme = staticCompositionLocalOf<ChatTheme> {
    error("No ChatTheme found — ChatScreen must be used after YaloChat.init()")
}

// Provides [theme] to all SDK composables in [content].
@Composable
internal fun ChatThemeProvider(
    theme: ChatTheme,
    content: @Composable () -> Unit,
) {
    CompositionLocalProvider(LocalChatTheme provides theme, content = content)
}

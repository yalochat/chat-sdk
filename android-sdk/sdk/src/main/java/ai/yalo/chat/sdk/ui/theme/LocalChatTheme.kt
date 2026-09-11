// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf

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
    CompositionLocalProvider(LocalChatTheme provides theme, content = content)
}

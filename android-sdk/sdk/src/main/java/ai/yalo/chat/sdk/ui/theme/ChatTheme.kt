// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.ui.graphics.Color

/**
 * Colors the chat paints itself with.
 *
 * Every value defaults to the host `MaterialTheme`, so a chat dropped into an
 * app follows that app's light and dark schemes with no setup. Override only
 * what you need:
 *
 * ```
 * Chat(client, theme = ChatTheme.default().copy(headerBackground = Color.Red))
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
) {

    public companion object {

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
        )
    }
}

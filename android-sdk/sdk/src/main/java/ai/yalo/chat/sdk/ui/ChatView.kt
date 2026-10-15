// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.ui.theme.ChatTheme
import android.content.Context
import android.util.AttributeSet
import android.view.View
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.AbstractComposeView
import androidx.compose.ui.viewinterop.AndroidView

/**
 * The [Chat] as a classic Android view, for hosts that do not use Compose,
 * such as a React Native bridge or an XML layout.
 *
 * Nothing is drawn until [client] is set. The colors follow the system light or
 * dark scheme, and [theme] adjusts them:
 *
 * ```
 * chatView.theme = { default -> default.copy(headerBackground = Color.Red) }
 * ```
 *
 * [avatar] creates the view drawn beside the channel name, and above the
 * welcome message when it is drawn with vertical quick replies. It is called
 * once for each place, so give each its own view. [onBack] adds a back button
 * to the header, which is absent unless you set one.
 */
public class ChatView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : AbstractComposeView(context, attrs) {

    public var client: YaloChatClient? by mutableStateOf(null)

    public var theme: (ChatTheme) -> ChatTheme by mutableStateOf({ default -> default })

    public var avatar: ((Context) -> View)? by mutableStateOf(null)

    public var onBack: (() -> Unit)? by mutableStateOf(null)

    @Composable
    override fun Content() {
        val current = client ?: return
        val colors = if (isSystemInDarkTheme()) darkColorScheme() else lightColorScheme()
        MaterialTheme(colorScheme = colors) {
            Chat(
                client = current,
                theme = theme(ChatTheme.default()),
                avatar = avatar?.let { factory -> { AndroidView(factory = factory) } },
                onBack = onBack,
            )
        }
    }
}

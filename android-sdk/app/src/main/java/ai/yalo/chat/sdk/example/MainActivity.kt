// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.example

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.QuickReplyType
import ai.yalo.chat.sdk.SessionMode
import ai.yalo.chat.sdk.WelcomeMessageType
import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.example.ui.theme.ExampleTheme
import ai.yalo.chat.sdk.ui.Chat
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp

private fun exampleChatClient(): YaloChatClient = YaloChatClient(
    YaloChatClientConfig(
        // Fill up with your values
        channelId = "",
        organizationId = "",
        channelName = "Test channel name",
        userId = "test-user-id",
        // Everything the SDK has to say, which is what an example app wants.
        logLevel = LogLevel.Debug,
        // What the chat is being opened from, as if a person had tapped
        // for help while looking at this product.
        openContext = mapOf("sku" to "44555697"),
        // Chips under the message that offered them, rather than in a bar of
        // their own above the input.
        quickReplyType = QuickReplyType.Inline,
        // The channel's first message centered, with one quick reply per line,
        // until the person answers.
        welcomeMessageType = WelcomeMessageType.VerticalQuickReplies,
        // A new conversation every time the app is started, and nothing left
        // behind once it ends. Turning the device keeps it.
        sessionMode = SessionMode.Ephemeral,
    ),
)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val yaloChatClient = exampleChatClient()
        setContent {
            ExampleTheme {
                ExampleApp(yaloChatClient)
            }
        }
    }
}

/**
 * A host app with nothing in it but a button that opens the chat.
 *
 * The chat slides in over the page and covers it while open. The header's back
 * button closes it again, which is why [Chat] is given an `onBack`.
 */
@Composable
fun ExampleApp(client: YaloChatClient) {
    var chatIsOpen: Boolean by rememberSaveable { mutableStateOf(false) }

    BackHandler(enabled = chatIsOpen) {
        chatIsOpen = false
    }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        floatingActionButton = {
            AnimatedVisibility(
                visible = !chatIsOpen,
                enter = scaleIn() + fadeIn(),
                exit = scaleOut() + fadeOut(),
            ) {
                // Labelled rather than an icon: material-icons-core carries no
                // chat glyph, and the extended set is not worth pulling in for
                // one button.
                ExtendedFloatingActionButton(onClick = { chatIsOpen = true }) {
                    Text("Open chat")
                }
            }
        },
    ) { innerPadding ->
        Box(modifier = Modifier.fillMaxSize()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "Example app",
                    style = MaterialTheme.typography.bodyLarge,
                )
            }
            // The chat slides in over the host page from the side the
            // language reads towards, so it enters from the right in English
            // and from the left in Arabic.
            val readsRightToLeft = LocalLayoutDirection.current == LayoutDirection.Rtl
            val offScreen: (Int) -> Int = { width ->
                if (readsRightToLeft) -width else width
            }
            AnimatedVisibility(
                visible = chatIsOpen,
                modifier = Modifier.fillMaxSize(),
                enter = slideInHorizontally(initialOffsetX = offScreen) + fadeIn(),
                exit = slideOutHorizontally(targetOffsetX = offScreen) + fadeOut(),
            ) {
                // The chat fills whatever space it is given. The host owns the
                // window insets and passes them down through the modifier.
                Chat(
                    client = client,
                    modifier = Modifier
                        .padding(innerPadding)
                        .consumeWindowInsets(innerPadding)
                        .imePadding(),
                    avatar = { ExampleAvatar() },
                    onBack = { chatIsOpen = false },
                )
            }
        }
    }
}

/**
 * A letter in a circle, so the example needs no image loading library. A real
 * app would load its logo here with whatever it already uses.
 */
@Composable
private fun ExampleAvatar() {
    Box(
        modifier = Modifier
            .size(40.dp)
            .background(MaterialTheme.colorScheme.primary, CircleShape),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = "Y",
            color = MaterialTheme.colorScheme.onPrimary,
            style = MaterialTheme.typography.titleMedium,
        )
    }
}

@Preview(showBackground = true)
@Composable
fun ExampleAppPreview() {
    ExampleTheme {
        ExampleApp(exampleChatClient())
    }
}

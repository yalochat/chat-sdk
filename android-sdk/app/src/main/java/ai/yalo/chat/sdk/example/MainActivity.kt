// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.example

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.example.ui.theme.ExampleTheme
import ai.yalo.chat.sdk.ui.Chat
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
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
import androidx.compose.ui.tooling.preview.Preview

private fun exampleChatClient(): YaloChatClient = YaloChatClient(
    YaloChatClientConfig(
        // Fill up with your values
        channelId = "",
        organizationId = "",
        channelName = "Test channel name",
        userId = "test-user-id",
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
 * The chat takes over the screen while it is open and the header's back button
 * closes it again, which is why [Chat] is given an `onBack`.
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
            if (!chatIsOpen) {
                // Labelled rather than an icon: material-icons-core carries no
                // chat glyph, and the extended set is not worth pulling in for
                // one button.
                ExtendedFloatingActionButton(onClick = { chatIsOpen = true }) {
                    Text("Open chat")
                }
            }
        },
    ) { innerPadding ->
        // The chat fills whatever space it is given. The host owns the window
        // insets and passes them down through the modifier.
        if (chatIsOpen) {
            Chat(
                client = client,
                modifier = Modifier
                    .padding(innerPadding)
                    .consumeWindowInsets(innerPadding)
                    .imePadding(),
                onBack = { chatIsOpen = false },
            )
        } else {
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
        }
    }
}

@Preview(showBackground = true)
@Composable
fun ExampleAppPreview() {
    ExampleTheme {
        ExampleApp(exampleChatClient())
    }
}

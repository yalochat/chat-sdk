package ai.yalo.chat.sdk.example

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.example.ui.theme.ExampleTheme
import ai.yalo.chat.sdk.ui.Chat
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
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
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    // The chat fills whatever space it is given. The host owns
                    // the window insets and passes them down through the modifier.
                    Chat(
                        client = yaloChatClient,
                        modifier = Modifier
                            .padding(innerPadding)
                            .consumeWindowInsets(innerPadding)
                            .imePadding(),
                    )
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun ChatPreview() {
    ExampleTheme {
        Chat(exampleChatClient())
    }
}

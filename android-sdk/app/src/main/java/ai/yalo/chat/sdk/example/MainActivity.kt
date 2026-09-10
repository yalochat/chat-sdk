package ai.yalo.chat.sdk.example

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import ai.yalo.chat.sdk.example.ui.theme.ExampleTheme
import ai.yalo.chat.sdk.ui.Chat

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val yaloChatClientConfig = YaloChatClientConfig(
            // Fill up with your values
            channelId = "",
            organizationId = "",
            channelName = "Test channel name",
            userId = "test-user-id",
        )
        val yaloChatClient = YaloChatClient(yaloChatClientConfig)
        setContent {
            ExampleTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { _ ->
                    Chat(yaloChatClient)
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    val yaloChatClientConfig = YaloChatClientConfig(
        // Fill up with your values
        channelId = "",
        organizationId = "",
        channelName = "Test channel name",
        userId = "test-user-id",
    )
    val yaloChatClient = YaloChatClient(yaloChatClientConfig)
    ExampleTheme {
        Scaffold(modifier = Modifier.fillMaxSize()) { _ ->
            Chat(
                YaloChatClient(yaloChatClientConfig)
            )
        }
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.YaloChatClient
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Modifier

@Composable
public fun Chat(client: YaloChatClient, modifier: Modifier = Modifier) {
    var text: String by rememberSaveable { mutableStateOf("") }
    ChatLayout(
        title = client.config.channelName,
        text = text,
        onTextChange = { value -> text = value },
        onSend = {
            client.sendTextMessage(text.trim())
            text = ""
        },
        modifier = modifier,
    )
}

@Composable
internal fun ChatLayout(
    title: String,
    text: String,
    onTextChange: (String) -> Unit,
    onSend: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Surface(
        modifier = modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.surface,
    ) {
        Column(modifier = Modifier.fillMaxSize().imePadding()) {
            ChatHeader(title = title)
            ChatMessageList(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
            )
            ChatFooter(
                text = text,
                onTextChange = onTextChange,
                onSend = onSend,
                modifier = Modifier.navigationBarsPadding(),
            )
        }
    }
}

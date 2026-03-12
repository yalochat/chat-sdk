// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.yalo.chat.sdk.YaloChat
import com.yalo.chat.sdk.ui.chat.ChatAppBar
import com.yalo.chat.sdk.ui.chat.ChatInput
import com.yalo.chat.sdk.ui.chat.MessageList
import com.yalo.chat.sdk.ui.chat.MessagesEvent
import com.yalo.chat.sdk.ui.chat.MessagesViewModel

// Port of flutter-sdk Chat widget.
// Scaffold mirrors Flutter's Scaffold: ChatAppBar (topBar), ChatInput (bottomBar),
// MessageList (body) — LazyColumn with reverseLayout = true.
@Composable
fun ChatScreen(onBack: (() -> Unit)? = null) {
    val viewModel: MessagesViewModel = viewModel(factory = YaloChat.getViewModelFactory())
    val state by viewModel.state.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.handleEvent(MessagesEvent.LoadMessages)
        viewModel.handleEvent(MessagesEvent.SubscribeToMessages)
    }

    Scaffold(
        topBar = {
            ChatAppBar(title = YaloChat.config.name, onBack = onBack)
        },
        bottomBar = {
            ChatInput(
                userMessage = state.userMessage,
                onUserMessageChange = { viewModel.handleEvent(MessagesEvent.UpdateUserMessage(it)) },
                onSendMessage = { viewModel.handleEvent(MessagesEvent.SendTextMessage(state.userMessage)) },
            )
        },
    ) { paddingValues ->
        MessageList(
            messages = state.messages,
            modifier = Modifier.padding(paddingValues),
        )
    }
}

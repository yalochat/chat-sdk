// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.demo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.yalo.chat.sdk.YaloChat
import com.yalo.chat.sdk.YaloChatConfig
import com.yalo.chat.sdk.ui.ChatScreen
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        YaloChat.init(
            YaloChatConfig(
                name = "Yalo Chat",
                flowKey = "demo-flow-key",
                authToken = "demo-auth-token",
                userToken = "demo-user-token",
            )
        )
        setContent {
            ChatScreen()
        }
    }
}

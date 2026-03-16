// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.demo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.yalo.chat.sdk.YaloChat
import com.yalo.chat.sdk.YaloChatConfig
import com.yalo.chat.sdk.ui.ChatScreen
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        YaloChat.init(
            config = YaloChatConfig(
                name = "Yalo Chat",
                flowKey = BuildConfig.YALO_FLOW_KEY,
                authToken = BuildConfig.YALO_AUTH_TOKEN,
                userToken = BuildConfig.YALO_USER_TOKEN,
                apiBaseUrl = BuildConfig.YALO_API_BASE_URL,
            ),
            context = this,
        )
        setContent {
            var showChat by remember { mutableStateOf(false) }
            if (showChat) {
                ChatScreen(onBack = { showChat = false })
            } else {
                HomeScreen(onOpenChat = { showChat = true })
            }
        }
    }
}

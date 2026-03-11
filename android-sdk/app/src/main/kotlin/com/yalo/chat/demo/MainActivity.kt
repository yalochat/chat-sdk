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
                flowKey = BuildConfig.YALO_FLOW_KEY,
                authToken = BuildConfig.YALO_AUTH_TOKEN,
                userToken = BuildConfig.YALO_USER_TOKEN,
                apiBaseUrl = BuildConfig.YALO_API_BASE_URL,
            )
        )
        setContent {
            ChatScreen()
        }
    }
}

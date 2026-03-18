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
                channelName = BuildConfig.YALO_CHANNEL_NAME,
                channelId = BuildConfig.YALO_CHANNEL_ID,
                organizationId = BuildConfig.YALO_ORGANIZATION_ID,
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

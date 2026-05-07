// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.demo

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.yalo.chat.sdk.YaloChat
import com.yalo.chat.sdk.YaloChatConfig
import com.yalo.chat.sdk.YaloChatEnvironment
import com.yalo.chat.sdk.domain.model.ChatCommand
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
                environment = runCatching { YaloChatEnvironment.valueOf(BuildConfig.YALO_ENVIRONMENT) }
                    .getOrDefault(YaloChatEnvironment.PRODUCTION),
            ),
            context = this,
        )
        YaloChat.registerCommand(ChatCommand.ADD_TO_CART) { payload ->
            val p = payload as? Map<*, *>
            Log.d("YaloCommands", "ADD_TO_CART  sku=${p?.get("sku")}  qty=${p?.get("quantity")}")
        }
        YaloChat.registerCommand(ChatCommand.REMOVE_FROM_CART) { payload ->
            val p = payload as? Map<*, *>
            Log.d("YaloCommands", "REMOVE_FROM_CART  sku=${p?.get("sku")}  qty=${p?.get("quantity")}")
        }
        YaloChat.registerCommand(ChatCommand.CLEAR_CART) {
            Log.d("YaloCommands", "CLEAR_CART")
        }
        YaloChat.registerCommand(ChatCommand.ADD_PROMOTION) { payload ->
            val p = payload as? Map<*, *>
            Log.d("YaloCommands", "ADD_PROMOTION  promotionId=${p?.get("promotionId")}")
        }
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

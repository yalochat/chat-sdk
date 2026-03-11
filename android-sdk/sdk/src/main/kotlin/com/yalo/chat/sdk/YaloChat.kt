// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.buildHttpClient
import com.yalo.chat.sdk.data.repository.fake.FakeChatMessageRepository
import com.yalo.chat.sdk.data.repository.remote.YaloMessageRepositoryRemote
import com.yalo.chat.sdk.ui.chat.MessagesViewModel
import io.ktor.client.engine.android.Android

// Port of flutter-sdk YaloChat entry point.
// Phase 2 M1: wires real Ktor networking via YaloMessageRepositoryRemote.
// Phase 2 M2: will replace FakeChatMessageRepository with SQLDelight persistence.
object YaloChat {

    private var _config: YaloChatConfig? = null
    private var _viewModelFactory: ViewModelProvider.Factory? = null

    val config: YaloChatConfig
        get() = _config ?: error("YaloChat.init() must be called before accessing config")

    fun init(config: YaloChatConfig) {
        _config = config
        val httpClient = buildHttpClient(Android.create(), debug = BuildConfig.DEBUG)
        val apiService = YaloChatApiService(
            apiBaseUrl = config.apiBaseUrl,
            authToken = config.authToken,
            userToken = config.userToken,
            flowKey = config.flowKey,
            httpClient = httpClient,
        )
        val yaloRepo = YaloMessageRepositoryRemote(apiService)
        // Phase 2 M2 will replace FakeChatMessageRepository with ChatMessageRepositoryLocal (SQLDelight).
        val chatRepo = FakeChatMessageRepository()
        _viewModelFactory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                require(modelClass.isAssignableFrom(MessagesViewModel::class.java)) {
                    "Unsupported ViewModel class: $modelClass"
                }
                return MessagesViewModel(yaloRepo, chatRepo) as T
            }
        }
    }

    fun getViewModelFactory(): ViewModelProvider.Factory =
        _viewModelFactory ?: error("YaloChat.init() must be called before rendering ChatScreen")
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.yalo.chat.sdk.data.repository.fake.FakeChatMessageRepository
import com.yalo.chat.sdk.data.repository.fake.FakeYaloMessageRepository
import com.yalo.chat.sdk.ui.chat.MessagesViewModel

// Port of flutter-sdk YaloChat entry point.
// Phase 2 wires real repos (Ktor networking, SQLDelight persistence) here.
object YaloChat {

    private var _config: YaloChatConfig? = null
    private var _viewModelFactory: ViewModelProvider.Factory? = null

    val config: YaloChatConfig
        get() = _config ?: error("YaloChat.init() must be called before accessing config")

    fun init(config: YaloChatConfig) {
        _config = config
        val yaloRepo = FakeYaloMessageRepository()
        val chatRepo = FakeChatMessageRepository(FakeYaloMessageRepository.SEED_MESSAGES)
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

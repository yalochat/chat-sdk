// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

sealed class ChatStatus {
    data object Initial : ChatStatus()
    data object Success : ChatStatus()
    data object Failure : ChatStatus()
    data object Offline : ChatStatus()
}

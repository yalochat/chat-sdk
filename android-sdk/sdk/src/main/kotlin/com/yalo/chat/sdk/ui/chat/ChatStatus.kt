// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

// Port of flutter-sdk/lib/src/ui/chat/view_models/messages/chat_status.dart
sealed class ChatStatus {
    object Initial : ChatStatus()
    object Success : ChatStatus()
    object Failure : ChatStatus()
    object Offline : ChatStatus()
}

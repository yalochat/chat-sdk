// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.repository

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatMessage

// Port of flutter-sdk/lib/src/data/repositories/yalo_message_repository.dart
// Phase 1: implemented by FakeYaloMessageRepository (in-memory hardcoded messages).
// Phase 2: implemented by YaloMessageRepositoryRemote (Ktor HTTP + polling).
interface YaloMessageRepository {
    suspend fun sendMessage(message: ChatMessage): Result<Unit>
    suspend fun fetchMessages(since: Long): Result<List<ChatMessage>>
}

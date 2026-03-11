// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

// Port of flutter-sdk YaloMessageRepositoryRemote._startPolling() + _handleMessagesSubscription().
// Separates the remote polling concern from MessagesViewModel — the ViewModel only observes
// the local store, while this service keeps the local store in sync with the server.
//
// Data flow:
//   YaloMessageRepositoryRemote.pollIncomingMessages()
//     → emit(batch) on each non-empty poll cycle
//     → MessageSyncService inserts batch into LocalChatMessageRepository (single transaction)
//     → LocalChatMessageRepository.observeMessages() emits updated list
//     → MessagesViewModel updates UI
//
// FDE-56: Free of Android-specific imports (KMP-compatible).
class MessageSyncService(
    private val yaloRepo: YaloMessageRepository,
    private val localRepo: ChatMessageRepository,
) {
    private var job: Job? = null

    // Start polling. Idempotent — calling while already active is a no-op.
    fun start(scope: CoroutineScope) {
        if (job?.isActive == true) return
        job = scope.launch {
            yaloRepo.pollIncomingMessages().collect { batch ->
                // Insert the whole poll batch in one SQLDelight transaction.
                // Polling continues on the next cycle regardless of insert outcome.
                val result = localRepo.insertMessages(batch)
                if (result is Result.Error) {
                    // Surface failures so SDK consumers can observe sync issues.
                    println("MessageSyncService: insertMessages failed — ${result.error.message}")
                }
            }
        }
    }

    fun stop() {
        job?.cancel()
        job = null
    }
}

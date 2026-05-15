// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

// Separates the remote polling concern from MessagesViewModel — the ViewModel only observes
// the local store, while this service keeps the local store in sync with the server.
//
// Data flow:
//   YaloMessageRepository.pollIncomingMessages()
//     → emit(batch) on each non-empty poll cycle
//     → MessageSyncService inserts batch into LocalChatMessageRepository (single transaction)
//     → LocalChatMessageRepository.observeMessages() emits updated list
//     → MessagesViewModel updates UI
internal class MessageSyncService(
    private val yaloRepo: YaloMessageRepository,
    private val localRepo: ChatMessageRepository,
    // Optional callback for insert failures — avoids println in library code.
    // YaloChat wires this to android.util.Log; tests can pass a capturing lambda.
    private val onSyncError: ((Throwable) -> Unit)? = null,
) {
    private var job: Job? = null

    // Start polling. Idempotent — calling while already active is a no-op.
    // Before the first poll, pre-warms the remote repo's dedup cache with the wiIds of
    // messages already in the local DB, so media files from previous sessions are never
    // re-downloaded on cold restart (which would block text responses for minutes).
    fun start(scope: CoroutineScope) {
        if (job?.isActive == true) return
        job = scope.launch {
            val existing = localRepo.getMessages(cursor = null, limit = 500)
            if (existing is Result.Ok) {
                yaloRepo.warmDedupCache(existing.result.mapNotNull { it.wiId })
            }
            yaloRepo.pollIncomingMessages().collect { batch ->
                // Insert the whole poll batch in one SQLDelight transaction.
                // Polling continues on the next cycle regardless of insert outcome.
                val result = localRepo.insertMessages(batch)
                if (result is Result.Error) {
                    onSyncError?.invoke(result.error)
                }
            }
        }
    }

    fun stop() {
        job?.cancel()
        job = null
    }
}

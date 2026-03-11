// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow

// Phase 1 stub — returns hardcoded messages covering all MessageType variants
// (Text, Image, Voice, Product, ProductCarousel, Promotion, QuickReply, Unknown).
// Replaced in Phase 2 by YaloMessageRepositoryRemote (FDE-51).
class FakeYaloMessageRepository : YaloMessageRepository {

    override suspend fun sendMessage(message: ChatMessage): Result<Unit> =
        Result.Ok(Unit)

    override suspend fun fetchMessages(since: Long): Result<List<ChatMessage>> =
        Result.Ok(SEED_MESSAGES)

    // No-op: Phase 1 has no remote polling — the fake repo provides seed data only.
    override fun pollIncomingMessages(): Flow<List<ChatMessage>> = emptyFlow()

    companion object {
        val SEED_MESSAGES: List<ChatMessage> = listOf(
            ChatMessage(
                id = 1L,
                role = MessageRole.AGENT,
                type = MessageType.Text,
                status = MessageStatus.DELIVERED,
                content = "Hello! How can I help you today?",
                timestamp = System.currentTimeMillis() - 60_000,
            ),
            ChatMessage(
                id = 2L,
                role = MessageRole.USER,
                type = MessageType.Text,
                status = MessageStatus.READ,
                content = "I need help with my order.",
                timestamp = System.currentTimeMillis() - 50_000,
            ),
            ChatMessage(
                id = 3L,
                role = MessageRole.AGENT,
                type = MessageType.Image,
                status = MessageStatus.DELIVERED,
                content = "https://example.com/product.jpg",
                timestamp = System.currentTimeMillis() - 40_000,
            ),
            ChatMessage(
                id = 4L,
                role = MessageRole.AGENT,
                type = MessageType.Voice,
                status = MessageStatus.DELIVERED,
                fileName = "audio_greeting.mp4",
                duration = 3200L,
                timestamp = System.currentTimeMillis() - 30_000,
            ),
            ChatMessage(
                id = 5L,
                role = MessageRole.AGENT,
                type = MessageType.Product,
                status = MessageStatus.DELIVERED,
                content = "Check out this product:",
                timestamp = System.currentTimeMillis() - 20_000,
            ),
            ChatMessage(
                id = 6L,
                role = MessageRole.AGENT,
                type = MessageType.QuickReply,
                status = MessageStatus.DELIVERED,
                content = "Please choose an option:",
                quickReplies = listOf("Track order", "Cancel order", "Talk to agent"),
                timestamp = System.currentTimeMillis() - 10_000,
            ),
            ChatMessage(
                id = 7L,
                role = MessageRole.AGENT,
                type = MessageType.ProductCarousel,
                status = MessageStatus.DELIVERED,
                content = "Here are some options:",
                timestamp = System.currentTimeMillis() - 8_000,
            ),
            ChatMessage(
                id = 8L,
                role = MessageRole.AGENT,
                type = MessageType.Promotion,
                status = MessageStatus.DELIVERED,
                content = "Special offer just for you!",
                timestamp = System.currentTimeMillis() - 6_000,
            ),
            ChatMessage(
                id = 9L,
                role = MessageRole.AGENT,
                type = MessageType.Unknown,
                status = MessageStatus.DELIVERED,
                content = "",
                timestamp = System.currentTimeMillis() - 5_000,
            ),
        )
    }
}

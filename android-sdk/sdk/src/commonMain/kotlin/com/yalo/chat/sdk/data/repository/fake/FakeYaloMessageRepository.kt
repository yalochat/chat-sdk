// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatButton
import com.yalo.chat.sdk.domain.model.ChatButtonType
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.model.Product
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.datetime.Clock

// Phase 1 stub — returns hardcoded messages covering all MessageType variants
// (Text, Image, Voice, Product, ProductCarousel, Promotion, QuickReply, Unknown).
// Replaced in Phase 2 by YaloMessageRepositoryRemote (FDE-51).
internal class FakeYaloMessageRepository : YaloMessageRepository {

    override suspend fun sendMessage(message: ChatMessage): Result<Unit> =
        Result.Ok(Unit)

    override suspend fun fetchMessages(since: Long): Result<List<ChatMessage>> =
        Result.Ok(SEED_MESSAGES)

    // No-op: Phase 1 has no remote polling — the fake repo provides seed data only.
    override fun pollIncomingMessages(): Flow<List<ChatMessage>> = emptyFlow()

    // No-op: fake repo emits no typing events.
    override fun events(): Flow<ChatEvent> = emptyFlow()

    companion object {
        val SEED_MESSAGES: List<ChatMessage> = listOf(
            ChatMessage(
                id = 1L,
                role = MessageRole.AGENT,
                type = MessageType.Text,
                status = MessageStatus.DELIVERED,
                content = "Hello! How can I help you today?",
                timestamp = Clock.System.now().toEpochMilliseconds() - 60_000,
            ),
            ChatMessage(
                id = 2L,
                role = MessageRole.USER,
                type = MessageType.Text,
                status = MessageStatus.READ,
                content = "I need help with my order.",
                timestamp = Clock.System.now().toEpochMilliseconds() - 50_000,
            ),
            ChatMessage(
                id = 3L,
                role = MessageRole.AGENT,
                type = MessageType.Image,
                status = MessageStatus.DELIVERED,
                content = "https://picsum.photos/seed/agent-img/400/300",
                timestamp = Clock.System.now().toEpochMilliseconds() - 40_000,
            ),
            ChatMessage(
                id = 4L,
                role = MessageRole.AGENT,
                type = MessageType.Voice,
                status = MessageStatus.DELIVERED,
                fileName = "audio_greeting.mp4",
                duration = 3200L,
                timestamp = Clock.System.now().toEpochMilliseconds() - 30_000,
            ),
            ChatMessage(
                id = 5L,
                role = MessageRole.AGENT,
                type = MessageType.Product,
                status = MessageStatus.DELIVERED,
                content = "Check out these products:",
                products = listOf(
                    Product(sku = "p1", name = "Organic Milk 1L", price = 25.50, imagesUrl = listOf("https://picsum.photos/seed/p1/200/200"), unitName = "unit", unitStep = 1.0),
                    Product(sku = "p2", name = "Free-range Eggs x12", price = 42.00, salePrice = 38.00, imagesUrl = listOf("https://picsum.photos/seed/p2/200/200"), unitName = "unit", unitStep = 1.0),
                    Product(sku = "p3", name = "Whole Wheat Bread 600g", price = 18.00, imagesUrl = listOf("https://picsum.photos/seed/p3/200/200"), unitName = "unit", unitStep = 1.0),
                    Product(sku = "p4", name = "Greek Yogurt 500g", price = 30.00, imagesUrl = listOf("https://picsum.photos/seed/p4/200/200"), unitName = "unit", unitStep = 1.0),
                ),
                timestamp = Clock.System.now().toEpochMilliseconds() - 20_000,
            ),
            ChatMessage(
                id = 6L,
                role = MessageRole.AGENT,
                type = MessageType.Text,
                status = MessageStatus.DELIVERED,
                content = "Please choose an option:",
                buttons = listOf(
                    ChatButton(text = "Track order", type = ChatButtonType.REPLY),
                    ChatButton(text = "Cancel order", type = ChatButtonType.REPLY),
                    ChatButton(text = "Talk to agent", type = ChatButtonType.REPLY),
                ),
                timestamp = Clock.System.now().toEpochMilliseconds() - 10_000,
            ),
            ChatMessage(
                id = 7L,
                role = MessageRole.AGENT,
                type = MessageType.ProductCarousel,
                status = MessageStatus.DELIVERED,
                content = "Here are some options:",
                products = listOf(
                    Product(sku = "c1", name = "Organic Milk 1L", price = 25.50, imagesUrl = listOf("https://picsum.photos/seed/c1/200/200"), unitName = "unit", unitStep = 1.0),
                    Product(sku = "c2", name = "Free-range Eggs x12", price = 42.00, salePrice = 38.00, imagesUrl = listOf("https://picsum.photos/seed/c2/200/200"), unitName = "unit", unitStep = 1.0),
                    Product(sku = "c3", name = "Whole Wheat Bread 600g", price = 18.00, imagesUrl = listOf("https://picsum.photos/seed/c3/200/200"), unitName = "unit", unitStep = 1.0),
                ),
                timestamp = Clock.System.now().toEpochMilliseconds() - 8_000,
            ),
            ChatMessage(
                id = 8L,
                role = MessageRole.AGENT,
                type = MessageType.Promotion,
                status = MessageStatus.DELIVERED,
                content = "Special offer just for you!",
                timestamp = Clock.System.now().toEpochMilliseconds() - 6_000,
            ),
            ChatMessage(
                id = 9L,
                role = MessageRole.AGENT,
                type = MessageType.Unknown,
                status = MessageStatus.DELIVERED,
                content = "",
                timestamp = Clock.System.now().toEpochMilliseconds() - 5_000,
            ),
        )
    }
}

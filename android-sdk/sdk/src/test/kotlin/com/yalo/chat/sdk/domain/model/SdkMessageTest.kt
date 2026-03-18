// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNull

class SdkMessageTest {

    // -------------------------------------------------------------------------
    // ResponseStatus
    // -------------------------------------------------------------------------

    @Test
    fun `ResponseStatus fromString returns correct value for known strings`() {
        assertEquals(ResponseStatus.UNSPECIFIED, ResponseStatus.fromString("UNSPECIFIED"))
        assertEquals(ResponseStatus.SUCCESS, ResponseStatus.fromString("SUCCESS"))
        assertEquals(ResponseStatus.ERROR, ResponseStatus.fromString("ERROR"))
    }

    @Test
    fun `ResponseStatus fromString returns UNSPECIFIED for unknown string`() {
        assertEquals(ResponseStatus.UNSPECIFIED, ResponseStatus.fromString("unknown"))
        assertEquals(ResponseStatus.UNSPECIFIED, ResponseStatus.fromString(""))
    }

    // -------------------------------------------------------------------------
    // ProductOrientation
    // -------------------------------------------------------------------------

    @Test
    fun `ProductOrientation fromString returns correct value for known strings`() {
        assertEquals(ProductOrientation.UNSPECIFIED, ProductOrientation.fromString("UNSPECIFIED"))
        assertEquals(ProductOrientation.VERTICAL, ProductOrientation.fromString("VERTICAL"))
        assertEquals(ProductOrientation.HORIZONTAL, ProductOrientation.fromString("HORIZONTAL"))
    }

    @Test
    fun `ProductOrientation fromString returns UNSPECIFIED for unknown string`() {
        assertEquals(ProductOrientation.UNSPECIFIED, ProductOrientation.fromString("carousel"))
        assertEquals(ProductOrientation.UNSPECIFIED, ProductOrientation.fromString(""))
    }

    // -------------------------------------------------------------------------
    // MessageRole — UNSPECIFIED variant
    // -------------------------------------------------------------------------

    @Test
    fun `MessageRole includes UNSPECIFIED variant`() {
        assertEquals(MessageRole.UNSPECIFIED, MessageRole.fromString("UNSPECIFIED"))
    }

    @Test
    fun `MessageRole existing variants still resolve correctly`() {
        assertEquals(MessageRole.USER, MessageRole.fromString("USER"))
        assertEquals(MessageRole.AGENT, MessageRole.fromString("AGENT"))
        // Fallback for unknowns remains AGENT per existing contract.
        assertEquals(MessageRole.AGENT, MessageRole.fromString("unknown"))
    }

    // -------------------------------------------------------------------------
    // MessageStatus — UNSPECIFIED variant
    // -------------------------------------------------------------------------

    @Test
    fun `MessageStatus includes UNSPECIFIED variant`() {
        assertEquals(MessageStatus.UNSPECIFIED, MessageStatus.fromString("UNSPECIFIED"))
    }

    @Test
    fun `MessageStatus existing variants still resolve correctly`() {
        assertEquals(MessageStatus.SENT, MessageStatus.fromString("SENT"))
        assertEquals(MessageStatus.DELIVERED, MessageStatus.fromString("DELIVERED"))
        assertEquals(MessageStatus.READ, MessageStatus.fromString("READ"))
        assertEquals(MessageStatus.IN_PROGRESS, MessageStatus.fromString("IN_PROGRESS"))
        assertEquals(MessageStatus.ERROR, MessageStatus.fromString("ERROR"))
        // Fallback for unknowns remains IN_PROGRESS per existing contract.
        assertEquals(MessageStatus.IN_PROGRESS, MessageStatus.fromString("unknown"))
    }

    // -------------------------------------------------------------------------
    // TextMessage content type
    // -------------------------------------------------------------------------

    @Test
    fun `TextMessage default values are applied correctly`() {
        val msg = TextMessage(timestamp = 1_000L, text = "hello")
        assertNull(msg.messageId)
        assertEquals(MessageStatus.UNSPECIFIED, msg.status)
        assertEquals(MessageRole.UNSPECIFIED, msg.role)
    }

    @Test
    fun `TextMessage equality holds for same field values`() {
        val a = TextMessage(messageId = "m1", timestamp = 1_000L, text = "hi", status = MessageStatus.SENT, role = MessageRole.USER)
        val b = a.copy()
        assertEquals(a, b)
    }

    // -------------------------------------------------------------------------
    // VoiceMessage content type
    // -------------------------------------------------------------------------

    @Test
    fun `VoiceMessage default amplitudesPreview is empty`() {
        val msg = VoiceMessage(timestamp = 2_000L, mediaUrl = "https://example.com/a.ogg", duration = 3.5, mediaType = "audio/ogg")
        assertEquals(emptyList(), msg.amplitudesPreview)
        assertEquals(MessageStatus.UNSPECIFIED, msg.status)
    }

    // -------------------------------------------------------------------------
    // ImageMessage content type
    // -------------------------------------------------------------------------

    @Test
    fun `ImageMessage optional text is null by default`() {
        val msg = ImageMessage(timestamp = 3_000L, mediaUrl = "https://example.com/img.jpg", mediaType = "image/jpeg")
        assertNull(msg.text)
        assertNull(msg.messageId)
    }

    // -------------------------------------------------------------------------
    // SdkMessage sealed class — construction and type checks
    // -------------------------------------------------------------------------

    @Test
    fun `TextMessageRequest is SdkMessage and carries envelope fields`() {
        val content = TextMessage(timestamp = 1_000L, text = "hello")
        val msg = SdkMessage.TextMessageRequest(correlationId = "corr-1", timestamp = 1_000L, content = content)
        assertIs<SdkMessage>(msg)
        assertEquals("corr-1", msg.correlationId)
        assertEquals(1_000L, msg.timestamp)
        assertEquals("hello", msg.content.text)
    }

    @Test
    fun `TextMessageResponse carries status and messageId`() {
        val msg = SdkMessage.TextMessageResponse(
            correlationId = "corr-2",
            timestamp = 2_000L,
            status = ResponseStatus.SUCCESS,
            messageId = "msg-42",
        )
        assertEquals(ResponseStatus.SUCCESS, msg.status)
        assertEquals("msg-42", msg.messageId)
    }

    @Test
    fun `VoiceMessageRequest default quickReplies is empty`() {
        val content = VoiceMessage(timestamp = 0L, mediaUrl = "u", duration = 1.0, mediaType = "audio/ogg")
        val msg = SdkMessage.VoiceMessageRequest(correlationId = "c", timestamp = 0L, content = content)
        assertEquals(emptyList(), msg.quickReplies)
    }

    @Test
    fun `ImageMessageRequest carries quickReplies`() {
        val content = ImageMessage(timestamp = 0L, mediaUrl = "u", mediaType = "image/jpeg")
        val msg = SdkMessage.ImageMessageRequest(
            correlationId = "c",
            timestamp = 0L,
            content = content,
            quickReplies = listOf("Yes", "No"),
        )
        assertEquals(listOf("Yes", "No"), msg.quickReplies)
    }

    @Test
    fun `MessageReceiptRequest carries messageStatus and messageId`() {
        val msg = SdkMessage.MessageReceiptRequest(
            correlationId = "c",
            timestamp = 0L,
            status = MessageStatus.DELIVERED,
            messageId = "msg-1",
        )
        assertEquals(MessageStatus.DELIVERED, msg.status)
        assertEquals("msg-1", msg.messageId)
        assertEquals(emptyList(), msg.quickReplies)
    }

    @Test
    fun `AddToCartRequest carries sku and quantity`() {
        val msg = SdkMessage.AddToCartRequest(correlationId = "c", timestamp = 0L, sku = "SKU-007", quantity = 2.5)
        assertEquals("SKU-007", msg.sku)
        assertEquals(2.5, msg.quantity)
    }

    @Test
    fun `RemoveFromCartRequest optional quantity is null by default`() {
        val msg = SdkMessage.RemoveFromCartRequest(correlationId = "c", timestamp = 0L, sku = "SKU-007")
        assertNull(msg.quantity)
    }

    @Test
    fun `ClearCartRequest carries only envelope fields`() {
        val msg = SdkMessage.ClearCartRequest(correlationId = "c", timestamp = 999L)
        assertEquals("c", msg.correlationId)
        assertEquals(999L, msg.timestamp)
    }

    @Test
    fun `GuidanceCardResponse carries title description and cards`() {
        val msg = SdkMessage.GuidanceCardResponse(
            correlationId = "c",
            timestamp = 0L,
            status = ResponseStatus.SUCCESS,
            guidanceTitle = "Help",
            guidanceDescription = "Choose an option",
            guidanceCards = listOf("Option A", "Option B"),
        )
        assertEquals("Help", msg.guidanceTitle)
        assertEquals(listOf("Option A", "Option B"), msg.guidanceCards)
    }

    @Test
    fun `AddPromotionRequest carries promotionId`() {
        val msg = SdkMessage.AddPromotionRequest(correlationId = "c", timestamp = 0L, promotionId = "PROMO-1")
        assertEquals("PROMO-1", msg.promotionId)
    }

    @Test
    fun `PromotionMessageRequest carries all promotional fields`() {
        val msg = SdkMessage.PromotionMessageRequest(
            correlationId = "c",
            timestamp = 0L,
            promotionId = "P1",
            title = "Summer Sale",
            gain = "20% off",
            description = "All items discounted",
            imageUrl = "https://example.com/promo.jpg",
            footer = "Limited time offer",
        )
        assertEquals("P1", msg.promotionId)
        assertEquals("Summer Sale", msg.title)
        assertEquals("20% off", msg.gain)
        assertEquals("Limited time offer", msg.footer)
    }

    @Test
    fun `ProductMessageRequest default orientation is UNSPECIFIED`() {
        val msg = SdkMessage.ProductMessageRequest(correlationId = "c", timestamp = 0L)
        assertEquals(ProductOrientation.UNSPECIFIED, msg.orientation)
        assertEquals(emptyList(), msg.products)
    }

    @Test
    fun `ProductMessageRequest horizontal orientation — carousel`() {
        val product = Product(sku = "S1", name = "Widget", price = 1.0, unitName = "unit")
        val msg = SdkMessage.ProductMessageRequest(
            correlationId = "c",
            timestamp = 0L,
            products = listOf(product),
            orientation = ProductOrientation.HORIZONTAL,
        )
        assertEquals(ProductOrientation.HORIZONTAL, msg.orientation)
        assertEquals(1, msg.products.size)
        assertEquals("S1", msg.products[0].sku)
    }

    @Test
    fun `ChatStatusRequest carries status string`() {
        val msg = SdkMessage.ChatStatusRequest(correlationId = "c", timestamp = 0L, status = "TYPING")
        assertEquals("TYPING", msg.status)
    }

    @Test
    fun `CustomActionRequest carries actionId and payload`() {
        val msg = SdkMessage.CustomActionRequest(
            correlationId = "c",
            timestamp = 0L,
            actionId = "OPEN_CART",
            payload = """{"key":"value"}""",
        )
        assertEquals("OPEN_CART", msg.actionId)
        assertEquals("""{"key":"value"}""", msg.payload)
    }

    @Test
    fun `CustomActionResponse carries status and payload`() {
        val msg = SdkMessage.CustomActionResponse(
            correlationId = "c",
            timestamp = 0L,
            status = ResponseStatus.SUCCESS,
            payload = """{"result":"ok"}""",
        )
        assertEquals(ResponseStatus.SUCCESS, msg.status)
        assertEquals("""{"result":"ok"}""", msg.payload)
    }

    // -------------------------------------------------------------------------
    // Exhaustive when — verifies sealed hierarchy is complete
    // -------------------------------------------------------------------------

    @Test
    fun `when expression over SdkMessage is exhaustive for all 26 subtypes`() {
        val messages: List<SdkMessage> = listOf(
            SdkMessage.TextMessageRequest("c", 0L, TextMessage(timestamp = 0L, text = "t")),
            SdkMessage.TextMessageResponse("c", 0L, ResponseStatus.SUCCESS, "m"),
            SdkMessage.VoiceMessageRequest("c", 0L, VoiceMessage(timestamp = 0L, mediaUrl = "u", duration = 1.0, mediaType = "audio/ogg")),
            SdkMessage.VoiceMessageResponse("c", 0L, ResponseStatus.SUCCESS, "m"),
            SdkMessage.ImageMessageRequest("c", 0L, ImageMessage(timestamp = 0L, mediaUrl = "u", mediaType = "image/jpeg")),
            SdkMessage.ImageMessageResponse("c", 0L, ResponseStatus.SUCCESS, "m"),
            SdkMessage.MessageReceiptRequest("c", 0L, MessageStatus.DELIVERED, "m"),
            SdkMessage.MessageReceiptResponse("c", 0L, ResponseStatus.SUCCESS),
            SdkMessage.AddToCartRequest("c", 0L, "sku", 1.0),
            SdkMessage.AddToCartResponse("c", 0L, ResponseStatus.SUCCESS),
            SdkMessage.RemoveFromCartRequest("c", 0L, "sku"),
            SdkMessage.RemoveFromCartResponse("c", 0L, ResponseStatus.SUCCESS),
            SdkMessage.ClearCartRequest("c", 0L),
            SdkMessage.ClearCartResponse("c", 0L, ResponseStatus.SUCCESS),
            SdkMessage.GuidanceCardRequest("c", 0L),
            SdkMessage.GuidanceCardResponse("c", 0L, ResponseStatus.SUCCESS, "title", "desc"),
            SdkMessage.AddPromotionRequest("c", 0L, "promo"),
            SdkMessage.AddPromotionResponse("c", 0L, ResponseStatus.SUCCESS),
            SdkMessage.PromotionMessageRequest("c", 0L, "p", "title", "gain", "desc", "url", "footer"),
            SdkMessage.PromotionMessageResponse("c", 0L, ResponseStatus.SUCCESS),
            SdkMessage.ProductMessageRequest("c", 0L),
            SdkMessage.ProductMessageResponse("c", 0L, ResponseStatus.SUCCESS),
            SdkMessage.ChatStatusRequest("c", 0L, "status"),
            SdkMessage.ChatStatusResponse("c", 0L, ResponseStatus.SUCCESS),
            SdkMessage.CustomActionRequest("c", 0L, "actionId", "payload"),
            SdkMessage.CustomActionResponse("c", 0L, ResponseStatus.SUCCESS, "payload"),
        )

        assertEquals(26, messages.size)

        // The when must be exhaustive — compiler enforces this at the call site.
        val handled = messages.map { msg ->
            when (msg) {
                is SdkMessage.TextMessageRequest -> "TextMessageRequest"
                is SdkMessage.TextMessageResponse -> "TextMessageResponse"
                is SdkMessage.VoiceMessageRequest -> "VoiceMessageRequest"
                is SdkMessage.VoiceMessageResponse -> "VoiceMessageResponse"
                is SdkMessage.ImageMessageRequest -> "ImageMessageRequest"
                is SdkMessage.ImageMessageResponse -> "ImageMessageResponse"
                is SdkMessage.MessageReceiptRequest -> "MessageReceiptRequest"
                is SdkMessage.MessageReceiptResponse -> "MessageReceiptResponse"
                is SdkMessage.AddToCartRequest -> "AddToCartRequest"
                is SdkMessage.AddToCartResponse -> "AddToCartResponse"
                is SdkMessage.RemoveFromCartRequest -> "RemoveFromCartRequest"
                is SdkMessage.RemoveFromCartResponse -> "RemoveFromCartResponse"
                is SdkMessage.ClearCartRequest -> "ClearCartRequest"
                is SdkMessage.ClearCartResponse -> "ClearCartResponse"
                is SdkMessage.GuidanceCardRequest -> "GuidanceCardRequest"
                is SdkMessage.GuidanceCardResponse -> "GuidanceCardResponse"
                is SdkMessage.AddPromotionRequest -> "AddPromotionRequest"
                is SdkMessage.AddPromotionResponse -> "AddPromotionResponse"
                is SdkMessage.PromotionMessageRequest -> "PromotionMessageRequest"
                is SdkMessage.PromotionMessageResponse -> "PromotionMessageResponse"
                is SdkMessage.ProductMessageRequest -> "ProductMessageRequest"
                is SdkMessage.ProductMessageResponse -> "ProductMessageResponse"
                is SdkMessage.ChatStatusRequest -> "ChatStatusRequest"
                is SdkMessage.ChatStatusResponse -> "ChatStatusResponse"
                is SdkMessage.CustomActionRequest -> "CustomActionRequest"
                is SdkMessage.CustomActionResponse -> "CustomActionResponse"
            }
        }

        assertEquals(26, handled.size)
        assertEquals("TextMessageRequest", handled[0])
        assertEquals("CustomActionResponse", handled[25])
    }
}

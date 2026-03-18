// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of SdkMessage from proto/events/external_channel/in_app/sdk/sdk_message.proto
//
// SdkMessage is the top-level sealed class sent over the bidirectional stream.
// Each subclass corresponds to exactly one payload field of the proto oneof.
// Timestamps are epoch millis (Long) throughout the Android SDK — avoids java.util.Date
// and keeps the class pure-JVM for unit tests without Android dependencies.
//
// The sealed class hierarchy replaces the protobuf oneof:
//   SdkMessage — common envelope fields (correlationId, timestamp)
//     Bidirectional
//       TextMessageRequest / TextMessageResponse
//       VoiceMessageRequest / VoiceMessageResponse
//       ImageMessageRequest / ImageMessageResponse
//       MessageReceiptRequest / MessageReceiptResponse
//     Client → Channel
//       AddToCartRequest / AddToCartResponse
//       RemoveFromCartRequest / RemoveFromCartResponse
//       ClearCartRequest / ClearCartResponse
//       GuidanceCardRequest / GuidanceCardResponse
//       AddPromotionRequest / AddPromotionResponse
//     Channel → Client
//       PromotionMessageRequest / PromotionMessageResponse
//       ProductMessageRequest / ProductMessageResponse
//       ChatStatusRequest / ChatStatusResponse
//       CustomActionRequest / CustomActionResponse
sealed class SdkMessage {
    abstract val correlationId: String
    abstract val timestamp: Long

    // -------------------------------------------------------------------------
    // Bidirectional — Text
    // -------------------------------------------------------------------------

    data class TextMessageRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val content: TextMessage,
    ) : SdkMessage()

    data class TextMessageResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
        val messageId: String,
    ) : SdkMessage()

    // -------------------------------------------------------------------------
    // Bidirectional — Voice
    // -------------------------------------------------------------------------

    data class VoiceMessageRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val content: VoiceMessage,
        val quickReplies: List<String> = emptyList(),
    ) : SdkMessage()

    data class VoiceMessageResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
        val messageId: String,
    ) : SdkMessage()

    // -------------------------------------------------------------------------
    // Bidirectional — Image
    // -------------------------------------------------------------------------

    data class ImageMessageRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val content: ImageMessage,
        val quickReplies: List<String> = emptyList(),
    ) : SdkMessage()

    data class ImageMessageResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
        val messageId: String,
    ) : SdkMessage()

    // -------------------------------------------------------------------------
    // Bidirectional — Receipt
    // -------------------------------------------------------------------------

    data class MessageReceiptRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val status: MessageStatus,
        val messageId: String,
        val quickReplies: List<String> = emptyList(),
    ) : SdkMessage()

    data class MessageReceiptResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
    ) : SdkMessage()

    // -------------------------------------------------------------------------
    // Client → Channel — Cart
    // -------------------------------------------------------------------------

    data class AddToCartRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val sku: String,
        val quantity: Double,
    ) : SdkMessage()

    data class AddToCartResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
    ) : SdkMessage()

    data class RemoveFromCartRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val sku: String,
        // Null means the entire SKU line is removed.
        val quantity: Double? = null,
    ) : SdkMessage()

    data class RemoveFromCartResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
    ) : SdkMessage()

    data class ClearCartRequest(
        override val correlationId: String,
        override val timestamp: Long,
    ) : SdkMessage()

    data class ClearCartResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
    ) : SdkMessage()

    // -------------------------------------------------------------------------
    // Client → Channel — Guidance cards
    // -------------------------------------------------------------------------

    data class GuidanceCardRequest(
        override val correlationId: String,
        override val timestamp: Long,
    ) : SdkMessage()

    data class GuidanceCardResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
        val guidanceTitle: String,
        val guidanceDescription: String,
        val guidanceCards: List<String> = emptyList(),
    ) : SdkMessage()

    // -------------------------------------------------------------------------
    // Client → Channel — Promotions
    // -------------------------------------------------------------------------

    data class AddPromotionRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val promotionId: String,
    ) : SdkMessage()

    data class AddPromotionResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
    ) : SdkMessage()

    // -------------------------------------------------------------------------
    // Channel → Client — Promotion message
    // -------------------------------------------------------------------------

    data class PromotionMessageRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val promotionId: String,
        val title: String,
        val gain: String,
        val description: String,
        val imageUrl: String,
        val footer: String,
    ) : SdkMessage()

    data class PromotionMessageResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
    ) : SdkMessage()

    // -------------------------------------------------------------------------
    // Channel → Client — Product message
    // -------------------------------------------------------------------------

    data class ProductMessageRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val products: List<Product> = emptyList(),
        val orientation: ProductOrientation = ProductOrientation.UNSPECIFIED,
    ) : SdkMessage()

    data class ProductMessageResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
    ) : SdkMessage()

    // -------------------------------------------------------------------------
    // Channel → Client — Chat status
    // -------------------------------------------------------------------------

    data class ChatStatusRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val status: String,
    ) : SdkMessage()

    data class ChatStatusResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
    ) : SdkMessage()

    // -------------------------------------------------------------------------
    // Channel → Client — Custom action
    // -------------------------------------------------------------------------

    data class CustomActionRequest(
        override val correlationId: String,
        override val timestamp: Long,
        val actionId: String,
        val payload: String,
    ) : SdkMessage()

    data class CustomActionResponse(
        override val correlationId: String,
        override val timestamp: Long,
        val status: ResponseStatus,
        val payload: String,
    ) : SdkMessage()
}

// ---------------------------------------------------------------------------
// Payload content types — used inside SdkMessage subclasses
// ---------------------------------------------------------------------------

// TextMessage holds the payload of a plain-text conversation turn.
data class TextMessage(
    val messageId: String? = null,
    val timestamp: Long,
    val text: String,
    val status: MessageStatus = MessageStatus.UNSPECIFIED,
    val role: MessageRole = MessageRole.UNSPECIFIED,
)

// VoiceMessage holds the payload of a voice-note conversation turn.
data class VoiceMessage(
    val messageId: String? = null,
    val timestamp: Long,
    val mediaUrl: String,
    // Amplitude samples used to render the waveform preview in the UI.
    val amplitudesPreview: List<Float> = emptyList(),
    val duration: Double,
    val mediaType: String,
    val status: MessageStatus = MessageStatus.UNSPECIFIED,
    val role: MessageRole = MessageRole.UNSPECIFIED,
)

// ImageMessage holds the payload of an image conversation turn.
data class ImageMessage(
    val messageId: String? = null,
    val timestamp: Long,
    val text: String? = null,
    val mediaUrl: String,
    val mediaType: String,
    val status: MessageStatus = MessageStatus.UNSPECIFIED,
    val role: MessageRole = MessageRole.UNSPECIFIED,
)

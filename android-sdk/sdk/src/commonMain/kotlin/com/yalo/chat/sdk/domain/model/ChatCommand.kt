// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of flutter-sdk/lib/domain/models/command/chat_command.dart.
// Client → Channel commands: instead of sending these actions through the default API,
// host apps can register a callback via YaloChat.registerCommand() to handle them locally.
enum class ChatCommand {
    AddToCart,
    RemoveFromCart,
    ClearCart,
    GuidanceCard,
    AddPromotion,
}

// Payload is a Map<String, Any?> for parameterised commands, or null for no-parameter ones:
//   AddToCart      → mapOf("sku" to String, "quantity" to Double)
//   RemoveFromCart → mapOf("sku" to String, "quantity" to Double?)
//   AddPromotion   → mapOf("promotionId" to String)
//   ClearCart      → null
//   GuidanceCard   → null
typealias ChatCommandCallback = (payload: Any?) -> Unit

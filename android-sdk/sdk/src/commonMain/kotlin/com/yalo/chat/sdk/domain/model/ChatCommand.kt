// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of flutter-sdk/lib/domain/models/command/chat_command.dart.
// Client → Channel commands: instead of sending these actions through the default API,
// host apps can register a callback via YaloChat.registerCommand() to handle them locally.
enum class ChatCommand {
    ADD_TO_CART,
    REMOVE_FROM_CART,
    CLEAR_CART,
    GUIDANCE_CARD,    // reserved — not yet dispatched by the SDK; callbacks will never fire
    ADD_PROMOTION,
}

// Typed alias for the payload map. Parameterised commands receive a map with these shapes:
//   ADD_TO_CART      → mapOf("sku" to String, "quantity" to Double)
//   REMOVE_FROM_CART → mapOf("sku" to String, "quantity" to Double?)
//   ADD_PROMOTION    → mapOf("promotionId" to String)
//   CLEAR_CART       → null
//   GUIDANCE_CARD    → null
typealias ChatCommandCallback = (payload: Map<String, Any?>?) -> Unit

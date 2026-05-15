// Copyright (c) Yalochat, Inc. All rights reserved.

import ChatSdk

/// Associates a ``ChatCommand`` with a host-app handler.
/// Pass an array to ``YaloChat/initialize`` to intercept SDK cart and promotion
/// operations instead of routing them through the default API.
///
/// Payload keys per command:
///   - ADD_TO_CART:      `["sku": String, "quantity": Double, "unitType": Any?]`
///   - REMOVE_FROM_CART: `["sku": String, "quantity": Double?, "unitType": Any?]`
///   - ADD_PROMOTION:    `["promotionId": String]`
///   - CLEAR_CART:       nil
///   - GUIDANCE_CARD:    nil (reserved — callback will not fire)
public struct YaloChatAction {
    public let command: ChatCommand
    public let callback: ([AnyHashable: Any]?) -> Void

    public init(command: ChatCommand, callback: @escaping ([AnyHashable: Any]?) -> Void) {
        self.command = command
        self.callback = callback
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.

/// The channel asking the host app to run `commandId` with `payload`.
/// `correlationId` goes back on the answer so the channel can match it, and
/// `kind` says which response the answer has to be.
struct CommandRequest: Equatable, Sendable {
    enum Kind: Sendable {
        case custom
        case getCart
        case updateCartProduct
    }

    let correlationId: String
    let commandId: String
    let payload: String
    var kind: Kind = .custom
}

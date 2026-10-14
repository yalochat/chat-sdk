// Copyright (c) Yalochat, Inc. All rights reserved.

/// The channel asking the host app to run `commandId` with `payload`.
/// `correlationId` goes back on the answer so the channel can match it.
struct CommandRequest: Equatable, Sendable {
    let correlationId: String
    let commandId: String
    let payload: String
}

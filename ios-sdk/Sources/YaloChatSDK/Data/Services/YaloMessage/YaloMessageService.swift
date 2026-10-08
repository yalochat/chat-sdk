// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import YaloChatProto

typealias SdkMessage = Yalo_ExternalChannel_InApp_Sdk_V2_SdkMessage
typealias PollMessageItem = Yalo_ExternalChannel_InApp_Sdk_V2_PollMessageItem

/// Carries a conversation between the device and the channel.
protocol YaloMessageService: Sendable {
    /// What the channel sends from now on. Every call is a listener of its
    /// own, and nothing sent before it is replayed.
    func messages() async -> AsyncStream<PollMessageItem>

    /// Opens one connection with `token` and reads from it until it dies.
    /// Answers whether the backend ever accepted it. Retrying is up to the
    /// caller, and cancelling the call is what ends the connection.
    func run(token: String) async -> Bool

    /// Takes `message` for the channel. One sent while no connection is up
    /// waits for the next one.
    func send(_ message: SdkMessage) async throws

    /// Forgets whatever was waiting to be sent.
    func close() async
}

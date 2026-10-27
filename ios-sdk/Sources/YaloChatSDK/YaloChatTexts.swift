// Copyright (c) Yalochat, Inc. All rights reserved.

/// Your own copy for strings the chat would otherwise show in its built-in
/// translations. Named after the same setting in the web SDK so the two read
/// alike.
///
/// A string given here is shown exactly as given whatever the device language,
/// so translating it is up to the app. Leave a field nil to keep the built-in
/// translation.
///
/// - `inputPlaceholder`: what the message input shows while it is empty.
public struct YaloChatTexts: Sendable, Equatable {
    public let inputPlaceholder: String?

    public init(inputPlaceholder: String? = nil) {
        self.inputPlaceholder = inputPlaceholder
    }
}

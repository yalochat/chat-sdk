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
/// - `imageNotAllowed`: the title of the alert shown when a picked picture is
///   turned away because its name is not allowed.
/// - `invalidImageAlertButtonText`: the button that closes that alert.
/// - `writingIndicator`: the text shown while a reply is being written, with
///   `typingIndicatorType` set to `.text`. Defaults to "Writing...".
public struct YaloChatTexts: Sendable, Equatable {
    public let inputPlaceholder: String?
    public let imageNotAllowed: String?
    public let invalidImageAlertButtonText: String?
    public let writingIndicator: String?

    public init(
        inputPlaceholder: String? = nil,
        imageNotAllowed: String? = nil,
        invalidImageAlertButtonText: String? = nil,
        writingIndicator: String? = nil
    ) {
        self.inputPlaceholder = inputPlaceholder
        self.imageNotAllowed = imageNotAllowed
        self.invalidImageAlertButtonText = invalidImageAlertButtonText
        self.writingIndicator = writingIndicator
    }
}

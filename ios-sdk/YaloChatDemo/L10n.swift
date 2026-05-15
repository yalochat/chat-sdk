// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

// Single source for all SDK localized string keys.
// To swap the localization backend, change string(_:) only.
private func string(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

enum L10n {
    static let noMessagesYet      = string("chat.no_messages_yet")
    static let unsupportedMessage = string("chat.unsupported_message_type")
    static let imageUnavailable   = string("chat.image_unavailable")
    static let videoUnavailable   = string("chat.video_unavailable")
    static let imageSaveError     = string("chat.image_save_error")
    static let defaultChannelName = string("chat.default_channel_name")
    static let attachImageTitle   = string("chat.attach_image_title")
    static let photoLibrary       = string("chat.photo_library")
    static let camera             = string("chat.camera")
    static let cancel             = string("chat.cancel")
    static let inputPlaceholder   = string("chat.input_placeholder")
}

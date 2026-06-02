// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

// Single source for all SDK localized string keys.
// Bundle.module is the SPM-generated resource bundle; the main bundle is used
// when the sources are compiled directly into an Xcode app target (e.g. demo app).
private func string(_ key: String) -> String {
    #if SWIFT_PACKAGE
    NSLocalizedString(key, bundle: .module, comment: "")
    #else
    NSLocalizedString(key, comment: "")
    #endif
}

enum Translate {
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
    static let retry              = string("chat.retry")
    static let showMore           = string("chat.show_more")
    static let showLess           = string("chat.show_less")
    static let notDelivered       = string("chat.not_delivered")
    static let writingMessage     = string("chat.writing_message")
}

// Copyright (c) Yalochat, Inc. All rights reserved.

import UIKit

/// What is drawn in a circle beside a message.
public enum YaloChatMessageAvatar: Sendable, Equatable {
    /// Nothing, and no room is kept for it.
    case none

    /// A couple of letters, for example `"JR"`. Only the first 2 characters
    /// are shown, as given.
    case text(String)

    /// A picture filling the circle.
    case image(UIImage)
}

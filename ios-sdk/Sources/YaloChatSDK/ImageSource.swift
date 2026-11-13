// Copyright (c) Yalochat, Inc. All rights reserved.

/// Where the pictures a person sends may come from.
public enum ImageSource: Sendable, Equatable {
    /// Anywhere in the photo library.
    case all

    /// Only screenshots. The photo picker shows nothing else.
    case screenshots
}

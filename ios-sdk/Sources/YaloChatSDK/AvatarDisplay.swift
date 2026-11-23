// Copyright (c) Yalochat, Inc. All rights reserved.

/// Which messages carry their avatar.
public enum AvatarDisplay: Sendable, Equatable {
    /// Only the newest message of a run sent by the same side, like most
    /// messaging apps. The other messages of the run keep the room it takes,
    /// so they line up.
    case lastInGroup

    /// Every message.
    case everyMessage
}

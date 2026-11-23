// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

/**
 * Which messages get the avatar of their side. Named after the same setting in
 * the web SDK so the two read alike.
 */
public enum class AvatarDisplay {

    /**
     * Only the newest message of a run sent by the same side, the way most
     * messaging apps group messages. The others keep the room the avatar takes,
     * so the bubbles stay lined up.
     */
    LastInGroup,

    /** Every message. */
    EveryMessage,
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

import android.graphics.Bitmap

/**
 * The small round picture drawn beside the messages of one side of the
 * conversation, so each bubble looks like it comes from it. Named after the
 * same setting in the web SDK so the two read alike.
 */
public sealed interface YaloChatMessageAvatar {

    /** No avatar, and no room kept for one. */
    public data object None : YaloChatMessageAvatar

    /**
     * Text in a circle, for example `JR` for Jose Rodrigo. At most the first 2
     * characters are shown, as given.
     */
    public data class Text(public val text: String) : YaloChatMessageAvatar

    /** A picture cropped to a circle. */
    public data class Image(public val image: Bitmap) : YaloChatMessageAvatar
}

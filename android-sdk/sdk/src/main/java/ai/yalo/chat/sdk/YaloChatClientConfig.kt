// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk


public data class YaloChatClientConfig(
    public val channelId: String,
    public val organizationId: String,
    public val channelName: String,
    public val userId: String? = null,
) {

    /**
     * The conversation this config points at.
     *
     * An app can show several chats at once, and two of them are the same
     * conversation when they resolve to the same session. Everything scoped to
     * a conversation keys off this: the view model an open chat gets, and the
     * rows a single shared database hands back.
     *
     * Built the same way as `computeSessionId` in the web SDK so both clients
     * agree on what one session is. The web SDK also appends an `openContext`
     * hash in `perContext` mode and a token in `ephemeral` mode; neither mode
     * exists here yet, and this has to grow the same way when they arrive.
     */
    internal val sessionId: String
        get() = "$organizationId-$channelId-${userId ?: "anonymous"}"
}

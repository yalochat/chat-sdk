// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

/**
 * The details of one conversation.
 *
 * @property openContext What the chat is being opened from, for example the
 * product a person was looking at. It is sent to the channel when the chat
 * opens on an empty conversation, so the first thing said can be about what
 * the person is doing rather than a generic greeting. Fixed for the life of
 * the client.
 * @property hideVoiceButton Whether the microphone is left out of the message
 * input. With it on, the send button is always there instead of appearing once
 * something has been typed, and nobody can record a voice message. Named after
 * the same setting in the web SDK so the two read alike.
 */
public data class YaloChatClientConfig(
    public val channelId: String,
    public val organizationId: String,
    public val channelName: String,
    public val userId: String? = null,
    public val quickReplyType: QuickReplyType = QuickReplyType.Modal,
    public val logLevel: LogLevel = LogLevel.Warn,
    public val openContext: Map<String, String> = emptyMap(),
    public val hideVoiceButton: Boolean = false,
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

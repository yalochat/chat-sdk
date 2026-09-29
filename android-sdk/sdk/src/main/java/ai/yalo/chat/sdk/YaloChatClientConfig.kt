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
 * @property sessionMode How the conversation is scoped, and whether it is
 * remembered between visits. Defaults to [SessionMode.Shared], which is one
 * conversation per person, remembered. Named after the same setting in the web
 * SDK so the two read alike.
 * @property hideVoiceButton Whether the microphone is left out of the message
 * input. With it on, the send button is always there instead of appearing once
 * something has been typed, and nobody can record a voice message. Named after
 * the same setting in the web SDK so the two read alike.
 * @property hideAttachmentButton Whether the plus is left out of the message
 * input. With it on, nobody can pick a picture to send. Pictures the channel
 * sends are still shown. Named after the same setting in the web SDK so the two
 * read alike.
 * @property hideWatermark Whether the "By Yalo" line under the channel name is
 * left out of the header. Everything else in the header stays where it is.
 */
public data class YaloChatClientConfig(
    public val channelId: String,
    public val organizationId: String,
    public val channelName: String,
    public val userId: String? = null,
    public val quickReplyType: QuickReplyType = QuickReplyType.Modal,
    public val logLevel: LogLevel = LogLevel.Warn,
    public val openContext: Map<String, String> = emptyMap(),
    public val sessionMode: SessionMode = SessionMode.Shared,
    public val hideVoiceButton: Boolean = false,
    public val hideAttachmentButton: Boolean = false,
    public val hideWatermark: Boolean = false,
) {

    /**
     * The conversation this config points at before [sessionMode] has had its
     * say.
     *
     * This is the whole session in [SessionMode.Shared] and the start of it in
     * the other modes, which add what tells two of their conversations apart.
     * Everything scoped to a conversation keys off the session built from it:
     * the view model an open chat gets, and the rows a single shared database
     * hands back.
     *
     * Built the same way as `computeSessionId` in the web SDK so both clients
     * agree on what one session is.
     */
    internal val baseSessionId: String
        get() = "$organizationId-$channelId-${userId ?: "anonymous"}"
}

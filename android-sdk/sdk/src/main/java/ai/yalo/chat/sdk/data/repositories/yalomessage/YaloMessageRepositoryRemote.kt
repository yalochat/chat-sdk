// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.yalomessage

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.data.datasources.message.MessageReceived
import ai.yalo.chat.sdk.data.datasources.message.WireFormat
import ai.yalo.chat.sdk.data.datasources.message.timestampOf
import ai.yalo.chat.sdk.data.datasources.message.toEpochMillis
import ai.yalo.chat.sdk.data.datasources.message.YaloMessageDataSource
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.CommandRequest
import ai.yalo.chat.sdk.domain.models.FeedbackRating
import ai.yalo.chat.sdk.domain.models.ImageAttachment
import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.domain.models.MessageButtonType
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.domain.models.VoiceNote
import ai.yalo.chat.sdk.log.YaloLog
import ai.yalo.chat.sdk.internal.proto.v2.CustomCommandResponse
import ai.yalo.chat.sdk.internal.proto.v2.GetCartResponse
import ai.yalo.chat.sdk.internal.proto.v2.GuidanceCardRequest
import ai.yalo.chat.sdk.internal.proto.v2.ImageMessage
import ai.yalo.chat.sdk.internal.proto.v2.ImageMessageRequest
import ai.yalo.chat.sdk.internal.proto.v2.MessageFeedbackRequest
import ai.yalo.chat.sdk.internal.proto.v2.MessageStatus
import ai.yalo.chat.sdk.internal.proto.v2.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.ResponseStatus
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.TextMessage
import ai.yalo.chat.sdk.internal.proto.v2.TextMessageRequest
import ai.yalo.chat.sdk.internal.proto.v2.Timestamp
import ai.yalo.chat.sdk.internal.proto.v2.UpdateCartProductResponse
import ai.yalo.chat.sdk.internal.proto.v2.VoiceMessage
import ai.yalo.chat.sdk.internal.proto.v2.VoiceNoteMessageRequest
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.filterIsInstance
import kotlinx.coroutines.flow.mapNotNull
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.util.UUID
import kotlin.time.Duration.Companion.milliseconds
import ai.yalo.chat.sdk.domain.models.MessageStatus as ChatStatus
import ai.yalo.chat.sdk.internal.proto.v2.ButtonType as WireButtonType
import ai.yalo.chat.sdk.internal.proto.v2.FeedbackRating as WireRating
import ai.yalo.chat.sdk.internal.proto.v2.MessageRole as WireRole

/**
 * Says what the chat means in the wire format, and keeps a line open to say it
 * on.
 *
 * The wire format stops here: above this a message is a [ChatMessage], below it
 * an `SdkMessage`, and neither side has to know about the other.
 *
 * Keeping the line up is decided here as well. One socket lasts as long as it
 * lasts, and when it dies this asks [auth] for a token and has another opened,
 * waiting a little longer before each attempt that gets nowhere. The data
 * source is handed the token and never learns where it came from.
 *
 * [connect], [pause], [resume] and [close] are handed to [scope] rather than
 * made to suspend, because the callers are a view model being built, cleared or
 * told the app went away, and none of those can wait.
 */
internal class YaloMessageRepositoryRemote(
    private val source: YaloMessageDataSource,
    private val auth: TokenRepository,
    private val scope: CoroutineScope,
    private val now: () -> Long = System::currentTimeMillis,
    private val correlationIds: () -> String = { UUID.randomUUID().toString() },
    logLevel: LogLevel = LogLevel.Warn,
) : YaloMessageRepository {

    private val log = YaloLog(LOG_NAME, logLevel)

    // Guards the lifecycle and the coroutine holding the line, which the four
    // calls below and a message being sent all reach for.
    private val mutex = Mutex()

    private var lifecycle: Lifecycle = Lifecycle.Closed

    /** Opens sockets for as long as it runs, so cancelling it is what stops. */
    private var connecting: Job? = null

    override fun connect() {
        scope.launch {
            mutex.withLock {
                if (lifecycle != Lifecycle.Closed) {
                    return@launch
                }
                lifecycle = Lifecycle.Running
                log.info { "connecting" }
                connecting = scope.launch { connectUntilStopped() }
            }
        }
    }

    override fun pause() {
        scope.launch {
            val running = mutex.withLock {
                if (lifecycle != Lifecycle.Running) {
                    return@launch
                }
                lifecycle = Lifecycle.Paused
                log.info { "pausing, the app went away" }
                connecting.also { connecting = null }
            }
            running?.cancelAndJoin()
        }
    }

    override fun resume() {
        scope.launch {
            mutex.withLock {
                if (lifecycle != Lifecycle.Paused) {
                    return@launch
                }
                lifecycle = Lifecycle.Running
                log.info { "resuming" }
                connecting = scope.launch { connectUntilStopped() }
            }
        }
    }

    override suspend fun reconnect() {
        mutex.withLock {
            if (lifecycle == Lifecycle.Closed) {
                return
            }
            log.info { "reconnecting" }
            connecting?.cancelAndJoin()
            source.close()
            // A paused line picks up the new token once it resumes.
            connecting = if (lifecycle == Lifecycle.Running) {
                scope.launch { connectUntilStopped() }
            } else {
                null
            }
        }
    }

    /**
     * Opens one socket after another for as long as the chat is open.
     *
     * A token is fetched for every attempt rather than once, because the one
     * that opened the last socket may have run out while it was up.
     */
    private suspend fun connectUntilStopped() {
        var attempt = FIRST_ATTEMPT
        while (true) {
            val token = auth.token().getOrElse { cause ->
                log.warn(cause) { "no token, so no socket" }
                null
            }
            if (token == null) {
                attempt = waitBefore(attempt)
                continue
            }
            // A socket that opened has shown the line works, so the waits start
            // over even when it died a moment later.
            val opened = source.runSession(token)
            attempt = waitBefore(if (opened) FIRST_ATTEMPT else attempt)
        }
    }

    /** Waits out the delay owed after [attempt], and answers with the attempt after it. */
    private suspend fun waitBefore(attempt: Int): Int {
        val delayMillis = minOf(MAX_BACKOFF_MILLIS, INITIAL_BACKOFF_MILLIS shl attempt)
        log.info { "reconnecting in ${delayMillis}ms" }
        delay(delayMillis.milliseconds)
        // Counting past the point where the delay stops growing keeps the shift
        // that computes it honest.
        return (attempt + 1).coerceAtMost(MAX_ATTEMPT)
    }

    /** Only what the channel said, never an acknowledgement. */
    override fun messages(): Flow<ChatMessage> = source.messages
        .filterIsInstance<MessageReceived>()
        .mapNotNull { received -> chatMessageOf(received.item) }

    override suspend fun send(message: ChatMessage): Result<Unit> {
        val payload = sdkMessageOf(message)
            ?: return Result.failure(UnsupportedMessageTypeException(message.type))
        return write(payload)
    }

    /**
     * Asks the channel to open the conversation, telling it what the chat was
     * opened from.
     *
     * The answer is not returned here. What the channel makes of the context
     * comes back as ordinary messages, the same way anything else it says does.
     */
    override suspend fun requestGuidanceCard(openContext: Map<String, String>): Result<Unit> {
        val askedAt = timestampOf(now())
        return write(
            SdkMessage(
                correlation_id = correlationIds(),
                timestamp = askedAt,
                guidance_card_request = GuidanceCardRequest(
                    timestamp = askedAt,
                    // Nothing to go on is said by leaving the field out, rather
                    // than by sending an empty object the channel would have to
                    // read and discard.
                    context = jsonOf(openContext).takeIf { openContext.isNotEmpty() },
                ),
            ),
        )
    }

    /**
     * The channel keeps the rating with the latest timestamp for a message, so
     * a change of mind is just another request.
     */
    override suspend fun sendFeedback(messageId: String, rating: FeedbackRating?): Result<Unit> {
        val ratedAt = timestampOf(now())
        return write(
            SdkMessage(
                correlation_id = correlationIds(),
                timestamp = ratedAt,
                message_feedback_request = MessageFeedbackRequest(
                    message_id = messageId,
                    rating = wireRatingOf(rating),
                    timestamp = ratedAt,
                ),
            ),
        )
    }

    private fun wireRatingOf(rating: FeedbackRating?): WireRating = when (rating) {
        FeedbackRating.ThumbsUp -> WireRating.FEEDBACK_RATING_THUMBS_UP
        FeedbackRating.ThumbsDown -> WireRating.FEEDBACK_RATING_THUMBS_DOWN
        null -> WireRating.FEEDBACK_RATING_UNSPECIFIED
    }

    override fun commandRequests(): Flow<CommandRequest> = source.messages
        .filterIsInstance<MessageReceived>()
        .mapNotNull { received -> received.item.message?.let(::commandRequestOf) }

    override suspend fun answerCommand(request: CommandRequest, result: Result<String>): Result<Unit> {
        val answeredAt = timestampOf(now())
        val envelope = SdkMessage(correlation_id = request.correlationId, timestamp = answeredAt)
        return write(
            when (request.kind) {
                CommandRequest.Kind.Custom -> envelope.copy(
                    custom_command_response = CustomCommandResponse(
                        status = statusOf(result),
                        payload = result.getOrDefault(""),
                        timestamp = answeredAt,
                    ),
                )

                CommandRequest.Kind.GetCart -> envelope.copy(
                    get_cart_response = cartPageOf(result).copy(timestamp = answeredAt),
                )

                CommandRequest.Kind.UpdateCartProduct -> envelope.copy(
                    update_cart_product_response = UpdateCartProductResponse(
                        status = statusOf(result),
                        timestamp = answeredAt,
                    ),
                )
            },
        )
    }

    private fun statusOf(result: Result<*>): ResponseStatus = if (result.isSuccess) {
        ResponseStatus.RESPONSE_STATUS_SUCCESS
    } else {
        ResponseStatus.RESPONSE_STATUS_ERROR
    }

    /** The page the host returned as JSON, or a failed answer when it could not be read. */
    private fun cartPageOf(result: Result<String>): GetCartResponse {
        val read = result.mapCatching { json -> WireFormat.read(json, GetCartResponse::class.java) }
        read.exceptionOrNull()?.let { error ->
            if (result.isSuccess) {
                log.warn(error) { "the cart the host returned is not valid JSON" }
            }
        }
        return (read.getOrNull() ?: GetCartResponse()).copy(status = statusOf(read))
    }

    /** A request the host app has to answer, or nothing when [message] is not one. */
    private fun commandRequestOf(message: SdkMessage): CommandRequest? {
        val custom = message.custom_command_request
        val getCart = message.get_cart_request
        val updateCart = message.update_cart_product_request
        return when {
            custom != null -> CommandRequest(
                correlationId = message.correlation_id,
                commandId = custom.command_id,
                payload = custom.payload,
            )

            // The timestamp is the channel's own bookkeeping, so the host gets the
            // fields it acts on.
            getCart != null -> CommandRequest(
                correlationId = message.correlation_id,
                commandId = GET_CART,
                payload = WireFormat.write(getCart.copy(timestamp = null), everyField = true),
                kind = CommandRequest.Kind.GetCart,
            )

            updateCart != null -> CommandRequest(
                correlationId = message.correlation_id,
                commandId = UPDATE_CART_PRODUCT,
                payload = WireFormat.write(updateCart.copy(timestamp = null), everyField = true),
                kind = CommandRequest.Kind.UpdateCartProduct,
            )

            else -> null
        }
    }

    override fun close() {
        scope.launch {
            val running = mutex.withLock {
                lifecycle = Lifecycle.Closed
                log.info { "closing" }
                connecting.also { connecting = null }
            }
            running?.cancelAndJoin()
            source.close()
        }
    }

    /** Nothing is sent, or held to be sent later, once the chat is closed. */
    private suspend fun write(message: SdkMessage): Result<Unit> = mutex.withLock {
        if (lifecycle == Lifecycle.Closed) {
            log.warn { "a message was written while the chat was closed" }
            return@withLock Result.failure(ChatClosedException())
        }
        source.send(message)
    }

    /**
     * Reads a message the channel sent, or nothing when the payload is not one.
     *
     * A kind the chat cannot draw yet still becomes a message of that kind, so
     * nothing arrives silently. Text and images carry a body so far, and an
     * image's body is its caption.
     */
    private fun chatMessageOf(item: PollMessageItem): ChatMessage? {
        val message: SdkMessage = item.message ?: return null
        val type = inboundTypeOf(message) ?: return null
        return ChatMessage(
            role = MessageRole.Agent,
            type = type,
            timestamp = item.date?.toEpochMillis() ?: now(),
            wiId = item.id,
            content = when (type) {
                MessageType.Text -> message.text_message_request?.content?.text.orEmpty()
                MessageType.Image -> message.image_message_request?.content?.text.orEmpty()
                else -> ""
            },
            status = ChatStatus.of(item.status, ChatStatus.Delivered),
            header = headerOf(message),
            footer = footerOf(message),
            buttons = buttonsOf(message),
            voice = message.voice_note_message_request
                ?.let { request -> voiceNoteOf(request.content ?: VoiceMessage()) },
            image = message.image_message_request
                ?.let { request -> imageOf(request.content ?: ImageMessage()) },
        )
    }

    /**
     * The line above a message, and the one below it.
     *
     * Every payload that can carry them keeps them beside the body rather than
     * inside it, the way the options are, so they are read the same way.
     */
    private fun headerOf(message: SdkMessage): String? = message.text_message_request?.header_
        ?: message.image_message_request?.header_
        ?: message.voice_note_message_request?.header_

    private fun footerOf(message: SdkMessage): String? = message.text_message_request?.footer
        ?: message.image_message_request?.footer
        ?: message.voice_note_message_request?.footer

    /**
     * The recording the channel sent, which is an address to download rather
     * than a file that is already here.
     */
    private fun voiceNoteOf(content: VoiceMessage): VoiceNote = VoiceNote(
        durationMillis = (content.duration * MILLIS_PER_SECOND).toLong(),
        amplitudes = content.amplitudes_preview,
        mediaUrl = content.media_url,
        mediaType = content.media_type,
        fileName = content.file_name,
        byteCount = content.byte_count,
    )

    /**
     * The picture the channel sent, which is an address to download rather than
     * a file that is already here.
     */
    private fun imageOf(content: ImageMessage): ImageAttachment = ImageAttachment(
        mediaUrl = content.media_url,
        mediaType = content.media_type,
        fileName = content.file_name,
        byteCount = content.byte_count,
    )

    /**
     * The options attached to a message, whatever kind of message it is.
     *
     * Every payload that can carry them keeps them beside the body rather than
     * inside it, so they are read here even for a kind the chat cannot draw yet.
     */
    private fun buttonsOf(message: SdkMessage): List<MessageButton> {
        val attached = message.text_message_request?.buttons
            ?: message.image_message_request?.buttons
            ?: message.voice_note_message_request?.buttons
            ?: message.video_message_request?.buttons
            ?: message.attachment_message_request?.buttons
            ?: emptyList()
        return attached.map { button ->
            MessageButton(
                text = button.text,
                type = buttonTypeOf(button.button_type),
                url = button.url,
            )
        }
    }

    // A kind this SDK does not know reads as the zero value, which is a reply:
    // the one thing every button can do and the one that stays inside the
    // conversation.
    private fun buttonTypeOf(type: WireButtonType): MessageButtonType = when (type) {
        WireButtonType.BUTTON_TYPE_REPLY -> MessageButtonType.Reply
        WireButtonType.BUTTON_TYPE_POSTBACK -> MessageButtonType.Postback
        WireButtonType.BUTTON_TYPE_LINK -> MessageButtonType.Link
    }

    /**
     * Says [message] in the wire format, or nothing when it is a kind that
     * cannot go out.
     *
     * A voice message with no recording on it is one of those, and so is an
     * image message with no picture: there is nothing for the channel to play
     * or to show, so it is turned away rather than sent empty.
     */
    private fun sdkMessageOf(message: ChatMessage): SdkMessage? {
        val sentAt = timestampOf(now())
        val envelope = SdkMessage(correlation_id = correlationIdOf(message), timestamp = sentAt)
        return when (message.type) {
            MessageType.Text -> envelope.copy(text_message_request = textRequestOf(message, sentAt))

            MessageType.Voice -> message.voice?.let { note ->
                envelope.copy(voice_note_message_request = voiceRequestOf(message, note, sentAt))
            }

            MessageType.Image -> message.image?.let { picture ->
                envelope.copy(image_message_request = imageRequestOf(message, picture, sentAt))
            }

            else -> null
        }
    }

    private fun textRequestOf(message: ChatMessage, sentAt: Timestamp): TextMessageRequest =
        TextMessageRequest(
            timestamp = sentAt,
            content = TextMessage(
                text = message.content,
                // The time the message was written, which is not the time it
                // goes out: one written on a plane is sent when the plane lands.
                timestamp = timestampOf(message.timestamp),
                role = wireRoleOf(message.role),
                // Whatever the stored row says, what is being sent has not
                // arrived anywhere yet.
                status = MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
            ),
        )

    /**
     * A voice note in the wire format.
     *
     * [VoiceNote.mediaUrl] carries the id the upload answered with rather than
     * an address, which is what the channel expects to be told and what the web
     * SDK sends in the same field. The duration is seconds there, not
     * milliseconds.
     */
    private fun voiceRequestOf(
        message: ChatMessage,
        note: VoiceNote,
        sentAt: Timestamp,
    ): VoiceNoteMessageRequest = VoiceNoteMessageRequest(
        timestamp = sentAt,
        content = VoiceMessage(
            timestamp = timestampOf(message.timestamp),
            media_url = note.mediaUrl,
            media_type = note.mediaType,
            file_name = note.fileName,
            byte_count = note.byteCount,
            duration = note.durationMillis / MILLIS_PER_SECOND,
            amplitudes_preview = note.amplitudes,
            role = wireRoleOf(message.role),
            status = MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
        ),
    )

    /**
     * A picture in the wire format.
     *
     * [ImageAttachment.mediaUrl] carries the id the upload answered with rather
     * than an address, the same way a voice note's does, and the caption is the
     * message's own body.
     */
    private fun imageRequestOf(
        message: ChatMessage,
        picture: ImageAttachment,
        sentAt: Timestamp,
    ): ImageMessageRequest = ImageMessageRequest(
        timestamp = sentAt,
        content = ImageMessage(
            timestamp = timestampOf(message.timestamp),
            text = message.content,
            media_url = picture.mediaUrl,
            media_type = picture.mediaType,
            file_name = picture.fileName,
            byte_count = picture.byteCount,
            role = wireRoleOf(message.role),
            status = MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
        ),
    )

    // The local row id doubles as the correlation id, so an acknowledgement
    // coming back names the row it belongs to. A message that was never stored
    // still needs something to be acknowledged by.
    private fun correlationIdOf(message: ChatMessage): String =
        message.id?.toString() ?: correlationIds()

    private fun wireRoleOf(role: MessageRole): WireRole = when (role) {
        MessageRole.User -> WireRole.MESSAGE_ROLE_USER
        MessageRole.Agent -> WireRole.MESSAGE_ROLE_AGENT
    }

    /** What the chat was last asked to do with its line. */
    private enum class Lifecycle { Closed, Running, Paused }

    private companion object {

        private const val LOG_NAME = "Messages"

        private const val GET_CART = "getCart"
        private const val UPDATE_CART_PRODUCT = "updateCartProduct"

        private const val INITIAL_BACKOFF_MILLIS = 1_000L
        private const val MAX_BACKOFF_MILLIS = 30_000L

        private const val FIRST_ATTEMPT = 0
        private const val MAX_ATTEMPT = 5

        /** The wire counts a voice note's length in seconds, the chat in milliseconds. */
        private const val MILLIS_PER_SECOND = 1_000.0
    }
}

/**
 * What the chat calls the payload, when it is one that belongs in the
 * conversation.
 *
 * Anything else, a cart answer for instance, is an exchange rather than
 * something anyone said.
 */
private fun inboundTypeOf(message: SdkMessage): MessageType? = when {
    message.text_message_request != null -> MessageType.Text
    message.image_message_request != null -> MessageType.Image
    message.voice_note_message_request != null -> MessageType.Voice
    message.video_message_request != null -> MessageType.Video
    message.attachment_message_request != null -> MessageType.Attachment
    message.product_message_request != null -> MessageType.Product
    message.product_confirmation_message_request != null -> MessageType.ProductConfirmation
    message.promotion_message_request != null -> MessageType.Promotion
    else -> null
}

/** A kind of message the SDK can hold and show, but cannot yet put on the wire. */
internal class UnsupportedMessageTypeException(type: MessageType) :
    IllegalArgumentException("A ${type.wireName} message cannot be sent yet")

/** Reported when a message is written while the chat is not open. */
internal class ChatClosedException :
    IllegalStateException("The chat is not open, so the message was not taken")

/**
 * The open context as the channel reads it, which is the JSON object the web
 * SDK sends in the same field.
 *
 * Written out here rather than with `JSONObject`, which belongs to the
 * platform and so is not there in a plain unit test, and which does not promise
 * to keep the order the keys were given in. The order is kept because the
 * channel is free to treat the string as one value.
 */
private fun jsonOf(context: Map<String, String>): String = context.entries.joinToString(
    separator = ",",
    prefix = "{",
    postfix = "}",
) { (key, value) -> "${quoted(key)}:${quoted(value)}" }

private fun quoted(text: String): String = buildString {
    append('"')
    for (character in text) {
        when {
            character == '"' -> append("\\\"")
            character == '\\' -> append("\\\\")
            character == '\n' -> append("\\n")
            character == '\r' -> append("\\r")
            character == '\t' -> append("\\t")
            character < ' ' -> append("\\u").append(character.code.toString(16).padStart(4, '0'))
            else -> append(character)
        }
    }
    append('"')
}

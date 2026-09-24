// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.yalomessage

import ai.yalo.chat.sdk.data.services.message.MessageReceived
import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import ai.yalo.chat.sdk.log.YaloLog
import ai.yalo.chat.sdk.data.services.message.MessageConnectionClosedException
import ai.yalo.chat.sdk.data.services.message.YaloMessageService
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.domain.models.MessageButtonType
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.GuidanceCardRequest
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.MessageStatus
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.TextMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.TextMessageRequest
import com.google.protobuf.Timestamp
import com.google.protobuf.util.Timestamps
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.filterIsInstance
import kotlinx.coroutines.flow.mapNotNull
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.launch
import java.util.UUID
import ai.yalo.chat.sdk.domain.models.MessageStatus as ChatStatus
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.Button as WireButton
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.ButtonType as WireButtonType
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.MessageRole as WireRole

/**
 * Says what the chat means in the wire format, and hands it to a
 * [YaloMessageService].
 *
 * The wire format stops here: above this a message is a [ChatMessage], below it
 * an `SdkMessage`, and neither side has to know about the other.
 *
 * [connect] and [close] are handed to [scope] rather than made to suspend,
 * because the two callers are a view model being built and one being cleared,
 * and neither of those can wait.
 */
internal class YaloMessageRepositoryRemote(
    private val service: YaloMessageService,
    private val tokens: TokenRepository,
    private val scope: CoroutineScope,
    private val now: () -> Long = System::currentTimeMillis,
    private val correlationIds: () -> String = { UUID.randomUUID().toString() },
    logLevel: LogLevel = LogLevel.Warn,
) : YaloMessageRepository {

    private val log = YaloLog(LOG_NAME, logLevel)
    private val mutex = Mutex()

    // Guarded by [mutex]. What could not be sent yet, oldest first.
    private val held = mutableListOf<SdkMessage>()
    private var closed: Boolean = false

    /**
     * Keeps asking for a token until there is one, then connects with it.
     *
     * The socket is given the token rather than fetching its own, so the waiting
     * has to happen here: without this a single failure on a cold network would
     * leave the chat off until something called this again.
     */
    override fun connect() {
        scope.launch {
            // Each acknowledged connection is the chance to send what piled up
            // while there was not one.
            service.isReady.collect { ready ->
                if (ready) {
                    flushHeld()
                }
            }
        }
        scope.launch {
            var backoffMillis = INITIAL_BACKOFF_MILLIS
            while (isActive) {
                val token = tokens.token().getOrNull()
                if (token != null) {
                    service.connect(token)
                    return@launch
                }
                log.warn { "no token to connect with, trying again in $backoffMillis ms" }
                delay(backoffMillis)
                backoffMillis = (backoffMillis * 2).coerceAtMost(MAX_BACKOFF_MILLIS)
            }
        }
    }

    /** Only what the channel said, never an acknowledgement. */
    override fun messages(): Flow<ChatMessage> = service.messages
        .filterIsInstance<MessageReceived>()
        .mapNotNull { received -> chatMessageOf(received.item) }

    override suspend fun send(message: ChatMessage): Result<Unit> {
        if (message.type != MessageType.Text) {
            return Result.failure(UnsupportedMessageTypeException(message.type))
        }
        return deliver(sdkMessageOf(message))
    }

    /**
     * Sends [message], or holds it until there is a connection to send it on.
     *
     * Taking a message is what lets the chat show it as on its way, so one
     * written while the line is down is held rather than refused. Once the chat
     * is closed there is nothing left to wait for, so it is refused.
     */
    private suspend fun deliver(message: SdkMessage): Result<Unit> {
        val result = service.send(message)
        if (result.exceptionOrNull() !is MessageConnectionClosedException) {
            return result
        }
        return mutex.withLock {
            if (closed) {
                return@withLock result
            }
            held += message
            // Holding without end would grow without end, so the oldest goes.
            if (held.size > MAX_HELD_MESSAGES) {
                held.removeAt(0)
            }
            log.debug { "holding a message until the line is back" }
            Result.success(Unit)
        }
    }

    private suspend fun flushHeld() {
        val waiting = mutex.withLock {
            val all = held.toList()
            held.clear()
            all
        }
        if (waiting.isEmpty()) {
            return
        }
        log.info { "sending ${waiting.size} held back while the line was down" }
        for (message in waiting) {
            service.send(message)
        }
    }

    /**
     * Asks the channel to open the conversation, telling it what the chat was
     * opened from.
     *
     * The answer is not returned here. What the channel makes of the context
     * comes back as ordinary messages, the same way anything else it says does.
     */
    override suspend fun requestGuidanceCard(openContext: Map<String, String>): Result<Unit> {
        val askedAt: Timestamp = Timestamps.fromMillis(now())
        val request: GuidanceCardRequest.Builder = GuidanceCardRequest.newBuilder()
            .setTimestamp(askedAt)
        // Nothing to go on is said by leaving the field out, rather than by
        // sending an empty object the channel would have to read and discard.
        if (openContext.isNotEmpty()) {
            request.setContext(jsonOf(openContext))
        }
        return service.send(
            SdkMessage.newBuilder()
                .setCorrelationId(correlationIds())
                .setTimestamp(askedAt)
                .setGuidanceCardRequest(request)
                .build(),
        )
    }

    override fun close() {
        scope.launch {
            mutex.withLock {
                closed = true
                held.clear()
            }
            service.close()
        }
    }

    /**
     * Reads a message the channel sent, or nothing when the payload is not one.
     *
     * A kind the chat cannot draw yet still becomes a message of that kind, so
     * nothing arrives silently. Only text carries a body so far.
     */
    private fun chatMessageOf(item: PollMessageItem): ChatMessage? {
        val type = INBOUND_TYPES[item.message.payloadCase] ?: return null
        val text: TextMessageRequest? = item.message.takeIf { type == MessageType.Text }
            ?.textMessageRequest
        return ChatMessage(
            role = MessageRole.Agent,
            type = type,
            timestamp = if (item.hasDate()) Timestamps.toMillis(item.date) else now(),
            wiId = item.id,
            content = text?.content?.text.orEmpty(),
            status = ChatStatus.of(item.status, ChatStatus.Delivered),
            header = text?.takeIf { it.hasHeader() }?.header,
            footer = text?.takeIf { it.hasFooter() }?.footer,
            buttons = buttonsOf(item.message),
        )
    }

    /**
     * The options attached to a message, whatever kind of message it is.
     *
     * Every payload that can carry them keeps them beside the body rather than
     * inside it, so they are read here even for a kind the chat cannot draw yet.
     */
    private fun buttonsOf(message: SdkMessage): List<MessageButton> {
        val attached: List<WireButton> = when (message.payloadCase) {
            SdkMessage.PayloadCase.TEXT_MESSAGE_REQUEST -> message.textMessageRequest.buttonsList
            SdkMessage.PayloadCase.IMAGE_MESSAGE_REQUEST -> message.imageMessageRequest.buttonsList
            SdkMessage.PayloadCase.VOICE_NOTE_MESSAGE_REQUEST -> message.voiceNoteMessageRequest.buttonsList
            SdkMessage.PayloadCase.VIDEO_MESSAGE_REQUEST -> message.videoMessageRequest.buttonsList
            SdkMessage.PayloadCase.ATTACHMENT_MESSAGE_REQUEST -> message.attachmentMessageRequest.buttonsList
            else -> emptyList()
        }
        return attached.map { button ->
            MessageButton(
                text = button.text,
                type = buttonTypeOf(button.buttonType),
                url = button.url.takeIf { button.hasUrl() },
            )
        }
    }

    // A kind this SDK does not know reads back as a reply, which is the one
    // thing every button can do and the one that stays inside the conversation.
    private fun buttonTypeOf(type: WireButtonType): MessageButtonType = when (type) {
        WireButtonType.BUTTON_TYPE_POSTBACK -> MessageButtonType.Postback
        WireButtonType.BUTTON_TYPE_LINK -> MessageButtonType.Link
        else -> MessageButtonType.Reply
    }

    private fun sdkMessageOf(message: ChatMessage): SdkMessage {
        val sentAt: Timestamp = Timestamps.fromMillis(now())
        return SdkMessage.newBuilder()
            .setCorrelationId(correlationIdOf(message))
            .setTimestamp(sentAt)
            .setTextMessageRequest(
                TextMessageRequest.newBuilder()
                    .setTimestamp(sentAt)
                    .setContent(
                        TextMessage.newBuilder()
                            .setText(message.content)
                            // The time the message was written, which is not the
                            // time it goes out: one written on a plane is sent
                            // when the plane lands.
                            .setTimestamp(Timestamps.fromMillis(message.timestamp))
                            .setRole(wireRoleOf(message.role))
                            // Whatever the stored row says, what is being sent
                            // has not arrived anywhere yet.
                            .setStatus(MessageStatus.MESSAGE_STATUS_IN_PROGRESS),
                    ),
            )
            .build()
    }

    // The local row id doubles as the correlation id, so an acknowledgement
    // coming back names the row it belongs to. A message that was never stored
    // still needs something to be acknowledged by.
    private fun correlationIdOf(message: ChatMessage): String =
        message.id?.toString() ?: correlationIds()

    private fun wireRoleOf(role: MessageRole): WireRole = when (role) {
        MessageRole.User -> WireRole.MESSAGE_ROLE_USER
        MessageRole.Agent -> WireRole.MESSAGE_ROLE_AGENT
    }
}

/**
 * The payloads that belong in the conversation, and what the chat calls each.
 *
 * Anything else, a cart answer for instance, is an exchange rather than
 * something anyone said.
 */
private const val LOG_NAME = "Messages"

private const val MAX_HELD_MESSAGES = 128

// The same ladder the socket climbs for a lost connection, so a backend that is
// down is waited out at one pace rather than two.
private const val INITIAL_BACKOFF_MILLIS = 1_000L
private const val MAX_BACKOFF_MILLIS = 30_000L

private val INBOUND_TYPES: Map<SdkMessage.PayloadCase, MessageType> = mapOf(
    SdkMessage.PayloadCase.TEXT_MESSAGE_REQUEST to MessageType.Text,
    SdkMessage.PayloadCase.IMAGE_MESSAGE_REQUEST to MessageType.Image,
    SdkMessage.PayloadCase.VOICE_NOTE_MESSAGE_REQUEST to MessageType.Voice,
    SdkMessage.PayloadCase.VIDEO_MESSAGE_REQUEST to MessageType.Video,
    SdkMessage.PayloadCase.ATTACHMENT_MESSAGE_REQUEST to MessageType.Attachment,
    SdkMessage.PayloadCase.PRODUCT_MESSAGE_REQUEST to MessageType.Product,
    SdkMessage.PayloadCase.PRODUCT_CONFIRMATION_MESSAGE_REQUEST to MessageType.ProductConfirmation,
    SdkMessage.PayloadCase.PROMOTION_MESSAGE_REQUEST to MessageType.Promotion,
)

/** A kind of message the SDK can hold and show, but cannot yet put on the wire. */
internal class UnsupportedMessageTypeException(type: MessageType) :
    IllegalArgumentException("A ${type.wireName} message cannot be sent yet")

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

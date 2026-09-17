// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.yalomessage

import ai.yalo.chat.sdk.data.services.message.MessageReceived
import ai.yalo.chat.sdk.data.services.message.YaloMessageService
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
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
import kotlinx.coroutines.launch
import java.util.UUID
import ai.yalo.chat.sdk.domain.models.MessageStatus as ChatStatus
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
    private val scope: CoroutineScope,
    private val now: () -> Long = System::currentTimeMillis,
    private val correlationIds: () -> String = { UUID.randomUUID().toString() },
) : YaloMessageRepository {

    override fun connect() {
        scope.launch {
            service.connect()
        }
    }

    /**
     * Only what the channel said. An acknowledgement travels the other way and
     * is the channel's own bookkeeping, so it is not part of the conversation.
     */
    override fun messages(): Flow<ChatMessage> = service.messages
        .filterIsInstance<MessageReceived>()
        .mapNotNull { received -> chatMessageOf(received.item) }

    override suspend fun send(message: ChatMessage): Result<Unit> {
        if (message.type != MessageType.Text) {
            return Result.failure(UnsupportedMessageTypeException(message.type))
        }
        return service.send(sdkMessageOf(message))
    }

    override fun close() {
        scope.launch {
            service.close()
        }
    }

    /**
     * Reads a message the channel sent, or nothing when the payload is not one.
     *
     * A kind the chat cannot draw yet still becomes a message of that kind, so
     * the person sees that something arrived rather than nothing at all. Only
     * text carries a body worth storing so far.
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
            // It is here, so it arrived. The channel's own word for that is
            // taken when it is one the SDK knows.
            status = ChatStatus.of(item.status, ChatStatus.Delivered),
            header = text?.takeIf { it.hasHeader() }?.header,
            footer = text?.takeIf { it.hasFooter() }?.footer,
        )
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
 * The kinds of payload that belong in the conversation, and what the chat calls
 * each of them.
 *
 * Everything else the channel can send, a cart answer for instance, is an
 * exchange rather than something anyone said, so it is left out.
 */
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

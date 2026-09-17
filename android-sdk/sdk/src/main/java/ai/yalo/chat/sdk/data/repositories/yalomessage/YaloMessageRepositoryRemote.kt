// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.yalomessage

import ai.yalo.chat.sdk.data.services.message.YaloMessageService
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.MessageStatus
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.TextMessage
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.TextMessageRequest
import com.google.protobuf.Timestamp
import com.google.protobuf.util.Timestamps
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import java.util.UUID
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

/** A kind of message the SDK can hold and show, but cannot yet put on the wire. */
internal class UnsupportedMessageTypeException(type: MessageType) :
    IllegalArgumentException("A ${type.wireName} message cannot be sent yet")

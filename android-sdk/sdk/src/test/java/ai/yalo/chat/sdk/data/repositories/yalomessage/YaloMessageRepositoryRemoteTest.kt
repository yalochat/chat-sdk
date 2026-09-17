// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.yalomessage

import ai.yalo.chat.sdk.data.services.message.InboundMessage
import ai.yalo.chat.sdk.data.services.message.YaloMessageService
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageStatus
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.SdkMessage
import com.google.protobuf.util.Timestamps
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.IOException
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.MessageRole as WireRole
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.MessageStatus as WireStatus

@OptIn(ExperimentalCoroutinesApi::class)
class YaloMessageRepositoryRemoteTest {

    private val service = FakeYaloMessageService()

    @Test
    fun sendsWhatThePersonWrote() = runTest {
        repository().send(message(content = "Hello"))

        assertEquals("Hello", sentText())
    }

    @Test
    fun sendsAMessageAsComingFromWhoeverWroteIt() = runTest {
        repository().send(message(role = MessageRole.User))

        assertEquals(WireRole.MESSAGE_ROLE_USER, service.sent.single().textMessageRequest.content.role)
    }

    @Test
    fun sendsAMessageAsComingFromTheChannelWhenThatIsWhoWroteIt() = runTest {
        repository().send(message(role = MessageRole.Agent))

        assertEquals(WireRole.MESSAGE_ROLE_AGENT, service.sent.single().textMessageRequest.content.role)
    }

    // Whatever the stored row says, a message on its way out has not arrived
    // anywhere yet.
    @Test
    fun sendsAMessageAsNotYetArrived() = runTest {
        repository().send(message(status = MessageStatus.Delivered))

        assertEquals(
            WireStatus.MESSAGE_STATUS_IN_PROGRESS,
            service.sent.single().textMessageRequest.content.status,
        )
    }

    @Test
    fun keepsTheTimeTheMessageWasWritten() = runTest {
        repository().send(message(timestamp = WRITTEN_AT))

        assertEquals(
            WRITTEN_AT,
            Timestamps.toMillis(service.sent.single().textMessageRequest.content.timestamp),
        )
    }

    @Test
    fun saysWhenTheMessageWasSentApartFromWhenItWasWritten() = runTest {
        repository().send(message(timestamp = WRITTEN_AT))

        assertEquals(SENT_AT, Timestamps.toMillis(service.sent.single().timestamp))
    }

    // An acknowledgement comes back naming the correlation id, so the row id is
    // what lets the answer find the message it belongs to.
    @Test
    fun namesTheMessageAfterTheRowItWasStoredAs() = runTest {
        repository().send(message(id = 42L))

        assertEquals("42", service.sent.single().correlationId)
    }

    @Test
    fun givesAMessageThatWasNeverStoredAnIdOfItsOwn() = runTest {
        repository().send(message(id = null))

        assertEquals("generated-id", service.sent.single().correlationId)
    }

    @Test
    fun reportsAMessageTheChannelTook() = runTest {
        val result = repository().send(message())

        assertTrue(result.isSuccess)
    }

    @Test
    fun reportsAMessageTheChannelWouldNotTake() = runTest {
        service.failure = IOException("the line is down")

        val result = repository().send(message())

        assertEquals("the line is down", result.exceptionOrNull()?.message)
    }

    @Test
    fun refusesAKindOfMessageItCannotPutOnTheWireYet() = runTest {
        val result = repository().send(message(type = MessageType.Image))

        assertTrue(result.exceptionOrNull() is UnsupportedMessageTypeException)
        assertEquals(emptyList<SdkMessage>(), service.sent)
    }

    @Test
    fun opensTheLineToTheChannel() = runTest {
        repository(this).connect()
        runCurrent()

        assertTrue(service.isOpen)
    }

    @Test
    fun endsTheConversation() = runTest {
        val repository = repository(this)
        repository.connect()
        runCurrent()

        repository.close()
        runCurrent()

        assertFalse(service.isOpen)
    }

    private fun sentText(): String = service.sent.single().textMessageRequest.content.text

    private fun TestScope.repository(): YaloMessageRepositoryRemote = repository(this)

    private fun repository(scope: CoroutineScope): YaloMessageRepositoryRemote =
        YaloMessageRepositoryRemote(
            service = service,
            scope = scope,
            now = { SENT_AT },
            correlationIds = { "generated-id" },
        )

    private fun message(
        content: String = "Hello",
        role: MessageRole = MessageRole.User,
        type: MessageType = MessageType.Text,
        status: MessageStatus = MessageStatus.InProgress,
        timestamp: Long = WRITTEN_AT,
        id: Long? = 1L,
    ): ChatMessage = ChatMessage(
        role = role,
        type = type,
        timestamp = timestamp,
        id = id,
        content = content,
        status = status,
    )

    private class FakeYaloMessageService : YaloMessageService {

        val sent: MutableList<SdkMessage> = mutableListOf()
        var isOpen: Boolean = false
            private set
        var failure: Throwable? = null

        override val messages: Flow<InboundMessage> = emptyFlow()

        override suspend fun connect() {
            isOpen = true
        }

        override suspend fun send(message: SdkMessage): Result<Unit> {
            failure?.let { error -> return Result.failure(error) }
            sent.add(message)
            return Result.success(Unit)
        }

        override suspend fun pause() = Unit

        override suspend fun resume() = Unit

        override suspend fun close() {
            isOpen = false
        }
    }

    private companion object {
        const val WRITTEN_AT = 1_700_000_000_000L
        const val SENT_AT = 1_700_000_005_000L
    }
}

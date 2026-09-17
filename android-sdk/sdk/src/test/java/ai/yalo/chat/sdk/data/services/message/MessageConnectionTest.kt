// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.message

import ai.yalo.chat.sdk.data.services.message.MessageConnection.Command
import ai.yalo.chat.sdk.data.services.message.MessageConnection.Event
import ai.yalo.chat.sdk.data.services.message.MessageConnection.State
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessageOuterClass.PollMessageItem
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class MessageConnectionTest {

    @Test
    fun asksForATokenBeforeAnythingElse() {
        val connection = MessageConnection()

        val commands = connection.handle(Event.Started)

        assertEquals(listOf(Command.FetchToken(FIRST)), commands)
    }

    @Test
    fun refusesToSendWhileTheChatIsNotOpen() {
        val connection = MessageConnection()

        val commands = connection.handle(Event.SendRequested(requestId = 1, frame = FRAME))

        assertTrue(commands.single() is Command.FailSend)
    }

    @Test
    fun ignoresWhatIsLeftOfAConnectionItGaveUpOn() {
        val connection = MessageConnection()

        val commands = connection.handle(Event.SocketClosed(generation = 0))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun opensASocketWithTheTokenItWasGiven() {
        val connection = authorizing()

        val commands = connection.handle(Event.TokenFetched(FIRST, "jwt"))

        assertEquals(listOf(Command.OpenSocket(FIRST, "jwt")), commands)
    }

    @Test
    fun waitsBeforeTryingAgainWhenNoTokenCanBeFetched() {
        val connection = authorizing()

        val commands = connection.handle(Event.TokenFetchFailed(FIRST))

        assertEquals(listOf(Command.StartReconnectTimer(FIRST, SECOND_MILLIS)), commands)
    }

    @Test
    fun holdsMessagesWrittenWhileTheTokenIsBeingFetched() {
        val connection = authorizing()

        val commands = connection.handle(Event.SendRequested(requestId = 7, frame = FRAME))

        assertEquals(listOf(Command.CompleteSend(7)), commands)
    }

    @Test
    fun givingUpWhileFetchingATokenClosesNothing() {
        val connection = authorizing()

        val commands = connection.handle(Event.Stopped)

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresASecondRequestToConnect() {
        val connection = authorizing()

        val commands = connection.handle(Event.Started)

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun startsTheAcknowledgementWatchdogWhenTheSocketOpens() {
        val connection = connecting()

        val commands = connection.handle(Event.SocketOpened(FIRST))

        assertEquals(listOf(Command.StartAckTimer(FIRST, ACK_TIMEOUT_MILLIS)), commands)
    }

    @Test
    fun waitsBeforeTryingAgainWhenTheSocketNeverOpens() {
        val connection = connecting()

        val commands = connection.handle(Event.SocketClosed(FIRST))

        assertEquals(listOf(Command.StartReconnectTimer(FIRST, SECOND_MILLIS)), commands)
    }

    @Test
    fun holdsMessagesWrittenWhileTheSocketIsOpening() {
        val connection = connecting()

        val commands = connection.handle(Event.SendRequested(requestId = 8, frame = FRAME))

        assertEquals(listOf(Command.CompleteSend(8)), commands)
    }

    @Test
    fun givingUpWhileOpeningClosesTheSocket() {
        val connection = connecting()

        val commands = connection.handle(Event.Stopped)

        assertEquals(listOf(Command.CloseSocket), commands)
    }

    @Test
    fun ignoresFramesFromASocketThatHasNotOpenedYet() {
        val connection = connecting()

        val commands = connection.handle(Event.FrameReceived(FIRST, SocketFrame.ConnectionAck))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun flushesWhatItHeldWhenTheServerAcknowledges() {
        val connection = handshaking()
        connection.handle(Event.SendRequested(requestId = 1, frame = "one"))
        connection.handle(Event.SendRequested(requestId = 2, frame = "two"))

        val commands = connection.handle(Event.FrameReceived(FIRST, SocketFrame.ConnectionAck))

        assertEquals(
            listOf(Command.CancelAckTimer, Command.FlushFrames(listOf("one", "two"))),
            commands,
        )
    }

    @Test
    fun acknowledgingWithNothingHeldFlushesNothing() {
        val connection = handshaking()

        val commands = connection.handle(Event.FrameReceived(FIRST, SocketFrame.ConnectionAck))

        assertEquals(listOf(Command.CancelAckTimer), commands)
    }

    @Test
    fun dropsMessagesThatArriveBeforeTheAcknowledgement() {
        val connection = handshaking()

        val commands = connection.handle(Event.FrameReceived(FIRST, payload()))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresAFrameItCannotReadBeforeTheAcknowledgement() {
        val connection = handshaking()

        val commands = connection.handle(Event.FrameReceived(FIRST, SocketFrame.Unusable))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun closesASocketThatIsNeverAcknowledged() {
        val connection = handshaking()

        val commands = connection.handle(Event.AckTimerFired(FIRST))

        assertEquals(
            listOf(Command.CloseSocket, Command.StartReconnectTimer(FIRST, SECOND_MILLIS)),
            commands,
        )
    }

    @Test
    fun stopsTheWatchdogWhenTheSocketDiesBeforeAcknowledging() {
        val connection = handshaking()

        val commands = connection.handle(Event.SocketClosed(FIRST))

        assertEquals(
            listOf(Command.CancelAckTimer, Command.StartReconnectTimer(FIRST, SECOND_MILLIS)),
            commands,
        )
    }

    @Test
    fun holdsMessagesWrittenBeforeTheAcknowledgement() {
        val connection = handshaking()

        val commands = connection.handle(Event.SendRequested(requestId = 3, frame = FRAME))

        assertEquals(listOf(Command.CompleteSend(3)), commands)
    }

    @Test
    fun givingUpBeforeTheAcknowledgementClosesTheSocketAndTheWatchdog() {
        val connection = handshaking()

        val commands = connection.handle(Event.Stopped)

        assertEquals(listOf(Command.CloseSocket, Command.CancelAckTimer), commands)
    }

    @Test
    fun ignoresASecondReportThatTheSocketIsOpen() {
        val connection = handshaking()

        val commands = connection.handle(Event.SocketOpened(FIRST))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun sendsStraightAwayOnceAcknowledged() {
        val connection = ready()

        val commands = connection.handle(Event.SendRequested(requestId = 4, frame = FRAME))

        assertEquals(listOf(Command.SendFrame(4, FRAME)), commands)
    }

    @Test
    fun handsOnEveryMessageTheServerSends() {
        val connection = ready()
        val frame = payload()

        val commands = connection.handle(Event.FrameReceived(FIRST, frame))

        assertEquals(listOf(Command.DeliverMessage(frame.message)), commands)
    }

    @Test
    fun ignoresASecondAcknowledgement() {
        val connection = ready()

        val commands = connection.handle(Event.FrameReceived(FIRST, SocketFrame.ConnectionAck))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresAFrameItCannotRead() {
        val connection = ready()

        val commands = connection.handle(Event.FrameReceived(FIRST, SocketFrame.Unusable))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun startsOverWhenAnAcknowledgedSocketDies() {
        val connection = ready()

        val commands = connection.handle(Event.SocketClosed(FIRST))

        assertEquals(listOf(Command.StartReconnectTimer(FIRST, SECOND_MILLIS)), commands)
    }

    @Test
    fun givingUpClosesAnAcknowledgedSocket() {
        val connection = ready()

        val commands = connection.handle(Event.Stopped)

        assertEquals(listOf(Command.CloseSocket), commands)
    }

    @Test
    fun ignoresAWatchdogForAConnectionItAlreadyAcknowledged() {
        val connection = ready()

        val commands = connection.handle(Event.AckTimerFired(FIRST))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun fetchesAFreshTokenForEveryAttempt() {
        val connection = waiting()

        val commands = connection.handle(Event.ReconnectTimerFired(FIRST))

        assertEquals(listOf(Command.FetchToken(SECOND)), commands)
    }

    @Test
    fun keepsHoldingMessagesWhileItWaits() {
        val connection = waiting()

        val commands = connection.handle(Event.SendRequested(requestId = 5, frame = FRAME))

        assertEquals(listOf(Command.CompleteSend(5)), commands)
    }

    @Test
    fun givingUpCancelsThePendingRetry() {
        val connection = waiting()

        val commands = connection.handle(Event.Stopped)

        assertEquals(listOf(Command.CancelReconnectTimer), commands)
    }

    @Test
    fun ignoresTheDeathOfTheSocketItIsAlreadyRetrying() {
        val connection = waiting()

        val commands = connection.handle(Event.SocketClosed(FIRST))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun waitsTwiceAsLongAfterEveryFailedAttempt() {
        assertEquals(listOf(1_000L, 2_000L, 4_000L, 8_000L, 16_000L), delaysOverFailedAttempts(5))
    }

    @Test
    fun neverWaitsLongerThanHalfAMinute() {
        val delays = delaysOverFailedAttempts(8)

        assertEquals(listOf(30_000L, 30_000L, 30_000L), delays.takeLast(3))
    }

    @Test
    fun startsTheDelaysOverOnceASocketOpens() {
        val connection = MessageConnection()
        connection.handle(Event.Started)
        connection.handle(Event.TokenFetchFailed(FIRST))
        connection.handle(Event.ReconnectTimerFired(FIRST))
        connection.handle(Event.TokenFetched(SECOND, TOKEN))
        connection.handle(Event.SocketOpened(SECOND))

        val commands = connection.handle(Event.SocketClosed(SECOND))

        assertEquals(
            listOf(Command.CancelAckTimer, Command.StartReconnectTimer(SECOND, SECOND_MILLIS)),
            commands,
        )
    }

    @Test
    fun closesTheSocketWhenTheAppGoesAway() {
        val connection = ready()

        val commands = connection.handle(Event.Paused)

        assertEquals(listOf(Command.CloseSocket), commands)
    }

    @Test
    fun schedulesNothingWhileTheAppIsAway() {
        val connection = ready()
        connection.handle(Event.Paused)

        val commands = connection.handle(Event.SocketClosed(FIRST))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun connectsAgainWhenTheAppComesBack() {
        val connection = ready()
        connection.handle(Event.Paused)

        val commands = connection.handle(Event.Resumed)

        assertEquals(listOf(Command.FetchToken(THIRD)), commands)
    }

    @Test
    fun keepsWhatItWasHoldingAcrossAPause() {
        val connection = handshaking()
        connection.handle(Event.SendRequested(requestId = 1, frame = FRAME))
        connection.handle(Event.Paused)
        connection.handle(Event.Resumed)
        connection.handle(Event.TokenFetched(THIRD, TOKEN))
        connection.handle(Event.SocketOpened(THIRD))

        val commands = connection.handle(Event.FrameReceived(THIRD, SocketFrame.ConnectionAck))

        assertEquals(
            listOf(Command.CancelAckTimer, Command.FlushFrames(listOf(FRAME))),
            commands,
        )
    }

    @Test
    fun comingBackWaitsNoLongerThanTheFirstTimeDid() {
        val connection = MessageConnection()
        connection.handle(Event.Started)
        repeat(3) {
            val generation = connection.state.generation
            connection.handle(Event.TokenFetchFailed(generation))
            connection.handle(Event.ReconnectTimerFired(generation))
        }
        connection.handle(Event.Paused)
        connection.handle(Event.Resumed)
        val generation = connection.state.generation

        val commands = connection.handle(Event.TokenFetchFailed(generation))

        assertEquals(listOf(Command.StartReconnectTimer(generation, SECOND_MILLIS)), commands)
    }

    @Test
    fun ignoresComingBackWhenItNeverWentAway() {
        val connection = ready()

        val commands = connection.handle(Event.Resumed)

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun stopsTheRetryWhenTheAppGoesAwayWhileWaiting() {
        val connection = waiting()

        val commands = connection.handle(Event.Paused)

        assertEquals(listOf(Command.CancelReconnectTimer), commands)
    }

    @Test
    fun holdsMessagesWrittenWhileTheAppIsAway() {
        val connection = ready()
        connection.handle(Event.Paused)

        val commands = connection.handle(Event.SendRequested(requestId = 6, frame = FRAME))

        assertEquals(listOf(Command.CompleteSend(6)), commands)
    }

    @Test
    fun givingUpWhileAwayClosesNothing() {
        val connection = ready()
        connection.handle(Event.Paused)

        val commands = connection.handle(Event.Stopped)

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun goingAwayWhileClosedDoesNothing() {
        val connection = MessageConnection()

        val commands = connection.handle(Event.Paused)

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun closesTheSocketAndTheWatchdogWhenTheAppGoesAwayDuringTheHandshake() {
        val connection = handshaking()

        val commands = connection.handle(Event.Paused)

        assertEquals(listOf(Command.CloseSocket, Command.CancelAckTimer), commands)
    }

    @Test
    fun closesTheSocketWhenTheAppGoesAwayWhileItIsOpening() {
        val connection = connecting()

        val commands = connection.handle(Event.Paused)

        assertEquals(listOf(Command.CloseSocket), commands)
    }

    @Test
    fun goingAwayWhileFetchingATokenClosesNothing() {
        val connection = authorizing()

        val commands = connection.handle(Event.Paused)

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresARequestToConnectWhileTheAppIsAway() {
        val connection = ready()
        connection.handle(Event.Paused)

        val commands = connection.handle(Event.Started)

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresTheTokenOfAnAttemptItGaveUpOn() {
        val connection = authorizing()
        connection.handle(Event.Stopped)
        connection.handle(Event.Started)

        val commands = connection.handle(Event.TokenFetched(FIRST, TOKEN))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresFramesFromASocketItReplaced() {
        val connection = ready()
        connection.handle(Event.SocketClosed(FIRST))
        connection.handle(Event.ReconnectTimerFired(FIRST))

        val commands = connection.handle(Event.FrameReceived(FIRST, payload()))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresAWatchdogThatFiredAfterItWasCancelled() {
        val connection = ready()
        connection.handle(Event.Paused)

        val commands = connection.handle(Event.AckTimerFired(FIRST))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresARetryTimerFromAnEarlierAttempt() {
        val connection = waiting()
        connection.handle(Event.ReconnectTimerFired(FIRST))

        val commands = connection.handle(Event.ReconnectTimerFired(FIRST))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun givesEveryAttemptItsOwnGeneration() {
        val connection = waiting()

        connection.handle(Event.ReconnectTimerFired(FIRST))

        assertEquals(SECOND, connection.state.generation)
    }

    @Test
    fun keepsHoldingAcrossALostSocketAndFlushesOnTheNextAcknowledgement() {
        val connection = ready()
        connection.handle(Event.SocketClosed(FIRST))
        connection.handle(Event.SendRequested(requestId = 1, frame = FRAME))
        connection.handle(Event.ReconnectTimerFired(FIRST))
        connection.handle(Event.TokenFetched(SECOND, TOKEN))
        connection.handle(Event.SocketOpened(SECOND))

        val commands = connection.handle(Event.FrameReceived(SECOND, SocketFrame.ConnectionAck))

        assertEquals(
            listOf(Command.CancelAckTimer, Command.FlushFrames(listOf(FRAME))),
            commands,
        )
    }

    @Test
    fun dropsTheOldestHeldMessageWhenTooManyPileUp() {
        val connection = handshaking()
        repeat(MAX_PENDING + 1) { index ->
            connection.handle(Event.SendRequested(requestId = index.toLong(), frame = "frame-$index"))
        }

        val commands = connection.handle(Event.FrameReceived(FIRST, SocketFrame.ConnectionAck))

        val flushed = commands.filterIsInstance<Command.FlushFrames>().single().frames
        assertEquals(MAX_PENDING, flushed.size)
        assertEquals("frame-1", flushed.first())
    }

    @Test
    fun forgetsWhatItWasHoldingWhenTheChatIsClosed() {
        val connection = handshaking()
        connection.handle(Event.SendRequested(requestId = 1, frame = FRAME))
        connection.handle(Event.Stopped)
        connection.handle(Event.Started)
        connection.handle(Event.TokenFetched(SECOND, TOKEN))
        connection.handle(Event.SocketOpened(SECOND))

        val commands = connection.handle(Event.FrameReceived(SECOND, SocketFrame.ConnectionAck))

        assertEquals(listOf(Command.CancelAckTimer), commands)
    }

    @Test
    fun startsFromAStateItWasHandedSoAChatCanCarryOnWhereItLeftOff() {
        val connection = MessageConnection(State.Ready(generation = 9))

        val commands = connection.handle(Event.SendRequested(requestId = 1, frame = FRAME))

        assertEquals(listOf(Command.SendFrame(1, FRAME)), commands)
    }

    /** The delay asked for before each of [attempts] successive failures. */
    private fun delaysOverFailedAttempts(attempts: Int): List<Long> {
        val connection = MessageConnection()
        connection.handle(Event.Started)
        return (1..attempts).map {
            val generation = connection.state.generation
            val commands = connection.handle(Event.TokenFetchFailed(generation))
            val delay = commands.filterIsInstance<Command.StartReconnectTimer>().single().delayMillis
            connection.handle(Event.ReconnectTimerFired(generation))
            delay
        }
    }

    private fun authorizing(): MessageConnection {
        val connection = MessageConnection()
        connection.handle(Event.Started)
        return connection
    }

    private fun connecting(): MessageConnection {
        val connection = authorizing()
        connection.handle(Event.TokenFetched(FIRST, TOKEN))
        return connection
    }

    private fun handshaking(): MessageConnection {
        val connection = connecting()
        connection.handle(Event.SocketOpened(FIRST))
        return connection
    }

    private fun ready(): MessageConnection {
        val connection = handshaking()
        connection.handle(Event.FrameReceived(FIRST, SocketFrame.ConnectionAck))
        return connection
    }

    private fun waiting(): MessageConnection {
        val connection = ready()
        connection.handle(Event.SocketClosed(FIRST))
        return connection
    }

    private fun payload(): SocketFrame.Payload =
        SocketFrame.Payload(MessageReceived(PollMessageItem.getDefaultInstance()))

    private companion object {

        const val FIRST = 1L
        const val SECOND = 2L
        const val THIRD = 3L

        const val TOKEN = "jwt"
        const val FRAME = """{"correlationId":"1"}"""

        const val SECOND_MILLIS = 1_000L
        const val ACK_TIMEOUT_MILLIS = 10_000L
        const val MAX_PENDING = 128
    }
}

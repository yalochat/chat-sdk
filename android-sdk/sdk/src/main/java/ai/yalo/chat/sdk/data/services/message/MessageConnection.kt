// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.message

/**
 * Decides what has to happen for the chat to hold a live link to the channel,
 * without opening one. An [Event] goes in, a list of [Command]s comes out, and
 * whoever owns the socket carries those out and reports back.
 */
internal class MessageConnection(initialState: State = State.Idle()) {

    var state: State = initialState
        private set

    fun handle(event: Event): List<Command> {
        if (event is Event.Tagged && event.generation != state.generation) {
            return emptyList()
        }
        val transition = transition(state, event)
        state = transition.state
        return transition.commands
    }

    sealed interface State {

        val generation: Long

        data class Idle(override val generation: Long = 0) : State

        data class Authorizing(
            override val generation: Long,
            val attempt: Int,
            val pending: List<String>,
        ) : State

        data class Connecting(
            override val generation: Long,
            val attempt: Int,
            val pending: List<String>,
        ) : State

        data class Handshaking(
            override val generation: Long,
            val pending: List<String>,
        ) : State

        data class Ready(override val generation: Long) : State

        data class Waiting(
            override val generation: Long,
            val attempt: Int,
            val pending: List<String>,
        ) : State

        data class Paused(
            override val generation: Long,
            val pending: List<String>,
        ) : State
    }

    sealed interface Event {

        /**
         * Answers for one attempt to connect, and is dropped once the
         * connection has moved past that attempt.
         */
        sealed interface Tagged : Event {
            val generation: Long
        }

        data object Started : Event

        data object Stopped : Event

        data object Paused : Event

        data object Resumed : Event

        data class SendRequested(val requestId: Long, val frame: String) : Event

        data class TokenFetched(
            override val generation: Long,
            val accessToken: String,
        ) : Tagged

        data class TokenFetchFailed(override val generation: Long) : Tagged

        data class SocketOpened(override val generation: Long) : Tagged

        data class FrameReceived(
            override val generation: Long,
            val frame: SocketFrame,
        ) : Tagged

        /** A failure, a close from the server and a close asked for from here all arrive this way. */
        data class SocketClosed(override val generation: Long) : Tagged

        data class AckTimerFired(override val generation: Long) : Tagged

        data class ReconnectTimerFired(override val generation: Long) : Tagged
    }

    sealed interface Command {

        data class FetchToken(val generation: Long) : Command

        data class OpenSocket(val generation: Long, val accessToken: String) : Command

        data object CloseSocket : Command

        data class SendFrame(val requestId: Long, val frame: String) : Command

        /** Nobody is waiting on these: each was answered when it was taken. */
        data class FlushFrames(val frames: List<String>) : Command

        data class CompleteSend(val requestId: Long) : Command

        data class FailSend(val requestId: Long, val cause: Throwable) : Command

        data class DeliverMessage(val message: InboundMessage) : Command

        data class StartAckTimer(val generation: Long, val delayMillis: Long) : Command

        data object CancelAckTimer : Command

        data class StartReconnectTimer(val generation: Long, val delayMillis: Long) : Command

        data object CancelReconnectTimer : Command
    }

    private data class Transition(val state: State, val commands: List<Command> = emptyList())

    private fun transition(state: State, event: Event): Transition = when (state) {
        is State.Idle -> idle(state, event)
        is State.Authorizing -> authorizing(state, event)
        is State.Connecting -> connecting(state, event)
        is State.Handshaking -> handshaking(state, event)
        is State.Ready -> ready(state, event)
        is State.Waiting -> waiting(state, event)
        is State.Paused -> paused(state, event)
    }

    private fun idle(state: State.Idle, event: Event): Transition = when (event) {
        is Event.Started -> authorize(state.generation + 1, attempt = FIRST_ATTEMPT, pending = emptyList())
        is Event.SendRequested -> Transition(
            state,
            listOf(Command.FailSend(event.requestId, MessageConnectionClosedException())),
        )
        else -> Transition(state)
    }

    private fun authorizing(state: State.Authorizing, event: Event): Transition = when (event) {
        is Event.TokenFetched -> Transition(
            State.Connecting(state.generation, state.attempt, state.pending),
            listOf(Command.OpenSocket(state.generation, event.accessToken)),
        )
        is Event.TokenFetchFailed -> retry(state.generation, state.attempt, state.pending)
        is Event.SendRequested -> hold(
            state.copy(pending = queue(state.pending, event.frame)),
            event.requestId,
        )
        is Event.Paused -> pause(state.generation, state.pending)
        is Event.Stopped -> stop(state)
        else -> Transition(state)
    }

    private fun connecting(state: State.Connecting, event: Event): Transition = when (event) {
        // Dropping the attempt count is how the delays reset: a socket that
        // opens has shown the line works.
        is Event.SocketOpened -> Transition(
            State.Handshaking(state.generation, state.pending),
            listOf(Command.StartAckTimer(state.generation, ACK_TIMEOUT_MILLIS)),
        )
        is Event.SocketClosed -> retry(state.generation, state.attempt, state.pending)
        is Event.SendRequested -> hold(
            state.copy(pending = queue(state.pending, event.frame)),
            event.requestId,
        )
        is Event.Paused -> pause(state.generation, state.pending, listOf(Command.CloseSocket))
        is Event.Stopped -> stop(state)
        else -> Transition(state)
    }

    private fun handshaking(state: State.Handshaking, event: Event): Transition = when (event) {
        is Event.FrameReceived -> when (event.frame) {
            is SocketFrame.ConnectionAck -> Transition(
                State.Ready(state.generation),
                listOf(Command.CancelAckTimer) + flush(state.pending),
            )
            else -> Transition(state)
        }
        is Event.AckTimerFired -> retry(
            state.generation,
            attempt = FIRST_ATTEMPT,
            pending = state.pending,
            first = listOf(Command.CloseSocket),
        )
        is Event.SocketClosed -> retry(
            state.generation,
            attempt = FIRST_ATTEMPT,
            pending = state.pending,
            first = listOf(Command.CancelAckTimer),
        )
        is Event.SendRequested -> hold(
            state.copy(pending = queue(state.pending, event.frame)),
            event.requestId,
        )
        is Event.Paused -> pause(
            state.generation,
            state.pending,
            listOf(Command.CloseSocket, Command.CancelAckTimer),
        )
        is Event.Stopped -> stop(state)
        else -> Transition(state)
    }

    private fun ready(state: State.Ready, event: Event): Transition = when (event) {
        is Event.SendRequested -> Transition(
            state,
            listOf(Command.SendFrame(event.requestId, event.frame)),
        )
        is Event.FrameReceived -> when (val frame = event.frame) {
            is SocketFrame.Payload -> Transition(state, listOf(Command.DeliverMessage(frame.message)))
            else -> Transition(state)
        }
        is Event.SocketClosed -> retry(
            state.generation,
            attempt = FIRST_ATTEMPT,
            pending = emptyList(),
        )
        is Event.Paused -> pause(state.generation, pending = emptyList(), first = listOf(Command.CloseSocket))
        is Event.Stopped -> stop(state)
        else -> Transition(state)
    }

    private fun waiting(state: State.Waiting, event: Event): Transition = when (event) {
        is Event.ReconnectTimerFired -> authorize(
            state.generation + 1,
            state.attempt,
            state.pending,
        )
        is Event.SendRequested -> hold(
            state.copy(pending = queue(state.pending, event.frame)),
            event.requestId,
        )
        is Event.Paused -> pause(
            state.generation,
            state.pending,
            listOf(Command.CancelReconnectTimer),
        )
        is Event.Stopped -> stop(state)
        else -> Transition(state)
    }

    private fun paused(state: State.Paused, event: Event): Transition = when (event) {
        is Event.Resumed -> authorize(
            state.generation + 1,
            attempt = FIRST_ATTEMPT,
            pending = state.pending,
        )
        is Event.SendRequested -> hold(
            state.copy(pending = queue(state.pending, event.frame)),
            event.requestId,
        )
        is Event.Stopped -> stop(state)
        else -> Transition(state)
    }

    private fun authorize(generation: Long, attempt: Int, pending: List<String>): Transition =
        Transition(
            State.Authorizing(generation, attempt, pending),
            listOf(Command.FetchToken(generation)),
        )

    private fun retry(
        generation: Long,
        attempt: Int,
        pending: List<String>,
        first: List<Command> = emptyList(),
    ): Transition = Transition(
        State.Waiting(generation, (attempt + 1).coerceAtMost(MAX_ATTEMPT), pending),
        first + Command.StartReconnectTimer(generation, backoff(attempt)),
    )

    // The generation moves on so the socket being closed cannot report its own
    // death back and be taken for the one running when the app returns.
    private fun pause(
        generation: Long,
        pending: List<String>,
        first: List<Command> = emptyList(),
    ): Transition = Transition(State.Paused(generation + 1, pending), first)

    private fun stop(state: State): Transition {
        val commands = mutableListOf<Command>()
        when (state) {
            is State.Connecting, is State.Ready -> commands += Command.CloseSocket
            is State.Handshaking -> {
                commands += Command.CloseSocket
                commands += Command.CancelAckTimer
            }
            is State.Waiting -> commands += Command.CancelReconnectTimer
            else -> Unit
        }
        return Transition(State.Idle(state.generation), commands)
    }

    private fun hold(state: State, requestId: Long): Transition =
        Transition(state, listOf(Command.CompleteSend(requestId)))

    private fun queue(pending: List<String>, frame: String): List<String> =
        (pending + frame).takeLast(MAX_PENDING_FRAMES)

    private fun flush(pending: List<String>): List<Command> {
        if (pending.isEmpty()) {
            return emptyList()
        }
        return listOf(Command.FlushFrames(pending))
    }

    private fun backoff(attempt: Int): Long =
        minOf(MAX_BACKOFF_MILLIS, INITIAL_BACKOFF_MILLIS shl attempt)

    private companion object {

        private const val ACK_TIMEOUT_MILLIS = 10_000L
        private const val INITIAL_BACKOFF_MILLIS = 1_000L
        private const val MAX_BACKOFF_MILLIS = 30_000L

        private const val FIRST_ATTEMPT = 0

        // Counting past the point where the delay stops growing keeps the shift
        // that computes it honest.
        private const val MAX_ATTEMPT = 5

        private const val MAX_PENDING_FRAMES = 128
    }
}

/** A frame the server sent, as far as the connection needs to care. */
internal sealed interface SocketFrame {

    data object ConnectionAck : SocketFrame

    data class Payload(val message: InboundMessage) : SocketFrame

    data object Unusable : SocketFrame
}

/**
 * Something the server sent that a listener is meant to see. Empty here so the
 * connection stays free of the wire format.
 */
internal sealed interface InboundMessage

internal class MessageConnectionClosedException :
    IllegalStateException("The chat is not open, so the message was not taken")

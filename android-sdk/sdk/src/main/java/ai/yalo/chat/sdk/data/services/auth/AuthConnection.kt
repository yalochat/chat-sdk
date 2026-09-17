// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

/**
 * Decides what has to happen for the chat to hold a usable access token,
 * without doing any of it. An [Event] goes in, a list of [Command]s comes out,
 * and whoever owns the network and the database carries those out.
 */
internal class AuthConnection(initialState: State = State.Unauthenticated) {

    var state: State = initialState
        private set

    fun handle(event: Event): List<Command> {
        val transition = transition(state, event)
        state = transition.state
        return transition.commands
    }

    sealed interface State {

        data object Unauthenticated : State

        data class Restoring(val pending: Set<Long>) : State

        data class Authenticating(val pending: Set<Long>) : State

        data class Authenticated(val token: AuthToken) : State

        data class Refreshing(val refreshToken: String, val pending: Set<Long>) : State
    }

    sealed interface Event {

        /** [requestId] is how the answer finds its way back to the caller. */
        data class TokenRequested(val requestId: Long, val nowMillis: Long) : Event

        data class StoredTokenLoaded(val token: AuthToken?, val nowMillis: Long) : Event

        data class AuthSucceeded(val credentials: AuthCredentials, val nowMillis: Long) : Event

        data class AuthFailed(val cause: Throwable) : Event

        data class RefreshSucceeded(val credentials: AuthCredentials, val nowMillis: Long) : Event

        data class RefreshFailed(val cause: Throwable) : Event

        /**
         * The backend turned away a request carrying a token this connection
         * still considers good. Answered by getting another one rather than by
         * guessing at the clock.
         */
        data object TokenRejected : Event

        data object SessionCleared : Event
    }

    sealed interface Command {

        data object LoadStoredToken : Command

        data object FetchToken : Command

        data class RefreshToken(val refreshToken: String) : Command

        data class StoreToken(val token: AuthToken) : Command

        data object ClearStoredToken : Command

        data class DeliverToken(val requestIds: Set<Long>, val accessToken: String) : Command

        data class FailRequests(val requestIds: Set<Long>, val cause: Throwable) : Command
    }

    private data class Transition(val state: State, val commands: List<Command> = emptyList())

    private fun transition(state: State, event: Event): Transition = when (state) {
        is State.Unauthenticated -> unauthenticated(event)
        is State.Restoring -> restoring(state, event)
        is State.Authenticating -> authenticating(state, event)
        is State.Authenticated -> authenticated(state, event)
        is State.Refreshing -> refreshing(state, event)
    }

    // Storage is read first because another chat on the same session may have
    // authenticated already.
    private fun unauthenticated(event: Event): Transition = when (event) {
        is Event.TokenRequested -> Transition(
            State.Restoring(pending = setOf(event.requestId)),
            listOf(Command.LoadStoredToken),
        )
        is Event.SessionCleared -> clear(pending = emptySet())
        else -> Transition(State.Unauthenticated)
    }

    private fun restoring(state: State.Restoring, event: Event): Transition = when (event) {
        is Event.TokenRequested -> Transition(state.copy(pending = state.pending + event.requestId))
        is Event.StoredTokenLoaded -> when {
            event.token == null -> {
                fetch(state.pending, forgetStored = false)
            }
            event.token.usableAt(event.nowMillis) -> {
                Transition(
                    State.Authenticated(event.token),
                    deliver(state.pending, event.token.accessToken),
                )
            }
            event.token.refreshToken.isNotBlank() -> {
                refresh(event.token.refreshToken, state.pending)
            }
            else -> {
                fetch(state.pending, forgetStored = true)
            }
        }
        is Event.SessionCleared -> clear(state.pending)
        else -> Transition(state)
    }

    private fun authenticating(state: State.Authenticating, event: Event): Transition = when (event) {
        is Event.TokenRequested -> Transition(state.copy(pending = state.pending + event.requestId))
        is Event.AuthSucceeded -> settle(event.credentials.issuedAt(event.nowMillis), state.pending)
        // How long to wait before trying again is the caller's to decide.
        is Event.AuthFailed -> Transition(State.Unauthenticated, fail(state.pending, event.cause))
        is Event.SessionCleared -> clear(state.pending)
        else -> Transition(state)
    }

    private fun authenticated(state: State.Authenticated, event: Event): Transition = when (event) {
        is Event.TokenRequested -> when {
            state.token.usableAt(event.nowMillis) -> {
                Transition(state, deliver(setOf(event.requestId), state.token.accessToken))
            }
            state.token.refreshToken.isNotBlank() -> {
                refresh(state.token.refreshToken, setOf(event.requestId))
            }
            else -> {
                fetch(setOf(event.requestId), forgetStored = true)
            }
        }
        // Refreshing rather than starting over: to the backend a new anonymous
        // authentication is a different person, and the conversation would
        // start empty.
        is Event.TokenRejected -> when {
            state.token.refreshToken.isNotBlank() -> refresh(state.token.refreshToken, emptySet())
            else -> clear(pending = emptySet())
        }
        is Event.SessionCleared -> clear(pending = emptySet())
        else -> Transition(state)
    }

    private fun refreshing(state: State.Refreshing, event: Event): Transition = when (event) {
        is Event.TokenRequested -> Transition(state.copy(pending = state.pending + event.requestId))
        is Event.RefreshSucceeded -> settle(
            event.credentials.issuedAt(event.nowMillis, fallbackRefreshToken = state.refreshToken),
            state.pending,
        )
        is Event.RefreshFailed -> fetch(state.pending, forgetStored = true)
        is Event.SessionCleared -> clear(state.pending)
        else -> Transition(state)
    }

    private fun fetch(pending: Set<Long>, forgetStored: Boolean): Transition {
        val commands = mutableListOf<Command>()
        if (forgetStored) {
            commands += Command.ClearStoredToken
        }
        commands += Command.FetchToken
        return Transition(State.Authenticating(pending), commands)
    }

    private fun refresh(refreshToken: String, pending: Set<Long>): Transition = Transition(
        State.Refreshing(refreshToken, pending),
        listOf(Command.RefreshToken(refreshToken)),
    )

    private fun settle(token: AuthToken, pending: Set<Long>): Transition = Transition(
        State.Authenticated(token),
        listOf(Command.StoreToken(token)) + deliver(pending, token.accessToken),
    )

    private fun clear(pending: Set<Long>): Transition = Transition(
        State.Unauthenticated,
        listOf(Command.ClearStoredToken) + fail(pending, AuthSessionClearedException()),
    )

    private fun deliver(requestIds: Set<Long>, accessToken: String): List<Command> {
        if (requestIds.isEmpty()) {
            return emptyList()
        }
        return listOf(Command.DeliverToken(requestIds, accessToken))
    }

    private fun fail(requestIds: Set<Long>, cause: Throwable): List<Command> {
        if (requestIds.isEmpty()) {
            return emptyList()
        }
        return listOf(Command.FailRequests(requestIds, cause))
    }
}

/** The lifetime arrives as a length, so it only means something next to [AuthToken]. */
internal data class AuthCredentials(
    val accessToken: String,
    val refreshToken: String,
    val expiresInSeconds: Long,
)

internal data class AuthToken(
    val accessToken: String,
    val refreshToken: String,
    val expiresAtMillis: Long,
)

internal class AuthSessionClearedException :
    IllegalStateException("The session was cleared before a token arrived")

// A refresh that hands back no new refresh token leaves the old one in place.
private fun AuthCredentials.issuedAt(
    nowMillis: Long,
    fallbackRefreshToken: String = "",
): AuthToken = AuthToken(
    accessToken = accessToken,
    refreshToken = refreshToken.ifBlank { fallbackRefreshToken },
    expiresAtMillis = nowMillis + expiresInSeconds * MILLIS_PER_SECOND,
)

private fun AuthToken.usableAt(nowMillis: Long): Boolean = nowMillis < expiresAtMillis

private const val MILLIS_PER_SECOND = 1_000L

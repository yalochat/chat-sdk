// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

/**
 * Works out what has to happen for the chat to hold a usable access token,
 * without doing any of it.
 *
 * Nothing here reads storage, calls the backend or looks at the clock. An
 * [Event] goes in, a list of [Command]s comes out, and whoever owns the network
 * and the database carries those out and reports back with more events. That
 * leaves the awkward parts of the token lifecycle, an expired token, a refusal
 * to refresh, a token the backend stops accepting, several screens asking for
 * one at once, testable as plain function calls.
 *
 * The rules are the web SDK's: a stored token is used for as long as it lasts,
 * an expired one is refreshed, and a refresh the backend refuses falls back to
 * authenticating from scratch.
 *
 * Time never comes from inside. Every event that depends on when it happened
 * carries that moment, so a test decides what "expired" means instead of
 * waiting for it.
 *
 * Events that do not apply to the current state are ignored. A reply from an
 * attempt the session moved on from is the usual case, and dropping it is what
 * keeps a cleared session from being brought back to life by a request that was
 * already on its way out.
 */
internal class AuthConnection(initialState: State = State.Unauthenticated) {

    /** What the connection believes about its token right now. */
    var state: State = initialState
        private set

    /**
     * Applies [event] and returns what the caller has to do about it, in the
     * order it has to be done.
     *
     * An empty list is a normal answer. A caller that asks for a token while an
     * attempt is already in flight is recorded as waiting and nothing else
     * happens, which is what keeps several screens opening at once from causing
     * several authentications.
     */
    fun handle(event: Event): List<Command> {
        val transition = transition(state, event)
        state = transition.state
        return transition.commands
    }

    /** Where the token lifecycle currently stands. */
    sealed interface State {

        /** No token is held and nothing is being done about it. */
        data object Unauthenticated : State

        /** Storage is being read to see whether an earlier token survived. */
        data class Restoring(val pending: Set<Long>) : State

        /** The backend is being asked for a brand new token. */
        data class Authenticating(val pending: Set<Long>) : State

        /** A token is held and is worth handing out. */
        data class Authenticated(val token: AuthToken) : State

        /** An expired token is being traded for a new one. */
        data class Refreshing(val refreshToken: String, val pending: Set<Long>) : State
    }

    /** Something that happened, either asked for by the SDK or reported to it. */
    sealed interface Event {

        /**
         * Someone needs an access token.
         *
         * [requestId] is how the answer finds its way back, so the caller picks
         * one it can recognise and waits for it to appear in a
         * [Command.DeliverToken] or a [Command.FailRequests].
         */
        data class TokenRequested(val requestId: Long, val nowMillis: Long) : Event

        /** Storage answered [Command.LoadStoredToken], with a token or nothing. */
        data class StoredTokenLoaded(val token: AuthToken?, val nowMillis: Long) : Event

        /** The backend issued a new token. */
        data class AuthSucceeded(val credentials: AuthCredentials, val nowMillis: Long) : Event

        /** The backend would not issue a token. */
        data class AuthFailed(val cause: Throwable) : Event

        /** The backend traded the refresh token for a new one. */
        data class RefreshSucceeded(val credentials: AuthCredentials, val nowMillis: Long) : Event

        /** The backend would not honour the refresh token. */
        data class RefreshFailed(val cause: Throwable) : Event

        /**
         * The backend turned away a request carrying a token this connection
         * still considers good.
         *
         * A token can stop being accepted before it is due to expire, and it can
         * expire while a request that carried it is still travelling. Both look
         * the same from here, and both are answered by getting another token
         * rather than by guessing at the clock.
         */
        data object TokenRejected : Event

        /** The session is over and whatever is held about it has to go. */
        data object SessionCleared : Event
    }

    /** Work for the caller to carry out, with the result reported back as an [Event]. */
    sealed interface Command {

        /** Read the token kept for this session, and report [Event.StoredTokenLoaded]. */
        data object LoadStoredToken : Command

        /** Ask the backend for a new token, and report [Event.AuthSucceeded] or [Event.AuthFailed]. */
        data object FetchToken : Command

        /** Trade [refreshToken] for a new token, and report [Event.RefreshSucceeded] or [Event.RefreshFailed]. */
        data class RefreshToken(val refreshToken: String) : Command

        /** Keep [token] for this session so the next chat that opens starts with it. */
        data class StoreToken(val token: AuthToken) : Command

        /** Forget the token kept for this session. */
        data object ClearStoredToken : Command

        /** Hand [accessToken] to everyone in [requestIds]. */
        data class DeliverToken(val requestIds: Set<Long>, val accessToken: String) : Command

        /** Tell everyone in [requestIds] that no token is coming, and why. */
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

    // Storage is read before the backend is asked, every time the connection
    // starts from nothing. Another chat on the same session may have
    // authenticated in the meantime, and reading is cheaper than a round trip.
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
        // Back to nothing rather than to a state that remembers the failure.
        // How long to wait before trying again is the caller's to decide, and
        // the next request starts the whole lifecycle over.
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
        // Refreshing rather than starting over, so the session survives. A new
        // authentication for an anonymous user is a different person as far as
        // the backend is concerned, and the conversation would start empty.
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
        // A refused refresh leaves nothing worth keeping, so the stored token
        // goes and the session is rebuilt from a fresh authentication.
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

/**
 * What the backend hands back when it issues a token.
 *
 * The lifetime arrives as a length rather than a moment, so it only means
 * something next to the time it was issued at.
 */
internal data class AuthCredentials(
    val accessToken: String,
    val refreshToken: String,
    val expiresInSeconds: Long,
)

/** An issued token, with the moment it stops being worth sending. */
internal data class AuthToken(
    val accessToken: String,
    val refreshToken: String,
    val expiresAtMillis: Long,
)

/** Reported to whoever was still waiting for a token when the session was cleared. */
internal class AuthSessionClearedException :
    IllegalStateException("The session was cleared before a token arrived")

// A refresh that hands back no new refresh token leaves the old one in place.
// Losing it would cost the session the next time the access token expires.
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

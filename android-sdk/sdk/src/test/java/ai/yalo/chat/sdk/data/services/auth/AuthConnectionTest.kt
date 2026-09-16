// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

import ai.yalo.chat.sdk.data.services.auth.AuthConnection.Command
import ai.yalo.chat.sdk.data.services.auth.AuthConnection.Event
import ai.yalo.chat.sdk.data.services.auth.AuthConnection.State
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class AuthConnectionTest {

    @Test
    fun looksInStorageBeforeAskingTheBackend() {
        val connection = AuthConnection()

        val commands = connection.handle(Event.TokenRequested(requestId = 1, nowMillis = NOW))

        assertEquals(listOf(Command.LoadStoredToken), commands)
    }

    @Test
    fun handsBackAStoredTokenThatIsStillGood() {
        val connection = AuthConnection()
        connection.handle(Event.TokenRequested(requestId = 1, nowMillis = NOW))

        val commands = connection.handle(
            Event.StoredTokenLoaded(token(expiresAtMillis = NOW + HOUR), nowMillis = NOW),
        )

        assertEquals(listOf(Command.DeliverToken(setOf(1L), "access")), commands)
    }

    @Test
    fun refreshesAStoredTokenThatHasExpired() {
        val connection = AuthConnection()
        connection.handle(Event.TokenRequested(requestId = 1, nowMillis = NOW))

        val commands = connection.handle(
            Event.StoredTokenLoaded(token(expiresAtMillis = NOW - 1), nowMillis = NOW),
        )

        assertEquals(listOf(Command.RefreshToken("refresh")), commands)
    }

    @Test
    fun authenticatesWhenStorageHasNothing() {
        val connection = AuthConnection()
        connection.handle(Event.TokenRequested(requestId = 1, nowMillis = NOW))

        val commands = connection.handle(Event.StoredTokenLoaded(token = null, nowMillis = NOW))

        assertEquals(listOf(Command.FetchToken), commands)
    }

    @Test
    fun authenticatesWhenAnExpiredStoredTokenCannotBeRefreshed() {
        val connection = AuthConnection()
        connection.handle(Event.TokenRequested(requestId = 1, nowMillis = NOW))

        val commands = connection.handle(
            Event.StoredTokenLoaded(
                token(refreshToken = "", expiresAtMillis = NOW - 1),
                nowMillis = NOW,
            ),
        )

        assertEquals(listOf(Command.ClearStoredToken, Command.FetchToken), commands)
    }

    @Test
    fun keepsAndHandsOutATokenTheBackendJustIssued() {
        val connection = authenticating()

        val commands = connection.handle(
            Event.AuthSucceeded(credentials(expiresInSeconds = 3_600), nowMillis = NOW),
        )

        assertEquals(
            listOf(
                Command.StoreToken(token(expiresAtMillis = NOW + HOUR)),
                Command.DeliverToken(setOf(1L), "access"),
            ),
            commands,
        )
    }

    @Test
    fun asksTheBackendOnceHoweverManyCallersAreWaiting() {
        val connection = AuthConnection()
        connection.handle(Event.TokenRequested(requestId = 1, nowMillis = NOW))

        val whileRestoring = connection.handle(Event.TokenRequested(requestId = 2, nowMillis = NOW))
        val started = connection.handle(Event.StoredTokenLoaded(token = null, nowMillis = NOW))
        val whileAuthenticating = connection.handle(Event.TokenRequested(requestId = 3, nowMillis = NOW))
        val finished = connection.handle(Event.AuthSucceeded(credentials(), nowMillis = NOW))

        assertEquals(emptyList<Command>(), whileRestoring)
        assertEquals(listOf(Command.FetchToken), started)
        assertEquals(emptyList<Command>(), whileAuthenticating)
        assertEquals(Command.DeliverToken(setOf(1L, 2L, 3L), "access"), finished.last())
    }

    @Test
    fun reusesALiveTokenWithoutTouchingTheBackend() {
        val connection = authenticated()

        val commands = connection.handle(Event.TokenRequested(requestId = 2, nowMillis = NOW + 1))

        assertEquals(listOf(Command.DeliverToken(setOf(2L), "access")), commands)
    }

    @Test
    fun refreshesALiveTokenOnceItHasExpired() {
        val connection = authenticated()

        val commands = connection.handle(Event.TokenRequested(requestId = 2, nowMillis = NOW + HOUR))

        assertEquals(listOf(Command.RefreshToken("refresh")), commands)
    }

    @Test
    fun authenticatesWhenAnExpiredLiveTokenCannotBeRefreshed() {
        val connection = authenticating()
        connection.handle(
            Event.AuthSucceeded(credentials(refreshToken = ""), nowMillis = NOW),
        )

        val commands = connection.handle(Event.TokenRequested(requestId = 2, nowMillis = NOW + HOUR))

        assertEquals(listOf(Command.ClearStoredToken, Command.FetchToken), commands)
    }

    @Test
    fun startsOverWhenTheBackendRefusesToRefresh() {
        val connection = refreshing()

        val commands = connection.handle(Event.RefreshFailed(Error()))

        assertEquals(listOf(Command.ClearStoredToken, Command.FetchToken), commands)
    }

    @Test
    fun keepsTheRefreshTokenWhenTheBackendSendsNoNewOne() {
        val connection = refreshing()

        val commands = connection.handle(
            Event.RefreshSucceeded(
                credentials(accessToken = "refreshed", refreshToken = ""),
                nowMillis = NOW,
            ),
        )

        assertEquals(
            Command.StoreToken(
                token(accessToken = "refreshed", refreshToken = "refresh", expiresAtMillis = NOW + HOUR),
            ),
            commands.first(),
        )
    }

    @Test
    fun tellsEveryWaiterWhenAuthenticationFails() {
        val connection = authenticating()
        val cause = Error("no network")

        val commands = connection.handle(Event.AuthFailed(cause))

        assertEquals(listOf(Command.FailRequests(setOf(1L), cause)), commands)
    }

    @Test
    fun triesTheWholeLifecycleAgainAfterAFailure() {
        val connection = authenticating()
        connection.handle(Event.AuthFailed(Error()))

        val commands = connection.handle(Event.TokenRequested(requestId = 2, nowMillis = NOW))

        assertEquals(listOf(Command.LoadStoredToken), commands)
    }

    @Test
    fun refreshesATokenTheBackendStoppedAccepting() {
        val connection = authenticated()

        val commands = connection.handle(Event.TokenRejected)

        assertEquals(listOf(Command.RefreshToken("refresh")), commands)
    }

    @Test
    fun forgetsARejectedTokenThatCannotBeRefreshed() {
        val connection = authenticating()
        connection.handle(Event.AuthSucceeded(credentials(refreshToken = ""), nowMillis = NOW))

        val commands = connection.handle(Event.TokenRejected)

        assertEquals(listOf(Command.ClearStoredToken), commands)
        assertEquals(State.Unauthenticated, connection.state)
    }

    @Test
    fun ignoresARejectionWhileARefreshIsAlreadyOnItsWay() {
        val connection = refreshing()

        val commands = connection.handle(Event.TokenRejected)

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresARejectionWhileStorageIsStillBeingRead() {
        val connection = AuthConnection()
        connection.handle(Event.TokenRequested(requestId = 1, nowMillis = NOW))

        val commands = connection.handle(Event.TokenRejected)

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresARejectionWhileThereIsNoTokenToReject() {
        val connection = authenticating()

        val commands = connection.handle(Event.TokenRejected)

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun keepsATokenRefreshedAfterARejectionEvenWithNoOneWaiting() {
        val connection = authenticated()
        connection.handle(Event.TokenRejected)

        val commands = connection.handle(
            Event.RefreshSucceeded(credentials(accessToken = "refreshed"), nowMillis = NOW),
        )

        assertEquals(
            listOf(Command.StoreToken(token(accessToken = "refreshed", expiresAtMillis = NOW + HOUR))),
            commands,
        )
    }

    @Test
    fun forgetsTheTokenWhenTheSessionIsCleared() {
        val connection = authenticated()

        val commands = connection.handle(Event.SessionCleared)

        assertEquals(listOf(Command.ClearStoredToken), commands)
        assertEquals(State.Unauthenticated, connection.state)
    }

    @Test
    fun tellsWaitersNoTokenIsComingWhenTheSessionIsCleared() {
        val connection = authenticating()

        val commands = connection.handle(Event.SessionCleared)

        assertEquals(Command.ClearStoredToken, commands.first())
        val failure = commands.last() as Command.FailRequests
        assertEquals(setOf(1L), failure.requestIds)
        assertTrue(failure.cause is AuthSessionClearedException)
    }

    @Test
    fun clearsStorageForASessionThatNeverHeldAToken() {
        val connection = AuthConnection()

        val commands = connection.handle(Event.SessionCleared)

        assertEquals(listOf(Command.ClearStoredToken), commands)
    }

    @Test
    fun ignoresALateReplyFromAnAbandonedAttempt() {
        val connection = authenticating()
        connection.handle(Event.SessionCleared)

        val commands = connection.handle(Event.AuthSucceeded(credentials(), nowMillis = NOW))

        assertEquals(emptyList<Command>(), commands)
        assertEquals(State.Unauthenticated, connection.state)
    }

    @Test
    fun ignoresARefreshReplyThatArrivesAfterTheSessionMovedOn() {
        val connection = refreshing()
        connection.handle(Event.SessionCleared)

        val commands = connection.handle(Event.RefreshSucceeded(credentials(), nowMillis = NOW))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun ignoresStorageAnsweringAfterTheSessionMovedOn() {
        val connection = authenticated()

        val commands = connection.handle(Event.StoredTokenLoaded(token(), nowMillis = NOW))

        assertEquals(emptyList<Command>(), commands)
    }

    @Test
    fun startsFromAStateItWasHandedSoAChatCanCarryOnWhereItLeftOff() {
        val connection = AuthConnection(State.Authenticated(token(expiresAtMillis = NOW + HOUR)))

        val commands = connection.handle(Event.TokenRequested(requestId = 1, nowMillis = NOW))

        assertEquals(listOf(Command.DeliverToken(setOf(1L), "access")), commands)
    }

    private fun authenticating(): AuthConnection {
        val connection = AuthConnection()
        connection.handle(Event.TokenRequested(requestId = 1, nowMillis = NOW))
        connection.handle(Event.StoredTokenLoaded(token = null, nowMillis = NOW))
        return connection
    }

    private fun authenticated(): AuthConnection {
        val connection = authenticating()
        connection.handle(Event.AuthSucceeded(credentials(), nowMillis = NOW))
        return connection
    }

    private fun refreshing(): AuthConnection {
        val connection = AuthConnection()
        connection.handle(Event.TokenRequested(requestId = 1, nowMillis = NOW))
        connection.handle(
            Event.StoredTokenLoaded(token(expiresAtMillis = NOW - 1), nowMillis = NOW),
        )
        return connection
    }

    private fun token(
        accessToken: String = "access",
        refreshToken: String = "refresh",
        expiresAtMillis: Long = NOW + HOUR,
    ): AuthToken = AuthToken(accessToken, refreshToken, expiresAtMillis)

    private fun credentials(
        accessToken: String = "access",
        refreshToken: String = "refresh",
        expiresInSeconds: Long = 3_600,
    ): AuthCredentials = AuthCredentials(accessToken, refreshToken, expiresInSeconds)

    private companion object {
        const val NOW = 1_700_000_000_000L
        const val HOUR = 3_600_000L
    }
}

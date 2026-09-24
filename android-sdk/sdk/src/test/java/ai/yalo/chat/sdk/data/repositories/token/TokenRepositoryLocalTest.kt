// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.token

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.SessionMode
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.data.services.auth.AuthCredentials
import ai.yalo.chat.sdk.data.services.auth.YaloMessageAuthService
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.cancel
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.launch
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import org.json.JSONObject
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.io.File
import java.io.IOException
import java.security.GeneralSecurityException

@RunWith(RobolectricTestRunner::class)
class TokenRepositoryLocalTest {

    private lateinit var file: File
    private lateinit var store: DataStore<Preferences>
    private val auth = FakeAuthService()
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    @Before
    fun createStore() {
        file = File.createTempFile("auth_token", ".preferences_pb").also { it.delete() }
        store = PreferenceDataStoreFactory.create { file }
    }

    @After
    fun deleteStore() {
        scope.cancel()
        file.delete()
    }

    @Test
    fun handsBackTheTokenTheBackendIssued() = runBlocking {
        auth.willAnswer(AuthCredentials("issued", "refresh", 3_600))

        assertEquals("issued", service().token().getOrNull())
    }

    @Test
    fun reportsAFailureWhenTheBackendWillNotAuthenticate() = runBlocking {
        auth.willFail(IOException("refused: 401"))

        val result = service().token()

        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull()?.message?.contains("401") == true)
    }

    @Test
    fun keepsTheTokenSoTheNextChatDoesNotHaveToAuthenticate() = runBlocking {
        auth.willAnswer(AuthCredentials("issued", "refresh", 3_600))

        service().token()

        assertEquals("issued", stored()?.accessToken)
        assertEquals(NOW + 3_600_000, stored()?.expiresAtMillis)
    }

    @Test
    fun usesAStoredTokenWithoutTalkingToTheBackend() = runBlocking {
        seed(SESSION, AuthToken("stored", "refresh", NOW + 3_600_000))

        val result = service().token()

        assertEquals("stored", result.getOrNull())
        assertEquals(0, auth.calls)
    }

    @Test
    fun tradesAnExpiredTokenForANewOne() = runBlocking {
        seed(SESSION, AuthToken("expired", "the-refresh-token", NOW - 1))
        auth.willAnswer(AuthCredentials("refreshed", "refresh", 3_600))

        val result = service().token()

        assertEquals("refreshed", result.getOrNull())
        assertEquals(listOf("the-refresh-token"), auth.refreshed)
    }

    @Test
    fun keepsTheRefreshTokenWhenARefreshDoesNotHandBackANewOne() = runBlocking {
        seed(SESSION, AuthToken("expired", "original-refresh", NOW - 1))
        auth.willAnswer(AuthCredentials("refreshed", "", 3_600))

        service().token()

        assertEquals("original-refresh", stored()?.refreshToken)
    }

    @Test
    fun authenticatesAgainWhenTheBackendWillNotRefresh() = runBlocking {
        seed(SESSION, AuthToken("expired", "stale-refresh", NOW - 1))
        auth.willFail(IOException("refused: 403"))
        auth.willAnswer(AuthCredentials("fresh", "refresh", 3_600))

        val result = service().token()

        assertEquals("fresh", result.getOrNull())
        assertEquals(2, auth.calls)
    }

    @Test
    fun asksTheBackendOnceWhenTwoCallersAskAtTheSameTime() = runBlocking {
        auth.willAnswer(AuthCredentials("shared", "refresh", 3_600))
        val service = service()

        val answers = listOf(
            async { service.token() },
            async { service.token() },
        ).awaitAll()

        assertEquals(listOf("shared", "shared"), answers.map { answer -> answer.getOrNull() })
        assertEquals(1, auth.calls)
    }

    @Test
    fun replacesATokenTheBackendStoppedAccepting() = runBlocking {
        seed(SESSION, AuthToken("rejected", "the-refresh-token", NOW + 3_600_000))
        auth.willAnswer(AuthCredentials("replacement", "refresh", 3_600))
        val service = service()
        service.token()

        service.invalidateToken()

        assertEquals("replacement", service.token().getOrNull())
    }

    @Test
    fun stopsInsteadOfReportingAFailureWhenTheCallerWalksAway() = runBlocking {
        auth.willAnswer(AuthCredentials("access", "refresh", 3_600), delayMillis = 2_000)
        val service = service()
        var outcome: Result<String>? = null

        val caller = launch(Dispatchers.IO) { outcome = service.token() }
        auth.awaitCall()
        caller.cancelAndJoin()

        assertNull(outcome)
    }

    @Test
    fun listsTheSessionsThatHaveAStoredToken() = runBlocking {
        seed("other", AuthToken("other-access", "other-refresh", NOW))
        seed(SESSION, AuthToken("stored", "refresh", NOW + 3_600_000))

        assertEquals(setOf("other", SESSION), service().storedSessions().keys)
    }

    @Test
    fun forgetsOnlyTheSessionsItIsGiven() = runBlocking {
        seed("a", AuthToken("a-access", "a-refresh", NOW))
        seed("b", AuthToken("b-access", "b-refresh", NOW))

        service().clearSessions(setOf("a"))

        assertEquals(setOf("b"), storedSessionIds())
    }

    @Test
    fun forgetsTheStoredTokenWhenItsOwnSessionIsCleared() = runBlocking {
        seed(SESSION, AuthToken("stored", "refresh", NOW + 3_600_000))

        service().clearSessions(setOf(SESSION))

        assertNull(stored())
    }

    // Sweeping somebody else's session has to be invisible here, or a chat
    // loses a good token to a clean up that was never about it.
    @Test
    fun keepsServingItsTokenWhenAnotherSessionIsCleared() = runBlocking {
        seed("other", AuthToken("other-access", "other-refresh", NOW))
        auth.willAnswer(AuthCredentials("issued", "refresh", 3_600))
        val service = service()
        service.token()

        service.clearSessions(setOf("other"))

        assertEquals("issued", service.token().getOrNull())
        assertEquals(1, auth.calls)
    }

    @Test
    fun authenticatesAgainOnceItsOwnSessionIsCleared() = runBlocking {
        auth.willAnswer(AuthCredentials("first", "refresh", 3_600))
        auth.willAnswer(AuthCredentials("second", "refresh", 3_600))
        val service = service()
        service.token()

        service.clearSessions(setOf(SESSION))

        assertEquals("second", service.token().getOrNull())
    }

    @Test
    fun forgetsEveryStoredSessionWhenEverySessionIsCleared() = runBlocking {
        seed("a", AuthToken("a-access", "a-refresh", NOW))
        seed(SESSION, AuthToken("stored", "refresh", NOW + 3_600_000))

        withTimeout(TIMEOUT_MILLIS) { service().clearAllSessions() }

        assertEquals(emptySet<String>(), storedSessionIds())
    }

    @Test
    fun authenticatesAgainOnceEverySessionIsCleared() = runBlocking {
        auth.willAnswer(AuthCredentials("first", "refresh", 3_600))
        auth.willAnswer(AuthCredentials("second", "refresh", 3_600))
        val service = service()
        service.token()

        withTimeout(TIMEOUT_MILLIS) { service.clearAllSessions() }

        assertEquals("second", service.token().getOrNull())
    }

    @Test
    fun failsTheCallersWaitingForATokenWhenEverySessionIsCleared() = runBlocking {
        auth.willAnswer(AuthCredentials("access", "refresh", 3_600), delayMillis = 2_000)
        val service = service()
        val waiting = async(Dispatchers.IO) { service.token() }
        auth.awaitCall()

        withTimeout(TIMEOUT_MILLIS) { service.clearAllSessions() }

        assertTrue(waiting.await().exceptionOrNull() is AuthSessionClearedException)
    }

    // The reply lands on a connection that has already moved on, so nothing it
    // carries may be written back.
    @Test
    fun storesNothingWhenAuthenticationAnswersAfterEverySessionIsCleared() = runBlocking {
        auth.willAnswer(AuthCredentials("late", "refresh", 3_600), delayMillis = 500)
        val service = service()
        val waiting = async(Dispatchers.IO) { service.token() }
        auth.awaitCall()

        withTimeout(TIMEOUT_MILLIS) { service.clearAllSessions() }
        waiting.await()

        assertEquals(emptySet<String>(), storedSessionIds())
    }

    @Test
    fun keepsTheSessionEphemeralWhenTheChatIsConfiguredThatWay() = runBlocking {
        auth.willAnswer(AuthCredentials("access", "refresh", 3_600))

        service(config(sessionMode = SessionMode.Ephemeral)).token()

        assertEquals(true, stored()?.ephemeral)
    }

    @Test
    fun keepsTheSessionDurableByDefault() = runBlocking {
        auth.willAnswer(AuthCredentials("access", "refresh", 3_600))

        service().token()

        assertEquals(false, stored()?.ephemeral)
    }

    @Test
    fun leavesNoTokenReadableOnTheDevice() = runBlocking {
        auth.willAnswer(AuthCredentials("secret-access", "secret-refresh", 3_600))

        service().token()

        val value = requireNotNull(storedValue("token:$SESSION"))
        assertTrue("secret-access" !in value && "secret-refresh" !in value)
    }

    @Test
    fun keepsOneSessionsTokenOutOfAnothers() = runBlocking {
        seed("other", AuthToken("other-access", "other-refresh", NOW + 3_600_000))
        seed(SESSION, AuthToken("mine", "refresh", NOW + 3_600_000))

        assertEquals("mine", service().token().getOrNull())
        assertEquals(0, auth.calls)
    }

    @Test
    fun authenticatesWhenTheStoredTokenCannotBeDecrypted() = runBlocking {
        writeRaw("not something we wrote", "token:$SESSION")
        auth.willAnswer(AuthCredentials("fresh", "refresh", 3_600))

        assertEquals("fresh", service(cipher = FailingCipher()).token().getOrNull())
    }

    @Test
    fun authenticatesWhenTheStoredValueIsNoLongerReadableAtAll() = runBlocking {
        writeRaw("not something we wrote", "token:$SESSION")
        auth.willAnswer(AuthCredentials("fresh", "refresh", 3_600))
        val cipher = FailingCipher { IllegalArgumentException("not base64") }

        assertEquals("fresh", service(cipher = cipher).token().getOrNull())
    }

    @Test
    fun authenticatesWhenTheStoredValueIsNotAToken() = runBlocking {
        writeRaw(ReversingCipher().encrypt("""{"unexpected":true}"""), "token:$SESSION")
        auth.willAnswer(AuthCredentials("fresh", "refresh", 3_600))

        assertEquals("fresh", service().token().getOrNull())
    }

    @Test
    fun throwsAwayAStoredValueItCannotDecrypt() = runBlocking {
        writeRaw("not something we wrote", "token:$SESSION")
        auth.willAnswer(AuthCredentials("access", "refresh", 3_600))

        service(cipher = FailingCipher()).token()

        assertNull(storedValue("token:$SESSION"))
    }

    @Test
    fun keepsWorkingWhenTheTokenCannotBeEncrypted() = runBlocking {
        auth.willAnswer(AuthCredentials("issued", "refresh", 3_600))

        val result = service(cipher = FailingCipher()).token()

        assertEquals("issued", result.getOrNull())
        assertNull(storedValue("token:$SESSION"))
    }

    @Test
    fun keepsWorkingWhenTheDeviceCannotBeRead() = runBlocking {
        auth.willAnswer(AuthCredentials("issued", "refresh", 3_600))

        assertEquals("issued", service(store = unreadableStore()).token().getOrNull())
    }

    @Test
    fun leavesASessionItCannotReadOutOfTheListing() = runBlocking {
        seed("a", AuthToken("a-access", "a-refresh", NOW))
        writeRaw("not something we wrote", "token:b")

        assertEquals(setOf("a"), service().storedSessions().keys)
    }

    // Listing runs over every session, so turning one unreadable value into a
    // delete would let a sweep reclaim what it cannot even identify.
    @Test
    fun leavesASessionItCannotReadOnTheDevice() = runBlocking {
        writeRaw("not something we wrote", "token:b")

        service().storedSessions()

        assertNotNull(storedValue("token:b"))
    }

    @Test
    fun ignoresEntriesThatAreNotStoredTokens() = runBlocking {
        writeRaw("something else", "other:thing")
        writeRaw(ReversingCipher().encrypt("{}"), "token:")

        assertEquals(emptyMap<String, AuthToken>(), service().storedSessions())
    }

    @Test
    fun listsNoSessionsWhenTheDeviceCannotBeRead() = runBlocking {
        assertEquals(emptyMap<String, AuthToken>(), service(store = unreadableStore()).storedSessions())
    }

    @Test
    fun forgetsTheSessionsItCanWhenOneOfThemHasNoToken() = runBlocking {
        seed("a", AuthToken("a-access", "a-refresh", NOW))

        service().clearSessions(setOf("a", "never-stored"))

        assertEquals(emptySet<String>(), storedSessionIds())
    }

    @Test
    fun leavesEverySessionAloneWhenItIsGivenNone() = runBlocking {
        seed("a", AuthToken("a-access", "a-refresh", NOW))

        service().clearSessions(emptySet())

        assertEquals(setOf("a"), storedSessionIds())
    }

    @Test
    fun keepsWorkingWhenTheSessionsCannotBeForgotten() = runBlocking {
        service(store = unreadableStore()).clearSessions(setOf("a"))
    }

    // The listing cannot see these, so clearing everything has to work by name
    // rather than by what it managed to read.
    @Test
    fun forgetsEvenTheSessionsItCannotRead() = runBlocking {
        writeRaw("not something we wrote", "token:b")

        withTimeout(TIMEOUT_MILLIS) { service().clearAllSessions() }

        assertNull(storedValue("token:b"))
    }

    @Test
    fun leavesEntriesThatAreNotStoredTokensWhenItForgetsEverySession() = runBlocking {
        writeRaw("something else", "other:thing")

        withTimeout(TIMEOUT_MILLIS) { service().clearAllSessions() }

        assertNotNull(storedValue("other:thing"))
    }

    private fun service(
        config: YaloChatClientConfig = config(),
        store: DataStore<Preferences> = this.store,
        cipher: TokenCipher = ReversingCipher(),
    ): TokenRepositoryLocal = TokenRepositoryLocal(
        config = config,
        auth = auth,
        store = store,
        scope = scope,
        cipher = cipher,
        now = { NOW },
        logLevel = LogLevel.Debug,
    )

    private fun config(
        userId: String? = null,
        sessionMode: SessionMode = SessionMode.Shared,
    ) = YaloChatClientConfig(
        channelId = "channel-1",
        organizationId = "org-1",
        channelName = "Support",
        userId = userId,
        sessionMode = sessionMode,
    )

    /** Stands in for the backend: no HTTP, and every answer is chosen by the test. */
    private class FakeAuthService : YaloMessageAuthService {
        private val answers = ArrayDeque<Pair<Result<AuthCredentials>, Long>>()
        private val called = Channel<Unit>(Channel.UNLIMITED)

        var calls: Int = 0
            private set
        val refreshed = mutableListOf<String>()

        fun willAnswer(credentials: AuthCredentials, delayMillis: Long = 0) {
            answers += Result.success(credentials) to delayMillis
        }

        fun willFail(cause: Throwable) {
            answers += Result.failure<AuthCredentials>(cause) to 0L
        }

        suspend fun awaitCall() {
            called.receive()
        }

        override suspend fun fetchToken(): Result<AuthCredentials> = answer()

        override suspend fun refreshToken(refreshToken: String): Result<AuthCredentials> {
            refreshed += refreshToken
            return answer()
        }

        private suspend fun answer(): Result<AuthCredentials> {
            calls++
            called.send(Unit)
            val (result, delayMillis) = answers.removeFirstOrNull()
                ?: error("the test did not say what the backend should answer")
            if (delayMillis > 0) {
                delay(delayMillis)
            }
            return result
        }
    }

    // Seeds and reads the device the way the service writes it, so a test can
    // say what was already there before this chat opened.
    private suspend fun seed(sessionId: String, token: AuthToken) {
        val json = JSONObject()
            .put("access", token.accessToken)
            .put("refresh", token.refreshToken)
            .put("expiresAt", token.expiresAtMillis)
            .put("ephemeral", token.ephemeral)
            .toString()
        writeRaw(ReversingCipher().encrypt(json), "token:$sessionId")
    }

    private suspend fun writeRaw(value: String, key: String) {
        store.edit { preferences -> preferences[stringPreferencesKey(key)] = value }
    }

    private suspend fun storedValue(key: String): String? =
        store.data.first()[stringPreferencesKey(key)]

    private suspend fun stored(sessionId: String = SESSION): AuthToken? {
        val value = storedValue("token:$sessionId") ?: return null
        val fields = JSONObject(ReversingCipher().decrypt(value))
        return AuthToken(
            accessToken = fields.getString("access"),
            refreshToken = fields.getString("refresh"),
            expiresAtMillis = fields.getLong("expiresAt"),
            ephemeral = fields.optBoolean("ephemeral", false),
        )
    }

    private suspend fun storedSessionIds(): Set<String> = store.data.first().asMap().keys
        .map { key -> key.name }
        .filter { name -> name.startsWith("token:") }
        .mapTo(mutableSetOf()) { name -> name.removePrefix("token:") }

    // A store that fails the way an unreadable or full disk does. Pointing
    // DataStore at a path it cannot create is not enough: it reports that
    // lazily and these tests would pass without ever reaching the failure.
    private fun unreadableStore(): DataStore<Preferences> = object : DataStore<Preferences> {
        override val data: Flow<Preferences> = flow { throw IOException("cannot be read") }

        override suspend fun updateData(
            transform: suspend (Preferences) -> Preferences,
        ): Preferences = throw IOException("cannot be written")
    }

    /** Stands in for the keystore: not encryption, but not the plain text either. */
    private class ReversingCipher : TokenCipher {
        override fun encrypt(plain: String): String = plain.reversed()

        override fun decrypt(encrypted: String): String = encrypted.reversed()
    }

    /**
     * Fails the way the real one does: no key at all raises
     * [GeneralSecurityException], and a value that is not base64 any more
     * raises [IllegalArgumentException] before the key is ever reached.
     */
    private class FailingCipher(
        private val error: () -> Throwable = { GeneralSecurityException("no key") },
    ) : TokenCipher {
        override fun encrypt(plain: String): String {
            throw error()
        }

        override fun decrypt(encrypted: String): String {
            throw error()
        }
    }

    private companion object {
        const val NOW = 1_700_000_000_000L

        /** What `config()` resolves to, so the fake and the service agree. */
        const val SESSION = "org-1-channel-1-anonymous"

        // The mutex behind these is not reentrant, and a self deadlock would
        // hang the run rather than fail it.
        const val TIMEOUT_MILLIS = 5_000L
    }
}

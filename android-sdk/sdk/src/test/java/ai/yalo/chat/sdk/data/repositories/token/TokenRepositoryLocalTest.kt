// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.token

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.common.crypto.TokenCipher
import ai.yalo.chat.sdk.data.datasources.auth.YaloMessageAuthDataSource
import ai.yalo.chat.sdk.domain.models.AuthToken
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import java.io.File
import java.io.IOException
import java.security.GeneralSecurityException

/**
 * The keystore is not available off a device, so these run against a cipher
 * that stands in for it. The real one is covered by
 * `KeystoreTokenCipherInstrumentedTest`.
 */
@RunWith(RobolectricTestRunner::class)
class TokenRepositoryLocalTest {

    private lateinit var file: File
    private lateinit var store: DataStore<Preferences>
    private val dataSource = FakeAuthDataSource()

    @Before
    fun createStore() {
        file = File.createTempFile("auth_token", ".preferences_pb").also { it.delete() }
        store = PreferenceDataStoreFactory.create { file }
    }

    @After
    fun deleteStore() {
        file.delete()
    }

    @Test
    fun authenticatesWhenTheDeviceHasNothingToOffer() = runBlocking {
        dataSource.issued = AuthToken("issued", "refresh", LATER)

        assertEquals("issued", repository().token().getOrNull())
        assertEquals(1, dataSource.authentications)
    }

    @Test
    fun handsOutTheTokenItAlreadyHasInsteadOfAskingAgain() = runBlocking {
        val repository = repository()
        repository.token()

        assertEquals("access", repository.token().getOrNull())
        assertEquals(1, dataSource.authentications)
    }

    @Test
    fun asksTheBackendOnceWhenTwoCallersAskAtTheSameTime() = runBlocking {
        dataSource.delayMillis = 50
        val repository = repository()

        val answers = listOf(
            async { repository.token() },
            async { repository.token() },
        ).awaitAll()

        assertEquals(listOf("access", "access"), answers.map { answer -> answer.getOrNull() })
        assertEquals(1, dataSource.authentications)
    }

    @Test
    fun usesTheTokenTheLastRunLeftBehindWithoutTalkingToTheBackend() = runBlocking {
        repository().token()

        assertEquals("access", repository().token().getOrNull())
        assertEquals(1, dataSource.authentications)
    }

    @Test
    fun refreshesATokenThatHasRunOutRatherThanStartingOver() = runBlocking {
        dataSource.issued = AuthToken("expired", "the-refresh-token", NOW - 1)
        dataSource.refreshedInto = AuthToken("refreshed", "the-refresh-token", LATER)
        val repository = repository()
        repository.token()

        assertEquals("refreshed", repository.token().getOrNull())
        assertEquals(listOf("the-refresh-token"), dataSource.traded)
    }

    @Test
    fun authenticatesAgainWhenTheBackendWillNotRefresh() = runBlocking {
        dataSource.issued = AuthToken("expired", "stale-refresh", NOW - 1)
        dataSource.refreshFailure = IOException("Refresh failed: 403")
        val repository = repository()
        repository.token()
        dataSource.issued = AuthToken("fresh", "refresh", LATER)

        assertEquals("fresh", repository.token().getOrNull())
        assertEquals(2, dataSource.authentications)
    }

    @Test
    fun authenticatesWhenWhatItHoldsHasRunOutAndCannotBeRefreshed() = runBlocking {
        dataSource.issued = AuthToken("expired", "", NOW - 1)
        val repository = repository()
        repository.token()

        repository.token()

        assertEquals(2, dataSource.authentications)
        assertTrue(dataSource.traded.isEmpty())
    }

    @Test
    fun reportsTheFailureWhenThereIsNoTokenToBeHad() = runBlocking {
        dataSource.authFailure = IOException("Auth failed: 401")

        val result = repository().token()

        assertEquals("Auth failed: 401", result.exceptionOrNull()?.message)
    }

    @Test
    fun replacesATokenTheBackendStoppedAccepting() = runBlocking {
        dataSource.refreshedInto = AuthToken("replacement", "refresh", LATER)
        val repository = repository()
        repository.token()

        repository.invalidateToken()

        assertEquals("replacement", repository.token().getOrNull())
        assertEquals(listOf("refresh"), dataSource.traded)
    }

    @Test
    fun remembersThatATokenWasRefusedAfterTheAppIsClosed() = runBlocking {
        dataSource.refreshedInto = AuthToken("replacement", "refresh", LATER)
        repository().token()

        repository().invalidateToken()

        assertEquals("replacement", repository().token().getOrNull())
    }

    @Test
    fun hasNothingToInvalidateBeforeATokenIsAskedFor() = runBlocking {
        repository().invalidateToken()

        assertEquals(0, dataSource.authentications)
        assertNull(storedValue())
    }

    @Test
    fun forgetsTheSessionWhenAskedTo() = runBlocking {
        val repository = repository()
        repository.token()

        repository.clearSession()

        assertNull(storedValue())
    }

    @Test
    fun authenticatesAsSomebodyElseOnceTheSessionIsForgotten() = runBlocking {
        val repository = repository()
        repository.token()
        repository.clearSession()

        repository.token()

        assertEquals(2, dataSource.authentications)
    }

    @Test
    fun keepsOneSessionsTokenOutOfAnothers() = runBlocking {
        dataSource.issued = AuthToken("for-a", "refresh", LATER)
        repository(sessionId = "a").token()
        dataSource.issued = AuthToken("for-b", "refresh", LATER)
        repository(sessionId = "b").token()

        assertEquals("for-a", repository(sessionId = "a").token().getOrNull())
        assertEquals("for-b", repository(sessionId = "b").token().getOrNull())
    }

    @Test
    fun clearingOneSessionLeavesTheOtherAlone() = runBlocking {
        repository(sessionId = "a").token()
        dataSource.issued = AuthToken("for-b", "refresh", LATER)
        repository(sessionId = "b").token()

        repository(sessionId = "a").clearSession()

        assertNull(storedValue(sessionId = "a"))
        assertEquals("for-b", repository(sessionId = "b").token().getOrNull())
    }

    @Test
    fun leavesNoTokenReadableInTheFile() = runBlocking {
        dataSource.issued = AuthToken("secret-access", "secret-refresh", LATER)

        repository().token()

        val stored = requireNotNull(storedValue())
        assertFalse(stored.contains("secret-access"))
        assertFalse(stored.contains("secret-refresh"))
    }

    @Test
    fun authenticatesWhenTheStoredTokenCannotBeDecrypted() = runBlocking {
        writeRaw("not something we wrote")

        assertEquals("access", repository(cipher = FailingCipher()).token().getOrNull())
    }

    @Test
    fun replacesAStoredValueThatIsNotAToken() = runBlocking {
        val nonsense = ReversingCipher().encrypt("""{"unexpected":true}""")
        writeRaw(nonsense)

        assertEquals("access", repository().token().getOrNull())
        assertNotEquals(nonsense, storedValue())
    }

    @Test
    fun keepsWorkingWhenTheTokenCannotBeEncrypted() = runBlocking {
        val repository = repository(cipher = FailingCipher())

        assertEquals("access", repository.token().getOrNull())
        assertNull(storedValue())
    }

    @Test
    fun authenticatesWhenTheStoredValueIsNotEvenCipherText() = runBlocking {
        writeRaw("not base 64")

        assertEquals("access", repository(cipher = UndecodableCipher()).token().getOrNull())
    }

    @Test
    fun keepsWorkingWhenTheFileWasWrittenBySomethingElse() = runBlocking {
        val corrupt = File.createTempFile("corrupt", ".preferences_pb")
        // A field that says it carries 127 bytes and then stops, so the file
        // cannot be read back as preferences at all.
        corrupt.writeBytes(byteArrayOf(0x0A, 0x7F))

        val repository = TokenRepositoryLocal(
            dataSource = dataSource,
            store = PreferenceDataStoreFactory.create { corrupt },
            sessionId = "session",
            cipher = ReversingCipher(),
        )

        assertEquals("access", repository.token().getOrNull())
    }

    @Test
    fun keepsWorkingWhenTheTokenCannotBeWrittenOrForgotten() = runBlocking {
        // A store whose file can never be opened: its parent is an ordinary
        // file, so the directory it needs cannot be created.
        val blocker = File.createTempFile("blocker", ".tmp")
        val repository = TokenRepositoryLocal(
            dataSource = dataSource,
            store = PreferenceDataStoreFactory.create { File(blocker, "auth.preferences_pb") },
            sessionId = "session",
            cipher = ReversingCipher(),
        )

        assertEquals("access", repository.token().getOrNull())
        repository.clearSession()
    }

    @Test
    fun buildsARepositoryForASessionFromAContext() = runBlocking {
        val repository = TokenRepositoryLocal.of(
            context = RuntimeEnvironment.getApplication(),
            dataSource = dataSource,
            sessionId = "session",
            cipher = ReversingCipher(),
        )

        assertEquals("access", repository.token().getOrNull())
        repository.clearSession()
    }

    private suspend fun storedValue(sessionId: String = "session"): String? =
        store.data.first()[stringPreferencesKey("token:$sessionId")]

    private suspend fun writeRaw(value: String) {
        store.edit { preferences ->
            preferences[stringPreferencesKey("token:session")] = value
        }
    }

    private fun repository(
        sessionId: String = "session",
        cipher: TokenCipher = ReversingCipher(),
    ): TokenRepositoryLocal = TokenRepositoryLocal(
        dataSource = dataSource,
        store = store,
        sessionId = sessionId,
        cipher = cipher,
        now = { NOW },
        logLevel = LogLevel.Debug,
    )

    private class FakeAuthDataSource : YaloMessageAuthDataSource {

        var issued: AuthToken = AuthToken("access", "refresh", LATER)
        var refreshedInto: AuthToken = AuthToken("refreshed", "refresh", LATER)
        var authFailure: Throwable? = null
        var refreshFailure: Throwable? = null
        var delayMillis: Long = 0
        var authentications: Int = 0

        /** The refresh tokens it was asked to trade, in the order they came. */
        val traded = mutableListOf<String>()

        override suspend fun authenticate(): Result<AuthToken> {
            authentications++
            delay(delayMillis)
            return authFailure?.let { cause -> Result.failure(cause) } ?: Result.success(issued)
        }

        override suspend fun refresh(refreshToken: String): Result<AuthToken> {
            traded += refreshToken
            delay(delayMillis)
            return refreshFailure?.let { cause -> Result.failure(cause) }
                ?: Result.success(refreshedInto)
        }
    }

    /** Stands in for the keystore: not encryption, but not the plain text either. */
    private class ReversingCipher : TokenCipher {
        override fun encrypt(plain: String): String = plain.reversed()

        override fun decrypt(encrypted: String): String = encrypted.reversed()
    }

    /** Stands in for a keystore that has lost the key. */
    private class FailingCipher : TokenCipher {
        override fun encrypt(plain: String): String {
            throw GeneralSecurityException("no key")
        }

        override fun decrypt(encrypted: String): String {
            throw GeneralSecurityException("no key")
        }
    }

    /** Stands in for a keystore handed something that is not cipher text. */
    private class UndecodableCipher : TokenCipher {
        override fun encrypt(plain: String): String = plain

        override fun decrypt(encrypted: String): String {
            throw IllegalArgumentException("not base 64")
        }
    }

    private companion object {
        const val NOW = 1_700_000_000_000L
        const val LATER = NOW + 3_600_000L
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

import ai.yalo.chat.sdk.LogLevel
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.io.File
import java.security.GeneralSecurityException

/**
 * The keystore is not available off a device, so these run against a cipher
 * that stands in for it. The real one is covered by
 * `KeystoreTokenCipherInstrumentedTest`.
 */
@RunWith(RobolectricTestRunner::class)
class AuthTokenStorageLocalTest {

    private lateinit var file: File
    private lateinit var store: DataStore<Preferences>

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
    fun readsBackWhatItWasGiven() = runBlocking {
        val storage = storage()

        storage.write(AuthToken("access", "refresh", 1_700_000_000_000L))

        assertEquals(AuthToken("access", "refresh", 1_700_000_000_000L), storage.read())
    }

    @Test
    fun hasNothingBeforeAnythingIsStored() = runBlocking {
        assertNull(storage().read())
    }

    @Test
    fun replacesTheTokenItWasHoldingOnTo() = runBlocking {
        val storage = storage()
        storage.write(AuthToken("first", "refresh", 1L))

        storage.write(AuthToken("second", "refresh", 2L))

        assertEquals(AuthToken("second", "refresh", 2L), storage.read())
    }

    @Test
    fun forgetsTheTokenWhenAskedTo() = runBlocking {
        val storage = storage()
        storage.write(AuthToken("access", "refresh", 1L))

        storage.clear()

        assertNull(storage.read())
    }

    @Test
    fun keepsOneSessionsTokenOutOfAnothers() = runBlocking {
        storage(sessionId = "a").write(AuthToken("a-access", "a-refresh", 1L))
        storage(sessionId = "b").write(AuthToken("b-access", "b-refresh", 2L))

        assertEquals(AuthToken("a-access", "a-refresh", 1L), storage(sessionId = "a").read())
        assertEquals(AuthToken("b-access", "b-refresh", 2L), storage(sessionId = "b").read())
    }

    @Test
    fun clearingOneSessionLeavesTheOtherAlone() = runBlocking {
        storage(sessionId = "a").write(AuthToken("a-access", "a-refresh", 1L))
        storage(sessionId = "b").write(AuthToken("b-access", "b-refresh", 2L))

        storage(sessionId = "a").clear()

        assertNull(storage(sessionId = "a").read())
        assertEquals(AuthToken("b-access", "b-refresh", 2L), storage(sessionId = "b").read())
    }

    @Test
    fun leavesNoTokenReadableInTheFile() = runBlocking {
        storage().write(AuthToken("secret-access", "secret-refresh", 1L))

        val stored = requireNotNull(storedValue())
        assertFalse(stored.contains("secret-access"))
        assertFalse(stored.contains("secret-refresh"))
    }

    @Test
    fun reportsNoTokenWhenTheStoredValueCannotBeDecrypted() = runBlocking {
        val storage = storage(cipher = FailingCipher())
        writeRaw("not something we wrote")

        assertNull(storage.read())
    }

    @Test
    fun throwsAwayAStoredValueItCannotDecrypt() = runBlocking {
        val storage = storage(cipher = FailingCipher())
        writeRaw("not something we wrote")

        storage.read()

        assertNull(storedValue())
    }

    @Test
    fun reportsNoTokenWhenTheStoredValueIsNotAToken() = runBlocking {
        val storage = storage()
        writeRaw(ReversingCipher().encrypt("{\"unexpected\":true}"))

        assertNull(storage.read())
    }

    @Test
    fun storesNothingWhenTheTokenCannotBeEncrypted() = runBlocking {
        val storage = storage(cipher = FailingCipher())

        storage.write(AuthToken("access", "refresh", 1L))

        assertNull(storedValue())
    }

    @Test
    fun reportsNoTokenWhenTheFileWasWrittenBySomethingElse() = runBlocking {
        val corrupt = File.createTempFile("corrupt", ".preferences_pb")
        corrupt.writeBytes(byteArrayOf(9, 9, 9, 9, 9))
        val store = PreferenceDataStoreFactory.create { corrupt }

        assertNull(AuthTokenStorageLocal(store, "session", ReversingCipher()).read())
    }

    @Test
    fun keepsWorkingWhenTheTokenCannotBeWritten() = runBlocking {
        val storage = AuthTokenStorageLocal(unreadableStore(), "session", ReversingCipher())

        storage.write(AuthToken("access", "refresh", 1L))

        assertNull(storage.read())
    }

    @Test
    fun keepsWorkingWhenTheFileCannotBeCleared() = runBlocking {
        AuthTokenStorageLocal(unreadableStore(), "session", ReversingCipher()).clear()
    }

    @Test
    fun buildsAStorageForASessionFromAContext() = runBlocking {
        val storage = AuthTokenStorageLocal.of(
            context = org.robolectric.RuntimeEnvironment.getApplication(),
            sessionId = "session",
            cipher = ReversingCipher(),
        )

        storage.write(AuthToken("access", "refresh", 1L))

        assertNotNull(storage.read())
        storage.clear()
    }

    // A store whose file can never be opened: its parent is an ordinary file,
    // so the directory it needs cannot be created.
    private fun unreadableStore(): DataStore<Preferences> {
        val blocker = File.createTempFile("blocker", ".tmp")
        return PreferenceDataStoreFactory.create { File(blocker, "auth.preferences_pb") }
    }

    private suspend fun storedValue(): String? =
        store.data.first()[stringPreferencesKey("token:session")]

    private suspend fun writeRaw(value: String) {
        store.edit { preferences ->
            preferences[stringPreferencesKey("token:session")] = value
        }
    }

    private fun storage(
        sessionId: String = "session",
        cipher: TokenCipher = ReversingCipher(),
    ): AuthTokenStorageLocal = AuthTokenStorageLocal(store, sessionId, cipher, LogLevel.Debug)

    /** Stands in for the keystore: not encryption, but not the plain text either. */
    private class ReversingCipher : TokenCipher {
        override fun encrypt(plain: String): String = plain.reversed()

        override fun decrypt(encrypted: String): String = encrypted.reversed()
    }

    private class FailingCipher : TokenCipher {
        override fun encrypt(plain: String): String {
            throw GeneralSecurityException("no key")
        }

        override fun decrypt(encrypted: String): String {
            throw GeneralSecurityException("no key")
        }
    }
}

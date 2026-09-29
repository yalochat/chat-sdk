// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.token

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.common.crypto.KeystoreTokenCipher
import ai.yalo.chat.sdk.common.crypto.TokenCipher
import ai.yalo.chat.sdk.data.datasources.auth.YaloMessageAuthDataSource
import ai.yalo.chat.sdk.domain.models.AuthToken
import ai.yalo.chat.sdk.log.YaloLog
import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.security.GeneralSecurityException

/**
 * Holds one conversation's token, in memory while the chat is open and in a
 * DataStore so it survives the app being closed.
 *
 * Everything runs under [mutex], which is what makes two callers arriving at
 * once cost one exchange with the backend rather than two: the second finds
 * what the first went and got.
 *
 * DataStore rather than shared preferences because writes are ordered against
 * each other: on plain preferences a slow delete can land after the write and
 * take a good token with it. Values are encrypted under a key that never leaves
 * the device's keystore, the refresh token being a way back into the
 * conversation for as long as the backend honours it.
 *
 * Storing is an optimisation, so every failure to read or write is answered by
 * authenticating again rather than by raising.
 */
internal class TokenRepositoryLocal(
    private val dataSource: YaloMessageAuthDataSource,
    private val store: DataStore<Preferences>,
    private val sessionId: String,
    private val ephemeral: Boolean = false,
    private val cipher: TokenCipher = KeystoreTokenCipher(),
    private val now: () -> Long = System::currentTimeMillis,
    logLevel: LogLevel = LogLevel.Warn,
) : TokenRepository {

    private val log = YaloLog(LOG_NAME, logLevel)
    private val entry: Preferences.Key<String> = stringPreferencesKey("$KEY_PREFIX$sessionId")
    private val mutex = Mutex()
    private var held: AuthToken? = null

    override suspend fun token(): Result<String> = mutex.withLock {
        val current = current()
        if (current != null && current.usableAt(now())) {
            log.debug { "the token in hand is still good" }
            return@withLock Result.success(current.accessToken)
        }
        val refreshToken = current?.refreshToken
        val issued = when {
            refreshToken.isNullOrBlank() -> authenticate()
            else -> refresh(refreshToken)
        }
        issued.map { token -> token.accessToken }
    }

    override suspend fun invalidateToken() {
        mutex.withLock {
            // Only the access token is spent, so the refresh token is kept:
            // authenticating again would be a new anonymous person to the
            // backend, and the conversation would start empty.
            val spent = current()?.copy(expiresAtMillis = 0) ?: return@withLock
            log.info { "the backend refused the token, the next one will be another" }
            keep(spent)
        }
    }

    override suspend fun clearSession() {
        mutex.withLock {
            log.info { "forgetting the session" }
            forget()
        }
    }

    override suspend fun deleteSessions(sessionIds: List<String>): Result<Unit> {
        if (sessionIds.isEmpty()) {
            return Result.success(Unit)
        }
        return mutex.withLock {
            try {
                store.edit { preferences ->
                    for (id in sessionIds) {
                        preferences.remove(stringPreferencesKey("$KEY_PREFIX$id"))
                    }
                }
                if (sessionIds.contains(sessionId)) {
                    held = null
                }
                log.debug { "forgot ${sessionIds.size} stored tokens" }
                Result.success(Unit)
            } catch (error: IOException) {
                log.warn(error) { "the stored tokens cannot be forgotten" }
                Result.failure(error)
            }
        }
    }

    override suspend fun ephemeralSessions(): Set<String> = preferences().asMap()
        .filterKeys { key -> key.name.startsWith(KEY_PREFIX) }
        .filterValues { stored -> stored is String && stored.startsWith(EPHEMERAL) }
        .keys
        .mapTo(mutableSetOf()) { key -> key.name.removePrefix(KEY_PREFIX) }

    /** What this conversation holds, read back from the device the first time. */
    private suspend fun current(): AuthToken? = held ?: read()?.also { stored -> held = stored }

    private suspend fun refresh(refreshToken: String): Result<AuthToken> =
        dataSource.refresh(refreshToken).fold(
            onSuccess = { token -> Result.success(keep(token)) },
            onFailure = {
                log.info { "the refresh was refused, authenticating instead" }
                authenticate()
            },
        )

    private suspend fun authenticate(): Result<AuthToken> {
        // What is on the device is what led here, and it goes before the round
        // trip rather than after: a failure must not leave it to be tried again.
        forget()
        return dataSource.authenticate().map { token -> keep(token) }
    }

    private suspend fun keep(token: AuthToken): AuthToken {
        held = token
        val encrypted = try {
            cipher.encrypt(encode(token))
        } catch (error: GeneralSecurityException) {
            log.warn(error) { "the token cannot be encrypted, keeping it for this run only" }
            return token
        }
        val mark = if (ephemeral) EPHEMERAL else PERSISTENT
        try {
            store.edit { preferences -> preferences[entry] = mark + encrypted }
            log.debug { "stored the token" }
        } catch (error: IOException) {
            log.warn(error) { "the token cannot be stored, keeping it for this run only" }
        }
        return token
    }

    private suspend fun preferences(): Preferences = store.data
        .catch { error ->
            if (error is IOException) {
                emit(emptyPreferences())
            } else {
                throw error
            }
        }
        .first()

    private suspend fun read(): AuthToken? {
        val stored = preferences()[entry] ?: return null

        return try {
            decode(cipher.decrypt(stored.drop(1)))
        } catch (error: GeneralSecurityException) {
            // The key is gone or the value was not written by it, so there is
            // nothing to recover.
            unreadable(error)
        } catch (error: JSONException) {
            unreadable(error)
        } catch (error: IllegalArgumentException) {
            unreadable(error)
        }
    }

    private suspend fun unreadable(error: Throwable): AuthToken? {
        log.warn(error) { "the stored token cannot be read, forgetting it" }
        forget()
        return null
    }

    private suspend fun forget() {
        held = null
        try {
            store.edit { preferences -> preferences.remove(entry) }
            log.debug { "forgot the stored token" }
        } catch (error: IOException) {
            log.warn(error) { "the stored token cannot be forgotten" }
        }
    }

    private fun encode(token: AuthToken): String = JSONObject()
        .put(FIELD_ACCESS_TOKEN, token.accessToken)
        .put(FIELD_REFRESH_TOKEN, token.refreshToken)
        .put(FIELD_EXPIRES_AT, token.expiresAtMillis)
        .toString()

    private fun decode(json: String): AuthToken {
        val fields = JSONObject(json)
        return AuthToken(
            accessToken = fields.getString(FIELD_ACCESS_TOKEN),
            refreshToken = fields.getString(FIELD_REFRESH_TOKEN),
            expiresAtMillis = fields.getLong(FIELD_EXPIRES_AT),
        )
    }

    companion object {

        /** The token for one session, on the file every session shares. */
        fun of(
            context: Context,
            dataSource: YaloMessageAuthDataSource,
            sessionId: String,
            ephemeral: Boolean = false,
            cipher: TokenCipher = KeystoreTokenCipher(),
            logLevel: LogLevel = LogLevel.Warn,
        ): TokenRepositoryLocal = TokenRepositoryLocal(
            dataSource = dataSource,
            store = context.applicationContext.authTokenStore,
            sessionId = sessionId,
            ephemeral = ephemeral,
            cipher = cipher,
            logLevel = logLevel,
        )

        private const val LOG_NAME = "Token"
        private const val KEY_PREFIX = "token:"
        private const val FIELD_ACCESS_TOKEN = "access"
        private const val FIELD_REFRESH_TOKEN = "refresh"
        private const val FIELD_EXPIRES_AT = "expiresAt"

        // Which kind of session stored the token, in front of it rather than
        // inside it: a sweep has to be able to tell after the key that
        // encrypted it has gone, and a device restored from a backup brings
        // the file back without the key.
        private const val EPHEMERAL = "e"
        private const val PERSISTENT = "p"
    }
}

// DataStore allows a single instance per file per process, so the delegate is
// what keeps several open chats from fighting over it.
private val Context.authTokenStore: DataStore<Preferences> by preferencesDataStore(
    name = "yalo_chat_auth",
)

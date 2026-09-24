// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.token

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.SessionMode
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.data.services.auth.YaloMessageAuthService
import ai.yalo.chat.sdk.log.YaloLog
import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.MutablePreferences
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.security.GeneralSecurityException

// DataStore allows a single instance per file per process, so the delegate is
// what keeps several open chats from fighting over it.
internal val Context.authTokenStore: DataStore<Preferences> by preferencesDataStore(
    name = "yalo_chat_auth",
)

/**
 * Keeps the token for one conversation, on the device and in memory.
 *
 * Tokens live in one DataStore file, an entry per session, encrypted under a key
 * that never leaves the device's keystore. Nothing about the device raises: a token
 * that cannot be read back is reported as no token, which costs a round trip rather
 * than a chat that will not open.
 *
 * State runs under [mutex], the round trips outside it.
 */
internal class TokenRepositoryLocal(
    private val config: YaloChatClientConfig,
    private val auth: YaloMessageAuthService,
    private val store: DataStore<Preferences>,
    private val scope: CoroutineScope,
    private val cipher: TokenCipher = KeystoreTokenCipher(),
    private val now: () -> Long = System::currentTimeMillis,
    logLevel: LogLevel = LogLevel.Warn,
) : TokenRepository {

    private val log = YaloLog(LOG_NAME, logLevel)
    private val mutex = Mutex()
    private val entry: Preferences.Key<String> = key(config.sessionId)
    private val ephemeral: Boolean = config.sessionMode == SessionMode.Ephemeral

    // Guarded by [mutex].
    private var held: AuthToken? = null
    private var running: Deferred<Result<String>>? = null
    private var generation: Int = 0

    override suspend fun token(): Result<String> {
        // Whoever arrives mid exchange waits on that one rather than starting a second.
        val exchange = mutex.withLock {
            held?.takeIf { it.usableAt(now()) }?.let { return Result.success(it.accessToken) }
            running ?: scope.async { obtain(generation) }.also { running = it }
        }
        return exchange.await()
    }

    override suspend fun invalidateToken() {
        log.info { "the backend refused the token, getting another one" }
        mutex.withLock {
            // Expired rather than forgotten, so the refresh token survives: to the
            // backend a new anonymous authentication is a different person, and the
            // conversation would start empty.
            held = held?.copy(expiresAtMillis = 0)
            running = null
        }
    }

    // What the device holds, then a refresh, then a new authentication. Storage is
    // read rather than memory trusted, since another chat on this session may have
    // authenticated since.
    private suspend fun obtain(generation: Int): Result<String> {
        val known = mutex.withLock { held ?: read() }
        if (known != null && known.usableAt(now())) {
            log.debug { "the token on the device is still good" }
            return keep(generation, known, alreadyStored = true)
        }

        val refreshToken = known?.refreshToken?.takeIf { it.isNotBlank() }
        if (refreshToken != null) {
            log.info { "refreshing the token" }
            auth.refreshToken(refreshToken).fold(
                onSuccess = { credentials ->
                    log.info { "refreshed the token" }
                    return keep(generation, credentials.issuedAt(now(), ephemeral, refreshToken))
                },
                onFailure = { cause ->
                    log.warn(cause) { "refresh failed, authenticating instead" }
                },
            )
        }

        if (known != null) {
            // Guarded: an edit writes the file even when it removes nothing.
            mutex.withLock { clearStoredToken() }
        }

        log.info { "authenticating" }
        return auth.fetchToken().fold(
            onSuccess = { credentials ->
                log.info { "authenticated" }
                keep(generation, credentials.issuedAt(now(), ephemeral))
            },
            onFailure = { cause ->
                log.warn(cause) { "authentication failed" }
                mutex.withLock { running = null }
                Result.failure(cause)
            },
        )
    }

    // A clear mid exchange moves [generation] on, and what comes back is then
    // somebody else's token: neither held nor written.
    private suspend fun keep(
        generation: Int,
        token: AuthToken,
        alreadyStored: Boolean = false,
    ): Result<String> = mutex.withLock {
        running = null
        if (generation != this.generation) {
            log.debug { "the session was cleared while this token was on its way" }
            return Result.failure(AuthSessionClearedException())
        }
        held = token
        if (!alreadyStored) {
            write(token)
        }
        Result.success(token.accessToken)
    }

    override suspend fun storedSessions(): Map<String, AuthToken> = mutex.withLock {
        preferences().asMap()
            .mapNotNull { (key, value) -> session(key.name, value) }
            .toMap()
    }

    override suspend fun clearSessions(sessionIds: Set<String>) {
        if (sessionIds.isEmpty()) {
            return
        }
        log.info { "forgetting ${sessionIds.size} sessions" }
        mutex.withLock {
            // Forgetting regardless would throw away a good token over a sweep that
            // was never about this session.
            if (config.sessionId in sessionIds) {
                forget()
            }
            edit("the stored tokens cannot be forgotten") { preferences ->
                for (sessionId in sessionIds) {
                    preferences.remove(key(sessionId))
                }
            }
        }
    }

    override suspend fun clearAllSessions() {
        log.info { "forgetting every session" }
        mutex.withLock {
            forget()
            edit("the stored tokens cannot be forgotten") { preferences ->
                // By name rather than by listing, so a value that can no longer be
                // decoded is reclaimed too.
                for (stored in preferences.asMap().keys.filter { it.name.startsWith(KEY_PREFIX) }) {
                    preferences.remove(stored)
                }
            }
        }
    }

    // Caller holds [mutex].
    private fun forget() {
        held = null
        running = null
        generation++
    }

    private suspend fun read(): AuthToken? {
        val stored = preferences()[entry] ?: return null
        val token = decodeOrNull(stored)
        if (token == null) {
            log.warn { "the stored token cannot be read, forgetting it" }
            clearStoredToken()
        }
        return token
    }

    private suspend fun write(token: AuthToken) {
        val encrypted = encryptOrNull(encode(token)) ?: return
        edit("the token cannot be stored, keeping it for this run only") { preferences ->
            preferences[entry] = encrypted
        }
        log.debug { "stored the token" }
    }

    private suspend fun clearStoredToken() {
        edit("the stored token cannot be forgotten") { preferences -> preferences.remove(entry) }
    }

    // Reads rather than forgets, unlike [read]: a sweep looks at every session, and
    // turning one unreadable value into a delete would let it reclaim what it cannot
    // even identify.
    private fun session(name: String, value: Any): Pair<String, AuthToken>? {
        if (!name.startsWith(KEY_PREFIX) || value !is String) {
            return null
        }
        val sessionId = name.removePrefix(KEY_PREFIX)
        if (sessionId.isEmpty()) {
            return null
        }
        return decodeOrNull(value)?.let { token -> sessionId to token }
    }

    private fun decodeOrNull(stored: String): AuthToken? = try {
        decode(cipher.decrypt(stored))
    } catch (error: GeneralSecurityException) {
        log.warn(error) { "a stored token cannot be read" }
        null
    } catch (error: JSONException) {
        log.warn(error) { "a stored token cannot be read" }
        null
    } catch (error: IllegalArgumentException) {
        log.warn(error) { "a stored token cannot be read" }
        null
    }

    private fun encryptOrNull(plain: String): String? = try {
        cipher.encrypt(plain)
    } catch (error: GeneralSecurityException) {
        log.warn(error) { "the token cannot be encrypted, keeping it for this run only" }
        null
    } catch (error: IllegalArgumentException) {
        log.warn(error) { "the token cannot be encrypted, keeping it for this run only" }
        null
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

    private suspend fun edit(failure: String, change: (MutablePreferences) -> Unit) {
        try {
            store.edit { preferences -> change(preferences) }
        } catch (error: IOException) {
            log.warn(error) { failure }
        }
    }

    private fun key(sessionId: String): Preferences.Key<String> =
        stringPreferencesKey("$KEY_PREFIX$sessionId")

    private fun encode(token: AuthToken): String = JSONObject()
        .put(FIELD_ACCESS_TOKEN, token.accessToken)
        .put(FIELD_REFRESH_TOKEN, token.refreshToken)
        .put(FIELD_EXPIRES_AT, token.expiresAtMillis)
        .put(FIELD_EPHEMERAL, token.ephemeral)
        .toString()

    private fun decode(json: String): AuthToken {
        val fields = JSONObject(json)
        return AuthToken(
            accessToken = fields.getString(FIELD_ACCESS_TOKEN),
            refreshToken = fields.getString(FIELD_REFRESH_TOKEN),
            expiresAtMillis = fields.getLong(FIELD_EXPIRES_AT),
            // A record written before the flag existed is a session nothing is
            // allowed to reclaim.
            ephemeral = fields.optBoolean(FIELD_EPHEMERAL, false),
        )
    }

    private companion object {

        private const val LOG_NAME = "Token"

        private const val KEY_PREFIX = "token:"
        private const val FIELD_ACCESS_TOKEN = "access"
        private const val FIELD_REFRESH_TOKEN = "refresh"
        private const val FIELD_EXPIRES_AT = "expiresAt"
        private const val FIELD_EPHEMERAL = "ephemeral"
    }
}

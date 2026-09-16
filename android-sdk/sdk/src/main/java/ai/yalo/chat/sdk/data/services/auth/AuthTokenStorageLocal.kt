// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.first
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.security.GeneralSecurityException
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Keeps tokens in a single DataStore file, one entry per session.
 *
 * DataStore rather than shared preferences because writes here are ordered
 * against each other. Forgetting a token and storing a new one arrive as two
 * separate pieces of work, and on plain preferences a slow delete can land
 * after the write and quietly take a good token with it.
 *
 * Values are encrypted with a key that never leaves the device's keystore, so
 * what is on disk is useless on its own. The refresh token is the part worth
 * protecting: an access token is spent within the hour, a refresh token is a
 * way back into the conversation for as long as the backend honours it.
 *
 * Every failure here reports no token rather than raising. A keystore that was
 * cleared, a file written by a version that stored something else, a device
 * that lost the key on a restore from backup: none of those should stop a chat
 * from opening, and all of them are answered by authenticating again.
 */
internal class AuthTokenStorageLocal(
    private val store: DataStore<Preferences>,
    sessionId: String,
    private val cipher: TokenCipher = KeystoreTokenCipher(),
) : AuthTokenStorage {

    private val entry: Preferences.Key<String> = stringPreferencesKey("$KEY_PREFIX$sessionId")

    override suspend fun read(): AuthToken? {
        val stored = store.data
            .catch { error ->
                if (error is IOException) {
                    emit(emptyPreferences())
                } else {
                    throw error
                }
            }
            .first()[entry] ?: return null

        return try {
            decode(cipher.decrypt(stored))
        } catch (error: GeneralSecurityException) {
            // The key is gone or the value was not written by it. Either way
            // there is nothing to recover, so the entry goes and the SDK
            // authenticates from scratch.
            clear()
            null
        } catch (error: JSONException) {
            clear()
            null
        } catch (error: IllegalArgumentException) {
            clear()
            null
        }
    }

    override suspend fun write(token: AuthToken) {
        val encrypted = try {
            cipher.encrypt(encode(token))
        } catch (error: GeneralSecurityException) {
            // Storing is an optimisation. A chat that cannot encrypt still
            // works, it just authenticates again next time it opens.
            return
        }
        try {
            store.edit { preferences -> preferences[entry] = encrypted }
        } catch (error: IOException) {
            return
        }
    }

    override suspend fun clear() {
        try {
            store.edit { preferences -> preferences.remove(entry) }
        } catch (error: IOException) {
            return
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

        /**
         * Storage for one session, on the file every session shares.
         *
         * DataStore allows one instance per file per process, so the store
         * comes from a delegate that hands the same one to every chat.
         */
        fun of(
            context: Context,
            sessionId: String,
            cipher: TokenCipher = KeystoreTokenCipher(),
        ): AuthTokenStorageLocal = AuthTokenStorageLocal(
            store = context.applicationContext.authTokenStore,
            sessionId = sessionId,
            cipher = cipher,
        )

        private const val KEY_PREFIX = "token:"
        private const val FIELD_ACCESS_TOKEN = "access"
        private const val FIELD_REFRESH_TOKEN = "refresh"
        private const val FIELD_EXPIRES_AT = "expiresAt"
    }
}

// One store for the whole app, the way one database holds every conversation's
// messages. DataStore allows a single instance per file per process, so the
// delegate is what keeps several open chats from fighting over it.
private val Context.authTokenStore: DataStore<Preferences> by preferencesDataStore(
    name = "yalo_chat_auth",
)

/** Turns a token into something safe to leave on disk, and back again. */
internal interface TokenCipher {

    /** Returns [plain] in a form that is useless without the device's key. */
    fun encrypt(plain: String): String

    /** Returns what [encrypt] was given, or raises if it cannot be recovered. */
    fun decrypt(encrypted: String): String
}

/**
 * Encrypts with AES-GCM under a key held by the platform keystore.
 *
 * The key is generated once and never leaves the keystore, which on most
 * devices means it never leaves secure hardware. Only this app can ask for it,
 * so a copy of the file on its own gives nothing away.
 *
 * GCM picks a fresh initialisation vector for every value, and it has to be
 * kept to read the value back, so it is written in front of the ciphertext
 * rather than stored apart from it.
 */
internal class KeystoreTokenCipher(private val alias: String = DEFAULT_ALIAS) : TokenCipher {

    override fun encrypt(plain: String): String {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, key())
        val encrypted = cipher.doFinal(plain.toByteArray(Charsets.UTF_8))
        return Base64.encodeToString(cipher.iv + encrypted, Base64.NO_WRAP)
    }

    override fun decrypt(encrypted: String): String {
        val payload = Base64.decode(encrypted, Base64.NO_WRAP)
        if (payload.size <= IV_BYTES) {
            throw GeneralSecurityException("Stored token is too short to hold a value")
        }
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(
            Cipher.DECRYPT_MODE,
            key(),
            GCMParameterSpec(TAG_BITS, payload, 0, IV_BYTES),
        )
        val plain = cipher.doFinal(payload, IV_BYTES, payload.size - IV_BYTES)
        return String(plain, Charsets.UTF_8)
    }

    private fun key(): SecretKey {
        val keystore = KeyStore.getInstance(KEYSTORE).apply { load(null) }
        val existing = keystore.getEntry(alias, null) as? KeyStore.SecretKeyEntry
        if (existing != null) {
            return existing.secretKey
        }
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE)
        generator.init(
            KeyGenParameterSpec.Builder(
                alias,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(KEY_BITS)
                .build(),
        )
        return generator.generateKey()
    }

    private companion object {
        const val DEFAULT_ALIAS = "ai.yalo.chat.sdk.auth"
        const val KEYSTORE = "AndroidKeyStore"
        const val TRANSFORMATION = "AES/GCM/NoPadding"
        const val IV_BYTES = 12
        const val TAG_BITS = 128
        const val KEY_BITS = 256
    }
}

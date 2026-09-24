// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.token

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.GeneralSecurityException
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** Turns a token into something safe to leave on disk, and back again. */
internal interface TokenCipher {

    /** Returns [plain] in a form that is useless without the device's key. */
    fun encrypt(plain: String): String

    /** Returns what [encrypt] was given, or raises if it cannot be recovered. */
    fun decrypt(encrypted: String): String
}

/**
 * Encrypts with AES-GCM under a key held by the platform keystore, which on
 * most devices means it never leaves secure hardware.
 *
 * GCM picks a fresh initialisation vector per value and it is needed to read
 * the value back, so it is written in front of the ciphertext.
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

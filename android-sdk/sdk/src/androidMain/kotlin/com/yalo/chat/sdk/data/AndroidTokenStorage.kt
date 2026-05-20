// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys
import com.yalo.chat.sdk.data.remote.TokenStorage

// Stores auth tokens using Keystore-backed EncryptedSharedPreferences on API 23+ so tokens
// are encrypted at rest and excluded from plaintext backups. Falls back to MODE_PRIVATE
// SharedPreferences on API 21-22 (< 0.1% of the market, no Keystore symmetric-key support).
// Scoped to channelId+userId so re-init with a different user never loads a stale JWT.
internal class AndroidTokenStorage(
    context: Context,
    channelId: String,
    userId: String? = null,
) : TokenStorage {

    private val prefName = "yalo_chat_sdk_tokens_${channelId}${userId?.let { "_$it" } ?: ""}"

    private val prefs: SharedPreferences = buildPrefs(context.applicationContext, prefName)

    override fun load(): TokenStorage.Entry? {
        val accessToken = prefs.getString(KEY_ACCESS_TOKEN, null) ?: return null
        val refreshToken = prefs.getString(KEY_REFRESH_TOKEN, null) ?: return null
        val expiresAt = prefs.getLong(KEY_EXPIRES_AT, 0L)
        return TokenStorage.Entry(accessToken, refreshToken, expiresAt)
    }

    override fun save(entry: TokenStorage.Entry) {
        prefs.edit()
            .putString(KEY_ACCESS_TOKEN, entry.accessToken)
            .putString(KEY_REFRESH_TOKEN, entry.refreshToken)
            .putLong(KEY_EXPIRES_AT, entry.expiresAt)
            .apply()
    }

    override fun clear() {
        prefs.edit().clear().apply()
    }

    private companion object {
        const val KEY_ACCESS_TOKEN = "access_token"
        const val KEY_REFRESH_TOKEN = "refresh_token"
        const val KEY_EXPIRES_AT = "expires_at"

        fun buildPrefs(context: Context, prefName: String): SharedPreferences {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                try {
                    val masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)
                    return EncryptedSharedPreferences.create(
                        prefName,
                        masterKeyAlias,
                        context,
                        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
                    )
                } catch (_: Exception) {
                    // Keystore unavailable (e.g. first boot before unlock) — fall through.
                }
            }
            return context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        }
    }
}

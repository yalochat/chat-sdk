// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data

import android.content.Context
import android.content.SharedPreferences
import com.yalo.chat.sdk.data.remote.TokenStorage

// Stores auth tokens in app-private SharedPreferences (MODE_PRIVATE — inaccessible to
// other apps without root). Scoped to channelId+userId so re-init with a different channel
// or user never loads a token issued for a previous session.
internal class AndroidTokenStorage(
    context: Context,
    channelId: String,
    userId: String? = null,
) : TokenStorage {

    private val prefs: SharedPreferences = context.applicationContext.getSharedPreferences(
        "yalo_chat_sdk_tokens_${channelId}${userId?.let { "_$it" } ?: ""}",
        Context.MODE_PRIVATE,
    )

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
    }
}

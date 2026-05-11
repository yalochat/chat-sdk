// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.remote

internal interface TokenStorage {
    data class Entry(val accessToken: String, val refreshToken: String, val expiresAt: Long)
    fun load(): Entry?
    fun save(entry: Entry)
    fun clear()
}

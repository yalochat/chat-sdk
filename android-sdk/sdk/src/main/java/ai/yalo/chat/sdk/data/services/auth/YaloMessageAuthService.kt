// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

/** Hands out an access token for one conversation, and keeps one worth handing out. */
internal interface YaloMessageAuthService {

    /** Several callers suspending at once are answered by a single exchange with the backend. */
    suspend fun token(): Result<String>

    /** The next [token] will not be the one that was refused. */
    suspend fun invalidateToken()

    suspend fun clearSession()
}

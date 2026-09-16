// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

/**
 * Hands out an access token for one conversation, and keeps one worth handing
 * out.
 *
 * Callers do not say how to get it. Whether the token came from storage, from
 * a refresh, or from authenticating from scratch is not something the sender of
 * a message should have to think about, and asking twice in the same moment
 * costs one round trip rather than two.
 */
internal interface AuthService {

    /**
     * A token to put on the next request.
     *
     * Suspends while one is being obtained. Several callers suspending at once
     * are answered by a single exchange with the backend.
     */
    suspend fun token(): Result<String>

    /**
     * Reports that the backend turned away a request carrying the last token.
     *
     * The next [token] will not be the one that was refused.
     */
    suspend fun invalidateToken()

    /** Ends the session and forgets everything kept for it. */
    suspend fun clearSession()
}

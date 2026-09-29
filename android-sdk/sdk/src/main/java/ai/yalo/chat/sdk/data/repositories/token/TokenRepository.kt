// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.token

/**
 * The access token everything else in the conversation sends, and the only
 * place that decides when a new one is needed.
 *
 * Whoever asks never has to know whether the answer came from the device, from
 * a refresh or from authenticating, and never has to look at the clock.
 *
 * A stored token also says whether its session is meant to leave nothing
 * behind, which is what a sweep goes looking for.
 */
internal interface TokenRepository {

    /** Several callers asking at once are answered by a single exchange with the backend. */
    suspend fun token(): Result<String>

    /** Says the backend refused the last token, so the next [token] is a different one. */
    suspend fun invalidateToken()

    /** Forgets the conversation, on the device as well as in memory. */
    suspend fun clearSession()

    /**
     * Forgets the tokens of [sessionIds], which do not have to include the one
     * this repository is bound to. Sessions with nothing stored are no error,
     * so a caller can pass ids another path may already have taken.
     */
    suspend fun deleteSessions(sessionIds: List<String>): Result<Unit>

    /**
     * The sessions whose stored token says they are to leave nothing behind.
     *
     * Read without decrypting anything, so a session is still found after the
     * key behind the tokens has gone. One that could not be read would be one
     * that sat on the device for good.
     */
    suspend fun ephemeralSessions(): Set<String>
}

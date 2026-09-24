// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.token

/**
 * Hands out an access token for one conversation, keeps one worth handing out,
 * and says what other sessions have left on the device.
 */
internal interface TokenRepository {

    /** Several callers suspending at once are answered by a single exchange with the backend. */
    suspend fun token(): Result<String>

    /** The next [token] will not be the one that was refused. */
    suspend fun invalidateToken()

    /**
     * The token of every session on this device, keyed by session id, this session
     * included. [AuthToken.ephemeral] says which were meant to leave nothing behind.
     */
    suspend fun storedSessions(): Map<String, AuthToken>

    /**
     * Forgets the tokens of [sessionIds], this session included when named.
     *
     * Which ids are worth forgetting is the caller's to decide, since only it knows
     * which chats are open. Safest at startup, before any is: nothing in the process
     * is live yet, so every ephemeral session on disk was left by one already gone.
     */
    suspend fun clearSessions(sessionIds: Set<String>)

    /** Forgets every stored token, this session's included. */
    suspend fun clearAllSessions()
}

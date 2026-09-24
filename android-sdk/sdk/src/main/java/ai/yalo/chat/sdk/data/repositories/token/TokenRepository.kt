// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.token

/**
 * The access token everything else in the conversation sends, and the only
 * place that decides when a new one is needed.
 *
 * Whoever asks never has to know whether the answer came from the device, from
 * a refresh or from authenticating, and never has to look at the clock.
 */
internal interface TokenRepository {

    /** Several callers asking at once are answered by a single exchange with the backend. */
    suspend fun token(): Result<String>

    /** Says the backend refused the last token, so the next [token] is a different one. */
    suspend fun invalidateToken()

    /** Forgets the conversation, on the device as well as in memory. */
    suspend fun clearSession()
}

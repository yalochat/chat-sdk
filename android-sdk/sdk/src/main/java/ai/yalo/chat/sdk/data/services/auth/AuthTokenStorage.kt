// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

/**
 * Where one conversation's token survives the app being closed.
 *
 * Reading back a token is what lets a chat reopen without authenticating
 * again, which for an anonymous user is the difference between the same
 * conversation and a new one.
 *
 * A token that cannot be read back is reported as no token at all. Nothing
 * here throws: losing a stored token costs one round trip, and that is a far
 * better outcome than a chat that will not open.
 */
internal interface AuthTokenStorage {

    /** The token kept for this session, or null if there is none to be had. */
    suspend fun read(): AuthToken?

    /** Keeps [token] for this session, replacing whatever was there. */
    suspend fun write(token: AuthToken)

    /** Forgets this session's token. */
    suspend fun clear()
}

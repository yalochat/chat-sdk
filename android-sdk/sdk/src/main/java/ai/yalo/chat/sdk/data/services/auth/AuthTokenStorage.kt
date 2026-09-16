// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

/**
 * Where one conversation's token survives the app being closed.
 *
 * Nothing here throws. A token that cannot be read back is reported as no
 * token, which costs a round trip rather than a chat that will not open.
 */
internal interface AuthTokenStorage {

    suspend fun read(): AuthToken?

    suspend fun write(token: AuthToken)

    suspend fun clear()
}

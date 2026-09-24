// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

/**
 * The two calls the backend offers for getting into a conversation.
 *
 * Nothing here remembers anything. Deciding when a token is worth asking for,
 * and what to do with one afterwards, belongs to whoever calls this.
 */
internal interface YaloMessageAuthService {

    suspend fun fetchToken(): Result<AuthCredentials>

    suspend fun refreshToken(refreshToken: String): Result<AuthCredentials>
}

/** The lifetime arrives as a length, so it only means something next to a clock. */
internal data class AuthCredentials(
    val accessToken: String,
    val refreshToken: String,
    val expiresInSeconds: Long,
)

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.auth

import ai.yalo.chat.sdk.domain.models.AuthToken

/**
 * The two calls the backend offers for getting into a conversation.
 *
 * Nothing here remembers anything. Deciding which call to make, and what to do
 * with what comes back, belongs to whoever keeps the token.
 */
internal interface YaloMessageAuthDataSource {

    /** Asks for a token for the configured channel and user. */
    suspend fun authenticate(): Result<AuthToken>

    /** Trades [refreshToken] for a token, without becoming a new person. */
    suspend fun refresh(refreshToken: String): Result<AuthToken>
}

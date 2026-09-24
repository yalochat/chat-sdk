// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.token

import ai.yalo.chat.sdk.data.services.auth.AuthCredentials

/** @property ephemeral Whether the session this was issued for leaves nothing behind. */
internal data class AuthToken(
    val accessToken: String,
    val refreshToken: String,
    val expiresAtMillis: Long,
    val ephemeral: Boolean = false,
)

internal class AuthSessionClearedException :
    IllegalStateException("The session was cleared before a token arrived")

// A refresh that hands back no new refresh token leaves the old one in place.
internal fun AuthCredentials.issuedAt(
    nowMillis: Long,
    ephemeral: Boolean,
    fallbackRefreshToken: String = "",
): AuthToken = AuthToken(
    accessToken = accessToken,
    refreshToken = refreshToken.ifBlank { fallbackRefreshToken },
    expiresAtMillis = nowMillis + expiresInSeconds * MILLIS_PER_SECOND,
    ephemeral = ephemeral,
)

internal fun AuthToken.usableAt(nowMillis: Long): Boolean = nowMillis < expiresAtMillis

private const val MILLIS_PER_SECOND = 1_000L

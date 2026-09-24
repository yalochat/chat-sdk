// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.domain.models

/**
 * What lets the chat speak to the channel as somebody.
 *
 * The backend says how long the token lasts, and the moment it stops being
 * worth sending is kept instead. A length only means something next to the
 * clock it was measured from, and this outlives the app being closed.
 */
internal data class AuthToken(
    val accessToken: String,
    /** Buys another [accessToken] without becoming a new person. Blank when there is none. */
    val refreshToken: String,
    val expiresAtMillis: Long,
) {

    fun usableAt(nowMillis: Long): Boolean = nowMillis < expiresAtMillis
}

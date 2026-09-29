// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.token

/**
 * Stands in for the token repository so a test can say what the backend makes
 * of a token without any of the getting of one.
 *
 * Set [failure] to make every ask come back failed, and read [invalidations]
 * and [deletedSessions] to see what was asked of it.
 */
internal class FakeTokenRepository : TokenRepository {

    var current: String = "access"
    var failure: Throwable? = null
    var invalidations: Int = 0
    val deletedSessions: MutableList<String> = mutableListOf()
    val ephemeralSessions: MutableSet<String> = mutableSetOf()

    override suspend fun token(): Result<String> =
        failure?.let { cause -> Result.failure(cause) } ?: Result.success(current)

    override suspend fun invalidateToken() {
        invalidations++
        current = "refreshed"
    }

    override suspend fun clearSession(): Unit = Unit

    override suspend fun deleteSessions(sessionIds: List<String>): Result<Unit> {
        failure?.let { cause -> return Result.failure(cause) }
        deletedSessions.addAll(sessionIds)
        ephemeralSessions.removeAll(sessionIds.toSet())
        return Result.success(Unit)
    }

    override suspend fun ephemeralSessions(): Set<String> = ephemeralSessions.toSet()
}

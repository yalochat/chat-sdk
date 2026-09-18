// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.log.YaloLog
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import okhttp3.FormBody
import okhttp3.HttpUrl
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.util.concurrent.atomic.AtomicLong

/**
 * Carries out what an [AuthConnection] decides, against the backend and the
 * device.
 *
 * Storage runs under [mutex] so forgetting a token and writing the next one
 * cannot land out of order. The network calls are launched instead, because
 * holding the lock across a round trip would make every other caller queue
 * behind it.
 */
internal class YaloMessageAuthServiceRemote(
    private val config: YaloChatClientConfig,
    private val storage: AuthTokenStorage,
    private val scope: CoroutineScope,
    baseUrl: HttpUrl,
    private val client: OkHttpClient = OkHttpClient(),
    private val now: () -> Long = System::currentTimeMillis,
    logLevel: LogLevel = LogLevel.Warn,
) : YaloMessageAuthService {

    private val log = YaloLog(LOG_NAME, logLevel)
    private val connection = AuthConnection()
    private val mutex = Mutex()
    private val waiting = mutableMapOf<Long, CompletableDeferred<String>>()
    private val nextRequestId = AtomicLong()
    private val channels: HttpUrl = baseUrl.newBuilder().addPathSegments(CHANNELS_PATH).build()

    override suspend fun token(): Result<String> {
        val requestId = nextRequestId.incrementAndGet()
        val answer = CompletableDeferred<String>()
        mutex.withLock {
            waiting[requestId] = answer
            dispatch(AuthConnection.Event.TokenRequested(requestId, now()))
        }
        return try {
            Result.success(answer.await())
        } catch (error: CancellationException) {
            throw error
        } catch (error: Throwable) {
            Result.failure(error)
        } finally {
            withContext(NonCancellable) {
                mutex.withLock { waiting.remove(requestId) }
            }
        }
    }

    override suspend fun invalidateToken() {
        log.info { "the backend refused the token, authenticating again" }
        send(AuthConnection.Event.TokenRejected)
    }

    override suspend fun clearSession() {
        log.info { "forgetting the session" }
        send(AuthConnection.Event.SessionCleared)
    }

    private suspend fun send(event: AuthConnection.Event) {
        mutex.withLock { dispatch(event) }
    }

    // Reading storage answers straight away, so its event is applied here
    // rather than posted back.
    private suspend fun dispatch(event: AuthConnection.Event) {
        var next: AuthConnection.Event? = event
        while (next != null) {
            next = apply(next)
        }
    }

    private suspend fun apply(event: AuthConnection.Event): AuthConnection.Event? {
        var follow: AuthConnection.Event? = null
        for (command in connection.handle(event)) {
            when (command) {
                AuthConnection.Command.LoadStoredToken -> {
                    val stored = storage.read()
                    if (stored == null) {
                        log.debug { "no token on the device" }
                    } else {
                        log.debug { "read a stored token" }
                    }
                    follow = AuthConnection.Event.StoredTokenLoaded(stored, now())
                }
                AuthConnection.Command.FetchToken -> {
                    log.info { "authenticating" }
                    scope.launch {
                        fetchToken().fold(
                            onSuccess = {
                                log.info { "authenticated" }
                                send(AuthConnection.Event.AuthSucceeded(it, now()))
                            },
                            onFailure = { cause ->
                                log.warn(cause) { "authentication failed" }
                                send(AuthConnection.Event.AuthFailed(cause))
                            },
                        )
                    }
                }
                is AuthConnection.Command.RefreshToken -> {
                    log.info { "refreshing the token" }
                    scope.launch {
                        refreshToken(command.refreshToken).fold(
                            onSuccess = {
                                log.info { "refreshed the token" }
                                send(AuthConnection.Event.RefreshSucceeded(it, now()))
                            },
                            onFailure = { cause ->
                                log.warn(cause) { "refresh failed, authenticating instead" }
                                send(AuthConnection.Event.RefreshFailed(cause))
                            },
                        )
                    }
                }
                is AuthConnection.Command.StoreToken -> {
                    storage.write(command.token)
                }
                AuthConnection.Command.ClearStoredToken -> {
                    log.debug { "clearing the stored token" }
                    storage.clear()
                }
                is AuthConnection.Command.DeliverToken -> {
                    log.debug { "handing a token to ${command.requestIds.size} waiting for one" }
                    for (requestId in command.requestIds) {
                        waiting.remove(requestId)?.complete(command.accessToken)
                    }
                }
                is AuthConnection.Command.FailRequests -> {
                    log.warn(command.cause) { "failing ${command.requestIds.size} waiting for a token" }
                    for (requestId in command.requestIds) {
                        waiting.remove(requestId)?.completeExceptionally(command.cause)
                    }
                }
            }
        }
        return follow
    }

    private suspend fun fetchToken(): Result<AuthCredentials> {
        val body = JSONObject()
            .put(FIELD_USER_TYPE, if (config.userId == null) USER_ANONYMOUS else USER_THIRD_PARTY)
            .put(FIELD_CHANNEL_ID, config.channelId)
            .put(FIELD_ORGANIZATION_ID, config.organizationId)
            .put(FIELD_TIMESTAMP, now() / MILLIS_PER_SECOND)
        config.userId?.let { userId -> body.put(FIELD_USER_ID, userId) }

        return call(
            Request.Builder()
                .url(channels.newBuilder().addPathSegment(AUTH_PATH).build())
                .post(body.toString().toRequestBody(JSON_MEDIA_TYPE))
                .build(),
            failure = "Auth failed",
        )
    }

    private suspend fun refreshToken(refreshToken: String): Result<AuthCredentials> = call(
        Request.Builder()
            .url(channels.newBuilder().addPathSegments(OAUTH_TOKEN_PATH).build())
            .post(
                FormBody.Builder()
                    .add(FIELD_GRANT_TYPE, GRANT_REFRESH_TOKEN)
                    .add(FIELD_REFRESH_TOKEN, refreshToken)
                    .build(),
            )
            .build(),
        failure = "Refresh failed",
    )

    private suspend fun call(request: Request, failure: String): Result<AuthCredentials> =
        withContext(Dispatchers.IO) {
            try {
                client.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) {
                        return@use Result.failure(IOException("$failure: ${response.code}"))
                    }
                    Result.success(credentials(response.body.string()))
                }
            } catch (error: IOException) {
                Result.failure(error)
            } catch (error: JSONException) {
                Result.failure(error)
            }
        }

    // The refresh endpoint follows OAuth and sends snake case; the auth
    // endpoint serialises a protobuf message and sends camel case.
    private fun credentials(json: String): AuthCredentials {
        val fields = JSONObject(json)
        return AuthCredentials(
            accessToken = fields.text(FIELD_ACCESS_TOKEN, "accessToken"),
            refreshToken = fields.text(FIELD_REFRESH_TOKEN, "refreshToken"),
            expiresInSeconds = fields.optLong(FIELD_EXPIRES_IN, fields.optLong("expiresIn")),
        )
    }

    private fun JSONObject.text(snakeCase: String, camelCase: String): String =
        optString(snakeCase).ifEmpty { optString(camelCase) }

    private companion object {

        private const val LOG_NAME = "Auth"

        private const val CHANNELS_PATH = "v1/channels"
        private const val AUTH_PATH = "auth"
        private const val OAUTH_TOKEN_PATH = "oauth/token"

        private const val USER_ANONYMOUS = "anonymous"
        private const val USER_THIRD_PARTY = "third_party_anonymous"
        private const val GRANT_REFRESH_TOKEN = "refresh_token"

        private const val FIELD_USER_TYPE = "user_type"
        private const val FIELD_USER_ID = "user_id"
        private const val FIELD_CHANNEL_ID = "channel_id"
        private const val FIELD_ORGANIZATION_ID = "organization_id"
        private const val FIELD_TIMESTAMP = "timestamp"
        private const val FIELD_GRANT_TYPE = "grant_type"
        private const val FIELD_ACCESS_TOKEN = "access_token"
        private const val FIELD_REFRESH_TOKEN = "refresh_token"
        private const val FIELD_EXPIRES_IN = "expires_in"

        private const val MILLIS_PER_SECOND = 1_000L
        private val JSON_MEDIA_TYPE = "application/json".toMediaType()
    }
}

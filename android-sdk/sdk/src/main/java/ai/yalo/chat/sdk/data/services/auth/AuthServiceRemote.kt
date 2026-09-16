// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

import ai.yalo.chat.sdk.YaloChatClientConfig
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
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
 * Drives an [AuthConnection] against the backend and the device.
 *
 * Every decision about what to do next belongs to the state machine. This is
 * the half that cannot be pure: it calls the two endpoints, reads and writes
 * [storage], reads the clock, and hands answers back to whoever is waiting.
 * What is here is a translation of each [AuthConnection.Command] into the work
 * it names, which is why almost nothing about the token lifecycle is decided in
 * this file.
 *
 * Events are applied one at a time under [mutex]. Storage runs while the lock
 * is held, so forgetting a token and writing the next one cannot land out of
 * order. The two network calls are launched instead, because holding the lock
 * across a round trip would make every other caller queue behind it and undo
 * the point of collecting them in the first place.
 */
internal class AuthServiceRemote(
    private val config: YaloChatClientConfig,
    private val storage: AuthTokenStorage,
    private val scope: CoroutineScope,
    baseUrl: HttpUrl,
    private val client: OkHttpClient = OkHttpClient(),
    private val now: () -> Long = System::currentTimeMillis,
) : AuthService {

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
        return runCatching { answer.await() }
    }

    override suspend fun invalidateToken() {
        send(AuthConnection.Event.TokenRejected)
    }

    override suspend fun clearSession() {
        send(AuthConnection.Event.SessionCleared)
    }

    private suspend fun send(event: AuthConnection.Event) {
        mutex.withLock { dispatch(event) }
    }

    // Reading storage answers straight away, so its event is applied here
    // rather than posted back. Looping instead of recursing keeps the lock
    // held once for the whole chain.
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
                    follow = AuthConnection.Event.StoredTokenLoaded(storage.read(), now())
                }
                AuthConnection.Command.FetchToken -> {
                    scope.launch {
                        fetchToken().fold(
                            onSuccess = { send(AuthConnection.Event.AuthSucceeded(it, now())) },
                            onFailure = { send(AuthConnection.Event.AuthFailed(it)) },
                        )
                    }
                }
                is AuthConnection.Command.RefreshToken -> {
                    scope.launch {
                        refreshToken(command.refreshToken).fold(
                            onSuccess = { send(AuthConnection.Event.RefreshSucceeded(it, now())) },
                            onFailure = { send(AuthConnection.Event.RefreshFailed(it)) },
                        )
                    }
                }
                is AuthConnection.Command.StoreToken -> {
                    storage.write(command.token)
                }
                AuthConnection.Command.ClearStoredToken -> {
                    storage.clear()
                }
                is AuthConnection.Command.DeliverToken -> {
                    for (requestId in command.requestIds) {
                        waiting.remove(requestId)?.complete(command.accessToken)
                    }
                }
                is AuthConnection.Command.FailRequests -> {
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

    // Both endpoints answer with the same shape under two spellings. The
    // refresh endpoint follows OAuth and sends snake case, while the auth
    // endpoint serialises a protobuf message and sends camel case, so each
    // field is looked for both ways.
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

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

import ai.yalo.chat.sdk.YaloChatClientConfig
import kotlinx.coroutines.Dispatchers
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

/** Talks to the backend and nothing else: no clock of its own, nothing remembered. */
internal class YaloMessageAuthServiceRemote(
    private val config: YaloChatClientConfig,
    baseUrl: HttpUrl,
    private val client: OkHttpClient = OkHttpClient(),
    private val now: () -> Long = System::currentTimeMillis,
) : YaloMessageAuthService {

    private val channels: HttpUrl = baseUrl.newBuilder().addPathSegments(CHANNELS_PATH).build()

    override suspend fun fetchToken(): Result<AuthCredentials> {
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

    override suspend fun refreshToken(refreshToken: String): Result<AuthCredentials> = call(
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

    // The refresh endpoint follows OAuth and sends snake case; the auth endpoint
    // serialises a protobuf message and sends camel case.
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

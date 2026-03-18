// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.services.auth

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.services.auth.model.YaloAuthRequest
import com.yalo.chat.sdk.data.services.auth.model.YaloAuthResponse
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.forms.submitForm
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.Parameters
import io.ktor.http.contentType
import io.ktor.http.isSuccess
import kotlinx.datetime.Clock

// Port of flutter-sdk YaloMessageAuthServiceRemote (data/services/yalo_message_auth).
// Uses Ktor instead of Dart's http package — same endpoints, same token-cache logic.
//
// Token-cache strategy (mirrors Flutter exactly):
//   1. Valid cache   → return cached access token immediately (no network).
//   2. Expired cache → POST /oauth/token with the refresh token.
//   3. No cache      → POST /auth with anonymous credentials.
//
// The HttpClient is injected so tests can pass a MockEngine client without any
// platform-specific engine (identical pattern to YaloChatApiService).
internal class YaloMessageAuthServiceRemote(
    private val baseUrl: String,
    private val channelId: String,
    private val organizationId: String,
    internal val httpClient: HttpClient,
) : YaloMessageAuthService {

    private data class TokenCache(
        val accessToken: String,
        val refreshToken: String,
        val expiresAtEpochSeconds: Long,
    )

    private var cache: TokenCache? = null

    override suspend fun auth(): Result<String> {
        val cached = cache
        val nowSeconds = Clock.System.now().epochSeconds

        if (cached != null && nowSeconds < cached.expiresAtEpochSeconds) {
            return Result.Ok(cached.accessToken)
        }

        return if (cached?.refreshToken != null) {
            refresh(cached.refreshToken)
        } else {
            fetchToken()
        }
    }

    // POST /auth — anonymous token acquisition.
    private suspend fun fetchToken(): Result<String> = try {
        val response = httpClient.post("$baseUrl/auth") {
            contentType(ContentType.Application.Json)
            setBody(
                YaloAuthRequest(
                    userType = "anonymous",
                    channelId = channelId,
                    organizationId = organizationId,
                    timestamp = Clock.System.now().epochSeconds,
                )
            )
        }
        if (response.status.isSuccess()) {
            val body: YaloAuthResponse = response.body()
            storeCache(body)
            Result.Ok(body.accessToken)
        } else {
            Result.Error(RuntimeException("Auth failed: ${response.status.value}"))
        }
    } catch (e: Exception) {
        Result.Error(e)
    }

    // POST /oauth/token — token refresh using the stored refresh token.
    // On failure the cache is cleared so the next auth() call goes back to /auth.
    private suspend fun refresh(refreshToken: String): Result<String> = try {
        val response = httpClient.submitForm(
            url = "$baseUrl/oauth/token",
            formParameters = Parameters.build {
                append("grant_type", "refresh_token")
                append("refresh_token", refreshToken)
            }
        )
        if (response.status.isSuccess()) {
            val body: YaloAuthResponse = response.body()
            storeCache(body)
            Result.Ok(body.accessToken)
        } else {
            cache = null
            Result.Error(RuntimeException("Refresh failed: ${response.status.value}"))
        }
    } catch (e: Exception) {
        Result.Error(e)
    }

    private fun storeCache(response: YaloAuthResponse) {
        cache = TokenCache(
            accessToken = response.accessToken,
            refreshToken = response.refreshToken,
            expiresAtEpochSeconds = Clock.System.now().epochSeconds + response.expiresIn,
        )
    }
}

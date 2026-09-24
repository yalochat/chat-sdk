// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.auth

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.domain.models.AuthToken
import kotlinx.coroutines.runBlocking
import mockwebserver3.MockResponse
import mockwebserver3.MockWebServer
import mockwebserver3.RecordedRequest
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrl
import org.json.JSONObject
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class YaloMessageAuthRemoteDataSourceTest {

    private lateinit var server: MockWebServer

    @Before
    fun startServer() {
        server = MockWebServer()
        server.start()
    }

    @After
    fun stopServer() {
        server.close()
    }

    @Test
    fun authenticatesAnonymouslyWhenNoUserIsConfigured() = runBlocking {
        server.enqueue(tokenResponse())

        service().authenticate()

        val body = JSONObject(server.takeRequest().text())
        assertEquals("anonymous", body.getString("user_type"))
        assertEquals(false, body.has("user_id"))
    }

    @Test
    fun identifiesTheUserWhenOneIsConfigured() = runBlocking {
        server.enqueue(tokenResponse())

        service(config(userId = "user-1")).authenticate()

        val body = JSONObject(server.takeRequest().text())
        assertEquals("third_party_anonymous", body.getString("user_type"))
        assertEquals("user-1", body.getString("user_id"))
    }

    @Test
    fun sendsTheChannelItIsAuthenticatingFor() = runBlocking {
        server.enqueue(tokenResponse())

        service().authenticate()

        val request = server.takeRequest()
        val body = JSONObject(request.text())
        assertEquals("/v1/channels/auth", request.url.encodedPath)
        assertEquals(
            listOf("channel-1", "org-1", NOW / 1_000),
            listOf(
                body.getString("channel_id"),
                body.getString("organization_id"),
                body.getLong("timestamp"),
            ),
        )
    }

    @Test
    fun handsBackTheTokenTheBackendIssued() = runBlocking {
        server.enqueue(tokenResponse(accessToken = "issued", refreshToken = "for-later"))

        val result = service().authenticate()

        assertEquals(AuthToken("issued", "for-later", NOW + 3_600_000), result.getOrNull())
    }

    @Test
    fun readsTheFieldsTheAuthEndpointSpellsInCamelCase() = runBlocking {
        server.enqueue(
            response("""{"accessToken":"camel","refreshToken":"r","expiresIn":60}"""),
        )

        assertEquals(AuthToken("camel", "r", NOW + 60_000), service().authenticate().getOrNull())
    }

    @Test
    fun reportsAFailureWhenTheBackendWillNotAuthenticate() = runBlocking {
        server.enqueue(MockResponse.Builder().code(401).build())

        val result = service().authenticate()

        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull()?.message?.contains("401") == true)
    }

    @Test
    fun reportsAFailureWhenTheBackendSendsSomethingThatIsNotAToken() = runBlocking {
        server.enqueue(response("not json at all"))

        assertTrue(service().authenticate().isFailure)
    }

    @Test
    fun reportsAFailureWhenTheBackendCannotBeReached() = runBlocking {
        // A port nothing is listening on, which is the same to the caller as a
        // phone that has just lost its signal.
        val unreachable = service(baseUrl = "http://localhost:1/".toHttpUrl())

        assertTrue(unreachable.authenticate().isFailure)
        assertTrue(unreachable.refresh("refresh").isFailure)
    }

    @Test
    fun tradesARefreshTokenForANewOne() = runBlocking {
        server.enqueue(tokenResponse(accessToken = "refreshed", refreshToken = "the-next-one"))

        val result = service().refresh("the-refresh-token")

        val request = server.takeRequest()
        assertEquals("/v1/channels/oauth/token", request.url.encodedPath)
        assertEquals("grant_type=refresh_token&refresh_token=the-refresh-token", request.text())
        assertEquals(AuthToken("refreshed", "the-next-one", NOW + 3_600_000), result.getOrNull())
    }

    @Test
    fun keepsTheRefreshTokenWhenTheAnswerCarriesNoNewOne() = runBlocking {
        server.enqueue(response("""{"access_token":"refreshed","expires_in":3600}"""))

        val result = service().refresh("the-refresh-token")

        assertEquals("the-refresh-token", result.getOrNull()?.refreshToken)
    }

    @Test
    fun reportsAFailureWhenTheBackendWillNotRefresh() = runBlocking {
        server.enqueue(MockResponse.Builder().code(403).build())

        val result = service().refresh("stale")

        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull()?.message?.contains("403") == true)
    }

    // The recorded body is nullable because a request need not carry one.
    // Every request these tests look at does.
    private fun RecordedRequest.text(): String = requireNotNull(body).utf8()

    private fun service(
        config: YaloChatClientConfig = config(),
        baseUrl: HttpUrl = server.url("/"),
    ): YaloMessageAuthRemoteDataSource = YaloMessageAuthRemoteDataSource(
        config = config,
        baseUrl = baseUrl,
        now = { NOW },
        logLevel = LogLevel.Debug,
    )

    private fun config(userId: String? = null) = YaloChatClientConfig(
        channelId = "channel-1",
        organizationId = "org-1",
        channelName = "Support",
        userId = userId,
    )

    private fun tokenResponse(
        accessToken: String = "access",
        refreshToken: String = "refresh",
        expiresIn: Long = 3_600,
    ): MockResponse = response(
        """{"access_token":"$accessToken","refresh_token":"$refreshToken","expires_in":$expiresIn}""",
    )

    private fun response(body: String): MockResponse = MockResponse.Builder()
        .code(200)
        .body(body)
        .build()

    private companion object {
        const val NOW = 1_700_000_000_000L
    }
}

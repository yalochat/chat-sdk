// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

import ai.yalo.chat.sdk.YaloChatClientConfig
import kotlinx.coroutines.runBlocking
import mockwebserver3.MockResponse
import mockwebserver3.MockWebServer
import mockwebserver3.RecordedRequest
import org.json.JSONObject
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class YaloMessageAuthServiceRemoteTest {

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

        service().fetchToken()

        val body = JSONObject(server.takeRequest().text())
        assertEquals("anonymous", body.getString("user_type"))
        assertEquals(false, body.has("user_id"))
    }

    @Test
    fun identifiesTheUserWhenOneIsConfigured() = runBlocking {
        server.enqueue(tokenResponse())

        service(config(userId = "user-1")).fetchToken()

        val body = JSONObject(server.takeRequest().text())
        assertEquals("third_party_anonymous", body.getString("user_type"))
        assertEquals("user-1", body.getString("user_id"))
    }

    @Test
    fun sendsTheChannelItIsAuthenticatingFor() = runBlocking {
        server.enqueue(tokenResponse())

        service().fetchToken()

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
    fun handsBackTheCredentialsTheBackendIssued() = runBlocking {
        server.enqueue(tokenResponse(accessToken = "issued", refreshToken = "r", expiresIn = 3_600))

        val credentials = service().fetchToken().getOrNull()

        assertEquals(AuthCredentials("issued", "r", 3_600), credentials)
    }

    @Test
    fun readsTheFieldsTheAuthEndpointSpellsInCamelCase() = runBlocking {
        server.enqueue(response("""{"accessToken":"camel","refreshToken":"r","expiresIn":3600}"""))

        assertEquals(AuthCredentials("camel", "r", 3_600), service().fetchToken().getOrNull())
    }

    @Test
    fun tradesARefreshTokenAtTheOauthEndpoint() = runBlocking {
        server.enqueue(tokenResponse(accessToken = "refreshed"))

        val credentials = service().refreshToken("the-refresh-token").getOrNull()

        val request = server.takeRequest()
        assertEquals("refreshed", credentials?.accessToken)
        assertEquals("/v1/channels/oauth/token", request.url.encodedPath)
        assertEquals("grant_type=refresh_token&refresh_token=the-refresh-token", request.text())
    }

    @Test
    fun reportsAFailureWhenTheBackendWillNotAuthenticate() = runBlocking {
        server.enqueue(MockResponse.Builder().code(401).build())

        val result = service().fetchToken()

        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull()?.message?.contains("401") == true)
    }

    @Test
    fun reportsAFailureWhenTheBackendWillNotRefresh() = runBlocking {
        server.enqueue(MockResponse.Builder().code(403).build())

        assertTrue(service().refreshToken("stale").isFailure)
    }

    @Test
    fun reportsAFailureWhenTheBackendSendsSomethingThatIsNotAToken() = runBlocking {
        server.enqueue(response("not json at all"))

        assertTrue(service().fetchToken().isFailure)
    }

    // The recorded body is nullable because a request need not carry one. Every
    // request these tests look at does.
    private fun RecordedRequest.text(): String = requireNotNull(body).utf8()

    private fun service(config: YaloChatClientConfig = config()) = YaloMessageAuthServiceRemote(
        config = config,
        baseUrl = server.url("/"),
        now = { NOW },
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

    private fun response(body: String): MockResponse =
        MockResponse.Builder().code(200).body(body).build()

    private companion object {
        const val NOW = 1_700_000_000_000L
    }
}

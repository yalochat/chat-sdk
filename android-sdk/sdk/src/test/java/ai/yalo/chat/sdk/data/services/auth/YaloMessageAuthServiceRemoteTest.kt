// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.auth

import ai.yalo.chat.sdk.YaloChatClientConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.cancel
import kotlinx.coroutines.runBlocking
import mockwebserver3.MockResponse
import mockwebserver3.MockWebServer
import mockwebserver3.RecordedRequest
import org.json.JSONObject
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.util.concurrent.TimeUnit

@RunWith(RobolectricTestRunner::class)
class YaloMessageAuthServiceRemoteTest {

    private lateinit var server: MockWebServer
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val storage = FakeAuthTokenStorage()

    @Before
    fun startServer() {
        server = MockWebServer()
        server.start()
    }

    @After
    fun stopServer() {
        scope.cancel()
        server.close()
    }

    @Test
    fun authenticatesAnonymouslyWhenNoUserIsConfigured() = runBlocking {
        server.enqueue(tokenResponse())

        service().token()

        val body = JSONObject(server.takeRequest().text())
        assertEquals("anonymous", body.getString("user_type"))
        assertEquals(false, body.has("user_id"))
    }

    @Test
    fun identifiesTheUserWhenOneIsConfigured() = runBlocking {
        server.enqueue(tokenResponse())

        service(config(userId = "user-1")).token()

        val body = JSONObject(server.takeRequest().text())
        assertEquals("third_party_anonymous", body.getString("user_type"))
        assertEquals("user-1", body.getString("user_id"))
    }

    @Test
    fun sendsTheChannelItIsAuthenticatingFor() = runBlocking {
        server.enqueue(tokenResponse())

        service().token()

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
        server.enqueue(tokenResponse(accessToken = "issued"))

        assertEquals("issued", service().token().getOrNull())
    }

    @Test
    fun readsTheFieldsTheAuthEndpointSpellsInCamelCase() = runBlocking {
        server.enqueue(
            response("""{"accessToken":"camel","refreshToken":"r","expiresIn":3600}"""),
        )

        assertEquals("camel", service().token().getOrNull())
    }

    @Test
    fun reportsAFailureWhenTheBackendWillNotAuthenticate() = runBlocking {
        server.enqueue(MockResponse.Builder().code(401).build())

        val result = service().token()

        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull()?.message?.contains("401") == true)
    }

    @Test
    fun reportsAFailureWhenTheBackendSendsSomethingThatIsNotAToken() = runBlocking {
        server.enqueue(response("not json at all"))

        assertTrue(service().token().isFailure)
    }

    @Test
    fun keepsTheTokenSoTheNextChatDoesNotHaveToAuthenticate() = runBlocking {
        server.enqueue(tokenResponse(accessToken = "issued", expiresIn = 3_600))

        service().token()

        assertEquals("issued", storage.token?.accessToken)
        assertEquals(NOW + 3_600_000, storage.token?.expiresAtMillis)
    }

    @Test
    fun usesAStoredTokenWithoutTalkingToTheBackend() = runBlocking {
        storage.token = AuthToken("stored", "refresh", NOW + 3_600_000)

        val result = service().token()

        assertEquals("stored", result.getOrNull())
        assertEquals(0, server.requestCount)
    }

    @Test
    fun tradesAnExpiredTokenForANewOne() = runBlocking {
        storage.token = AuthToken("expired", "the-refresh-token", NOW - 1)
        server.enqueue(tokenResponse(accessToken = "refreshed"))

        val result = service().token()

        val request = server.takeRequest()
        assertEquals("refreshed", result.getOrNull())
        assertEquals("/v1/channels/oauth/token", request.url.encodedPath)
        assertEquals(
            "grant_type=refresh_token&refresh_token=the-refresh-token",
            request.text(),
        )
    }

    @Test
    fun authenticatesAgainWhenTheBackendWillNotRefresh() = runBlocking {
        storage.token = AuthToken("expired", "stale-refresh", NOW - 1)
        server.enqueue(MockResponse.Builder().code(403).build())
        server.enqueue(tokenResponse(accessToken = "fresh"))

        val result = service().token()

        assertEquals("fresh", result.getOrNull())
        assertEquals(2, server.requestCount)
    }

    @Test
    fun asksTheBackendOnceWhenTwoCallersAskAtTheSameTime() = runBlocking {
        server.enqueue(tokenResponse(accessToken = "shared"))
        val service = service()

        val answers = listOf(
            async { service.token() },
            async { service.token() },
        ).awaitAll()

        assertEquals(listOf("shared", "shared"), answers.map { answer -> answer.getOrNull() })
        assertEquals(1, server.requestCount)
    }

    @Test
    fun replacesATokenTheBackendStoppedAccepting() = runBlocking {
        storage.token = AuthToken("rejected", "the-refresh-token", NOW + 3_600_000)
        server.enqueue(tokenResponse(accessToken = "replacement"))
        val service = service()
        service.token()

        service.invalidateToken()

        assertEquals("replacement", service.token().getOrNull())
    }

    @Test
    fun forgetsTheStoredTokenWhenTheSessionEnds() = runBlocking {
        storage.token = AuthToken("stored", "refresh", NOW + 3_600_000)

        service().clearSession()

        assertNull(storage.token)
    }

    // The recorded body is nullable because a request need not carry one.
    // Every request these tests look at does.
    private fun RecordedRequest.text(): String = requireNotNull(body).utf8()

    private fun service(config: YaloChatClientConfig = config()): YaloMessageAuthServiceRemote =
        YaloMessageAuthServiceRemote(
            config = config,
            storage = storage,
            scope = scope,
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

    private fun response(body: String): MockResponse = MockResponse.Builder()
        .code(200)
        .body(body)
        // Every caller that arrives while this is in flight has to be waiting
        // before the answer lands, which is the whole point of the test that
        // counts requests.
        .bodyDelay(50, TimeUnit.MILLISECONDS)
        .build()

    private class FakeAuthTokenStorage : AuthTokenStorage {
        var token: AuthToken? = null

        override suspend fun read(): AuthToken? = token

        override suspend fun write(token: AuthToken) {
            this.token = token
        }

        override suspend fun clear() {
            token = null
        }
    }

    private companion object {
        const val NOW = 1_700_000_000_000L
    }
}

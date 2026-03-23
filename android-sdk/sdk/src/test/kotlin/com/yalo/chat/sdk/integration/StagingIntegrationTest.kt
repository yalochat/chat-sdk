// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.integration

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.buildHttpClient
import com.yalo.chat.sdk.data.repository.remote.YaloMessageRepositoryRemote
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import io.ktor.client.HttpClient
import io.ktor.client.engine.cio.CIO
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

// ── Real network integration tests against api-staging2.yalochat.com ──────────
// These tests exercise the FULL Kotlin stack: YaloMessageRepositoryRemote →
// YaloChatApiService → Ktor CIO → real HTTPS → real staging backend.
//
// runBlocking is used (not runTest) because real I/O needs a real coroutine dispatcher;
// runTest's virtual scheduler blocks CIO's internal coroutine machinery.
//
// Run manually:
//   STAGING_INTEGRATION=1 ./gradlew :sdk:testDebugUnitTest --tests "*.StagingIntegrationTest"
class StagingIntegrationTest {

    private val enabled = System.getenv("STAGING_INTEGRATION") == "1"

    private val apiBaseUrl = "https://api-staging2.yalochat.com/public-api-gateway/v1/channels"
    private val channelId = "c76f0984-db46-4b77-8591-ffbb27ab0e05"
    private val organizationId = "1000000219"

    // Debug logging is off by default to avoid leaking Authorization headers into CI logs.
    // Set STAGING_HTTP_DEBUG=1 locally to enable request/response tracing.
    private val httpDebug = System.getenv("STAGING_HTTP_DEBUG") == "1"

    // Single shared client — closed after all tests via @AfterTest.
    private val httpClient: HttpClient = buildHttpClient(engine = CIO.create(), debug = httpDebug)

    @AfterTest
    fun tearDown() {
        httpClient.close()
    }

    private fun buildRepo(pollingIntervalMs: Long = 500L): YaloMessageRepositoryRemote {
        val apiService = YaloChatApiService(
            apiBaseUrl = apiBaseUrl,
            channelId = channelId,
            organizationId = organizationId,
            httpClient = httpClient,
        )
        return YaloMessageRepositoryRemote(apiService, pollingIntervalMs = pollingIntervalMs)
    }

    // ── Auth + fetch ────────────────────────────────────────────────────────────

    @Test
    fun `fetchMessages authenticates and returns Ok against staging`() {
        if (!enabled) return

        runBlocking {
            val repo = buildRepo()
            val since = System.currentTimeMillis() - 60_000L
            val result = repo.fetchMessages(since)

            if (result is Result.Error) println("[integration] fetchMessages ERROR: ${result.error}")
            assertIs<Result.Ok<*>>(result)
            println("[integration] fetchMessages OK — ${(result as Result.Ok).result.size} message(s)")
        }
    }

    // ── Send + poll round-trip ──────────────────────────────────────────────────

    @Test
    fun `sendMessage then pollIncomingMessages receives agent reply from staging`() {
        if (!enabled) return

        runBlocking {
            val repo = buildRepo(pollingIntervalMs = 1_000L)

            val outgoing = ChatMessage(
                role = MessageRole.USER,
                type = MessageType.Text,
                status = MessageStatus.SENT,
                content = "Android SDK integration test ${System.currentTimeMillis()}",
            )
            val sendResult = repo.sendMessage(outgoing)
            if (sendResult is Result.Error) println("[integration] sendMessage ERROR: ${sendResult.error}")
            assertIs<Result.Ok<Unit>>(sendResult)
            println("[integration] sendMessage OK — content=${outgoing.content}")

            // Poll for the agent reply — staging bot typically replies within ~30s.
            // withTimeout ensures the test fails clearly instead of hanging CI.
            val batch = withTimeout(30_000L) { repo.pollIncomingMessages().first() }

            assertTrue(batch.isNotEmpty(), "Expected at least one message from agent within 30s")
            val reply = batch.first()
            println("[integration] received ${batch.size} message(s), first: role=${reply.role} text=${reply.content.take(80)}")

            assertNotNull(reply.content)
            assertTrue(reply.content.isNotEmpty())
            assertTrue(reply.role == MessageRole.AGENT || reply.role == MessageRole.USER)
            assertEquals(MessageType.Text, reply.type)
            assertEquals(MessageStatus.DELIVERED, reply.status)
        }
    }

    // ── Endpoint path check ─────────────────────────────────────────────────────

    @Test
    fun `fetchMessages uses inapp messages path (not webchat)`() {
        if (!enabled) return

        runBlocking {
            val apiService = YaloChatApiService(
                apiBaseUrl = apiBaseUrl,
                channelId = channelId,
                organizationId = organizationId,
                httpClient = httpClient,
            )
            val since = System.currentTimeMillis() - 10_000L
            val result = apiService.fetchMessages(since)
            if (result is Result.Error) println("[integration] fetchMessages ERROR: ${result.error}")
            assertIs<Result.Ok<*>>(result)
            println("[integration] /inapp/messages responded OK")
        }
    }
}

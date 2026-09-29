// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.common.session

import ai.yalo.chat.sdk.SessionMode
import ai.yalo.chat.sdk.YaloChatClientConfig
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Test

/**
 * The ids here were produced by the web SDK's `computeSessionId` and
 * `computeEffectiveAuthUserId` for the same config, so a change that moves
 * them parts the two clients.
 */
class ChatSessionTest {

    @Test
    fun scopesBySharedByDefault() {
        assertEquals("org-1-channel-1-anonymous", sessionOf(config()).id)
        assertEquals("org-1-channel-1-user-1", sessionOf(config(userId = "user-1")).id)
    }

    @Test
    fun tellsTheBackendWhoItIsOnlyWhenTheConfigSaid() {
        assertNull(sessionOf(config()).authUserId)
        assertEquals("user-1", sessionOf(config(userId = "user-1")).authUserId)
    }

    @Test
    fun ignoresTheContextUnlessItIsScopingByIt() {
        val session = sessionOf(config(userId = "user-1", openContext = CONTEXT))

        assertEquals("org-1-channel-1-user-1", session.id)
        assertEquals("user-1", session.authUserId)
    }

    @Test
    fun scopesByContext() {
        val session = sessionOf(
            config(userId = "user-1", openContext = CONTEXT, sessionMode = SessionMode.PerContext),
        )

        assertEquals("org-1-channel-1-user-1-188hajw", session.id)
        assertEquals("user-1-188hajw", session.authUserId)
    }

    @Test
    fun keepsAnAnonymousPersonAnonymousWhenScopingByContext() {
        val session = sessionOf(config(openContext = CONTEXT, sessionMode = SessionMode.PerContext))

        assertEquals("org-1-channel-1-anonymous-188hajw", session.id)
        assertNull(session.authUserId)
    }

    @Test
    fun readsTheSameContextInAnotherOrderAsAnotherConversation() {
        val ordered = sessionOf(
            config(openContext = CONTEXT, sessionMode = SessionMode.PerContext),
        )
        val reversed = sessionOf(
            config(
                openContext = mapOf("sku" to "37549996", "source" to "product-page"),
                sessionMode = SessionMode.PerContext,
            ),
        )

        assertNotEquals(ordered.id, reversed.id)
    }

    @Test
    fun writesAContextOfAwkwardCharactersTheWayTheWebSdkDoes() {
        val session = sessionOf(
            config(
                userId = "user-1",
                sessionMode = SessionMode.PerContext,
                openContext = mapOf(
                    "quote" to "a \"quoted\" value",
                    "backslash" to "c:\\tmp",
                    "lines" to "one\ntwo\rthree\tfour",
                    "control" to "\u0001\u001F",
                    "form" to "\b\u000C",
                    "unicode" to "ñ é 漢字",
                ),
            ),
        )

        assertEquals("org-1-channel-1-user-1-1ao0itf", session.id)
    }

    @Test
    fun scopesByNothingWhenThereIsNoContextToScopeBy() {
        val session = sessionOf(config(userId = "user-1", sessionMode = SessionMode.PerContext))

        assertEquals("org-1-channel-1-user-1", session.id)
        assertEquals("user-1", session.authUserId)
    }

    @Test
    fun scopesByTheIdOfTheVisit() {
        val session = sessionOf(
            config(userId = "user-1", sessionMode = SessionMode.Ephemeral),
            ephemeralId = "a-fresh-one",
        )

        assertEquals("org-1-channel-1-user-1-a-fresh-one", session.id)
        assertEquals("user-1-a-fresh-one", session.authUserId)
    }

    @Test
    fun asksForAFreshPersonForEveryAnonymousVisit() {
        val session = sessionOf(
            config(sessionMode = SessionMode.Ephemeral),
            ephemeralId = "a-fresh-one",
        )

        assertEquals("org-1-channel-1-anonymous-a-fresh-one", session.id)
        assertNull(session.authUserId)
    }

    @Test
    fun ignoresTheIdInTheModesThatDoNotUseIt() {
        val shared = sessionOf(config(userId = "user-1"), ephemeralId = "a-fresh-one")
        val perContext = sessionOf(
            config(userId = "user-1", openContext = CONTEXT, sessionMode = SessionMode.PerContext),
            ephemeralId = "a-fresh-one",
        )

        assertEquals("org-1-channel-1-user-1", shared.id)
        assertEquals("org-1-channel-1-user-1-188hajw", perContext.id)
    }

    @Test
    fun givesEveryEphemeralChatItsOwnId() {
        assertNotEquals(
            ephemeralIdOf(newEphemeralStamp()),
            ephemeralIdOf(newEphemeralStamp()),
        )
    }

    @Test
    fun keepsTheIdWhenTheScreenIsBuiltAgain() {
        val stamp = newEphemeralStamp()

        assertEquals(ephemeralIdOf(stamp), ephemeralIdOf(stamp))
    }

    @Test
    fun givesANewIdForAStampSavedByAnEarlierRun() {
        val earlierRun = "an-earlier-run|an-id-it-minted"

        assertNotEquals("an-id-it-minted", ephemeralIdOf(earlierRun))
    }

    @Test
    fun keepsAnsweringTheSameWayForAStampItHasAlreadyReplaced() {
        val earlierRun = "another-earlier-run|an-id-it-minted"

        assertEquals(ephemeralIdOf(earlierRun), ephemeralIdOf(earlierRun))
    }

    private fun config(
        userId: String? = null,
        openContext: Map<String, String> = emptyMap(),
        sessionMode: SessionMode = SessionMode.Shared,
    ) = YaloChatClientConfig(
        channelId = "channel-1",
        organizationId = "org-1",
        channelName = "Support",
        userId = userId,
        openContext = openContext,
        sessionMode = sessionMode,
    )

    private companion object {
        val CONTEXT = mapOf("source" to "product-page", "sku" to "37549996")
    }
}

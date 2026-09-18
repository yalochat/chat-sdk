// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.log

import ai.yalo.chat.sdk.LogLevel
import android.util.Log
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertSame
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.shadows.ShadowLog

@RunWith(RobolectricTestRunner::class)
class YaloLogTest {

    @Before
    fun forgetEarlierLogs() {
        ShadowLog.clear()
    }

    @Test
    fun writesUnderOneTagSoTheSdkCanBeReadOnItsOwn() {
        YaloLog("Auth", LogLevel.Debug).debug { "authenticating" }

        assertEquals(listOf(YaloLog.TAG), written().map { item -> item.tag })
    }

    @Test
    fun saysWhichPartOfTheSdkWrote() {
        YaloLog("Auth", LogLevel.Debug).debug { "authenticating" }

        assertEquals("Auth: authenticating", written().single().msg)
    }

    @Test
    fun writesEveryLevelFromTheOneItWasGiven() {
        val log = YaloLog("Auth", LogLevel.Debug)

        log.debug { "debug" }
        log.info { "info" }
        log.warn { "warn" }
        log.error { "error" }

        assertEquals(
            listOf(Log.DEBUG, Log.INFO, Log.WARN, Log.ERROR),
            written().map { item -> item.type },
        )
    }

    @Test
    fun keepsQuietBelowTheLevelItWasGiven() {
        val log = YaloLog("Auth", LogLevel.Warn)

        log.debug { "debug" }
        log.info { "info" }
        log.warn { "warn" }

        assertEquals(listOf("Auth: warn"), written().map { item -> item.msg })
    }

    @Test
    fun writesNothingAtAllWhenSilenced() {
        val log = YaloLog("Auth", LogLevel.Silent)

        log.debug { "debug" }
        log.info { "info" }
        log.warn { "warn" }
        log.error { "error" }

        assertEquals(emptyList<String>(), written().map { item -> item.msg })
    }

    @Test
    fun keepsQuietUnlessItIsAskedToSpeakUp() {
        YaloLog("Auth").info { "authenticating" }

        assertEquals(emptyList<String>(), written().map { item -> item.msg })
    }

    @Test
    fun carriesWhatWentWrong() {
        val cause = IllegalStateException("the line is down")

        YaloLog("Auth").error(cause) { "authentication failed" }

        assertSame(cause, written().single().throwable)
    }

    // Skipping a message costs nothing, which is what lets the SDK log freely
    // on paths that run for every frame.
    @Test
    fun buildsNoMessageItIsNotGoingToWrite() {
        var built = false

        YaloLog("Auth", LogLevel.Warn).debug {
            built = true
            "debug"
        }

        assertFalse(built)
    }

    private fun written(): List<ShadowLog.LogItem> =
        ShadowLog.getLogs().filter { item -> item.tag == YaloLog.TAG }
}

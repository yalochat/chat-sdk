// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import com.yalo.chat.sdk.domain.model.ChatCommand
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

// Tests for YaloChat.registerCommand() pre-init buffering behaviour.
// init() cannot be called in JVM unit tests (requires Android Context, AndroidSqliteDriver, etc.),
// so these tests focus on the pending-commands buffer: that registrations made before init()
// are stored and will be flushed to the repo when init() eventually runs.
class YaloChatTest {

    @Before
    fun setUp() {
        YaloChat.resetForTest()
    }

    @After
    fun tearDown() {
        YaloChat.resetForTest()
    }

    @Test
    fun `registerCommand before init stores callback in pending buffer`() {
        val callback: (Map<String, Any?>?) -> Unit = {}
        YaloChat.registerCommand(ChatCommand.ADD_TO_CART, callback)
        assertNotNull(
            "ADD_TO_CART callback should be in pending buffer",
            YaloChat.pendingCommandsForTest[ChatCommand.ADD_TO_CART],
        )
    }

    @Test
    fun `registerCommand before init stores all five commands independently`() {
        val cb1: (Map<String, Any?>?) -> Unit = {}
        val cb2: (Map<String, Any?>?) -> Unit = {}
        val cb3: (Map<String, Any?>?) -> Unit = {}
        val cb4: (Map<String, Any?>?) -> Unit = {}
        val cb5: (Map<String, Any?>?) -> Unit = {}

        YaloChat.registerCommand(ChatCommand.ADD_TO_CART, cb1)
        YaloChat.registerCommand(ChatCommand.REMOVE_FROM_CART, cb2)
        YaloChat.registerCommand(ChatCommand.CLEAR_CART, cb3)
        YaloChat.registerCommand(ChatCommand.ADD_PROMOTION, cb4)
        YaloChat.registerCommand(ChatCommand.GUIDANCE_CARD, cb5)

        val pending = YaloChat.pendingCommandsForTest
        assertEquals(5, pending.size)
        assertEquals(cb1, pending[ChatCommand.ADD_TO_CART])
        assertEquals(cb2, pending[ChatCommand.REMOVE_FROM_CART])
        assertEquals(cb3, pending[ChatCommand.CLEAR_CART])
        assertEquals(cb4, pending[ChatCommand.ADD_PROMOTION])
        assertEquals(cb5, pending[ChatCommand.GUIDANCE_CARD])
    }

    @Test
    fun `registerCommand before init overwrites previous registration for same command`() {
        val firstCallback: (Map<String, Any?>?) -> Unit = {}
        val secondCallback: (Map<String, Any?>?) -> Unit = {}

        YaloChat.registerCommand(ChatCommand.ADD_TO_CART, firstCallback)
        YaloChat.registerCommand(ChatCommand.ADD_TO_CART, secondCallback)

        assertEquals(
            "Second registration should overwrite first",
            secondCallback,
            YaloChat.pendingCommandsForTest[ChatCommand.ADD_TO_CART],
        )
    }

    @Test
    fun `resetForTest clears pending buffer`() {
        YaloChat.registerCommand(ChatCommand.CLEAR_CART) {}
        YaloChat.resetForTest()
        assertTrue("Pending buffer must be empty after reset", YaloChat.pendingCommandsForTest.isEmpty())
    }

    @Test
    fun `pending buffer is empty on fresh state`() {
        assertTrue("Pending buffer must be empty on fresh state", YaloChat.pendingCommandsForTest.isEmpty())
    }

    @Test
    fun `commands registered before fake init survive in pending buffer`() {
        val cb: (Map<String, Any?>?) -> Unit = {}
        YaloChat.registerCommand(ChatCommand.ADD_TO_CART, cb)

        // Simulate the fake-init re-buffer: snapshot → clear → putAll (what init() does in fake path).
        val snapshot = YaloChat.pendingCommandsForTest
        YaloChat.resetForTest()
        // Rehydrate as fake init now does via pendingCommands.putAll(savedCommands).
        snapshot.forEach { (cmd, callback) -> YaloChat.registerCommand(cmd, callback) }

        assertEquals(
            "Command must survive fake-init re-buffering",
            cb,
            YaloChat.pendingCommandsForTest[ChatCommand.ADD_TO_CART],
        )
    }
}

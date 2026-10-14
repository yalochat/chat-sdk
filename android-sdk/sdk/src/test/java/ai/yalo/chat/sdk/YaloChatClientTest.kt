// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class YaloChatClientTest {

    private val client = YaloChatClient(
        YaloChatClientConfig(channelId = "channel", organizationId = "organization", channelName = "Support"),
    )

    @Test
    fun handsBackTheHandlerRegisteredForACommand() = runBlocking {
        client.registerCommand("getStore") { payload -> "store $payload" }

        assertEquals("store 42", client.commandHandler("getStore")?.invoke("42"))
    }

    @Test
    fun keepsTheLatestHandlerForACommandRegisteredTwice() = runBlocking {
        client.registerCommand("getStore") { _ -> "first" }
        client.registerCommand("getStore") { _ -> "second" }

        assertEquals("second", client.commandHandler("getStore")?.invoke(""))
    }

    @Test
    fun hasNoHandlerForACommandNeverRegistered() {
        assertNull(client.commandHandler("getStore"))
    }
}

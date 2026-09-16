// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.config

import ai.yalo.chat.sdk.YaloChatClientConfig
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertSame
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment

@RunWith(RobolectricTestRunner::class)
class ChatDependenciesTest {

    @Test
    fun buildsWhatOneConversationNeeds() {
        val dependencies = dependencies()

        assertNotNull(dependencies.chatMessages)
        assertNotNull(dependencies.auth)
    }

    @Test
    fun handsOutTheSameInstanceHoweverOftenItIsAsked() {
        val dependencies = dependencies()

        assertSame(dependencies.chatMessages, dependencies.chatMessages)
        assertSame(dependencies.auth, dependencies.auth)
    }

    private fun dependencies() = ChatDependencies(
        context = RuntimeEnvironment.getApplication(),
        config = YaloChatClientConfig(
            channelId = "channel-1",
            organizationId = "org-1",
            channelName = "Support",
        ),
    )
}

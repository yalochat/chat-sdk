// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.message

import ai.yalo.chat.sdk.internal.proto.v2.MessageRole
import ai.yalo.chat.sdk.internal.proto.v2.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.TextMessage
import ai.yalo.chat.sdk.internal.proto.v2.TextMessageRequest
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Apps are not asked to turn on desugaring, so the wire format has to work on
 * API 24 and 25, where `java.time` does not exist. Only a device on one of
 * those can show that it does.
 */
@RunWith(AndroidJUnit4::class)
class WireFormatInstrumentedTest {

    @Test
    fun readsBackWhatItWrites() {
        val item = PollMessageItem(
            id = "wi-1",
            date = timestampOf(1_700_000_005_123L),
            message = SdkMessage(
                correlation_id = "cid-1",
                timestamp = timestampOf(1_700_000_005_000L),
                text_message_request = TextMessageRequest(
                    content = TextMessage(text = "hello", role = MessageRole.MESSAGE_ROLE_AGENT),
                ),
            ),
        )

        val frame = WireFormat.write(item)

        assertEquals(item, WireFormat.read(frame, PollMessageItem::class.java))
    }

    @Test
    fun readsATimeTheWayTheBackendWritesIt() {
        val item = WireFormat.read("""{"date":"2023-11-14T22:13:25.123Z"}""", PollMessageItem::class.java)

        assertEquals(1_700_000_005_123L, item.date?.toEpochMillis())
    }
}

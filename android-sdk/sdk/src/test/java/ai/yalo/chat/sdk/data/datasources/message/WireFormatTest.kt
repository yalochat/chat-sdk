// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.message

import ai.yalo.chat.sdk.internal.proto.v2.ImageMessage
import ai.yalo.chat.sdk.internal.proto.v2.ImageMessageRequest
import ai.yalo.chat.sdk.internal.proto.v2.MessageRole
import ai.yalo.chat.sdk.internal.proto.v2.MessageStatus
import ai.yalo.chat.sdk.internal.proto.v2.PollMessageItem
import ai.yalo.chat.sdk.internal.proto.v2.SdkMessage
import ai.yalo.chat.sdk.internal.proto.v2.TextMessage
import ai.yalo.chat.sdk.internal.proto.v2.Timestamp
import ai.yalo.chat.sdk.internal.proto.v2.VoiceMessage
import ai.yalo.chat.sdk.internal.proto.v2.VoiceNoteMessageRequest
import com.squareup.moshi.JsonDataException
import com.squareup.moshi.Moshi
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Pins the JSON to what the backend speaks, written out by hand, so a change in
 * the codec cannot drift from it unnoticed.
 */
class WireFormatTest {

    @Test
    fun writesAMessageTheWayTheBackendReadsIt() {
        val message = SdkMessage(
            correlation_id = "cid-1",
            timestamp = timestampOf(1_700_000_005_000L),
            voice_note_message_request = VoiceNoteMessageRequest(
                content = VoiceMessage(
                    media_url = "media-1",
                    byte_count = 2_048L,
                    duration = 4.5,
                    amplitudes_preview = listOf(0.25f),
                    role = MessageRole.MESSAGE_ROLE_USER,
                    status = MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
                ),
            ),
        )

        assertSameJson(
            """
            {"correlationId":"cid-1","timestamp":"2023-11-14T22:13:25Z",
            "voiceNoteMessageRequest":{"content":{"mediaUrl":"media-1","byteCount":"2048",
            "duration":4.5,"amplitudesPreview":[0.25],"role":"MESSAGE_ROLE_USER",
            "status":"MESSAGE_STATUS_IN_PROGRESS"}}}
            """,
            WireFormat.write(message),
        )
    }

    @Test
    fun writesTheMillisecondsOfATime() {
        val message = SdkMessage(timestamp = timestampOf(1_700_000_005_123L))

        assertSameJson("""{"timestamp":"2023-11-14T22:13:25.123Z"}""", WireFormat.write(message))
    }

    @Test
    fun writesEveryFieldWhenAskedTo() {
        val message = TextMessage()

        assertSameJson(
            """{"text":"","status":"MESSAGE_STATUS_UNSPECIFIED","role":"MESSAGE_ROLE_UNSPECIFIED"}""",
            WireFormat.write(message, everyField = true),
        )
    }

    @Test
    fun readsAMessageTheWayTheBackendWritesIt() {
        val frame = """
            {"id":"wi-1","date":"2023-11-14T22:13:25.123Z","status":"READ","somethingNewer":{"a":1},
            "message":{"correlationId":"cid-1","imageMessageRequest":{"header":"Support",
            "content":{"mediaUrl":"https://yalo.com/shirt.png","byteCount":"4096","role":"MESSAGE_ROLE_AGENT"}}}}
        """.trimIndent()

        val expected = PollMessageItem(
            id = "wi-1",
            date = timestampOf(1_700_000_005_123L),
            status = "READ",
            message = SdkMessage(
                correlation_id = "cid-1",
                image_message_request = ImageMessageRequest(
                    header_ = "Support",
                    content = ImageMessage(
                        media_url = "https://yalo.com/shirt.png",
                        byte_count = 4_096L,
                        role = MessageRole.MESSAGE_ROLE_AGENT,
                    ),
                ),
            ),
        )
        assertEquals(expected, WireFormat.read(frame, PollMessageItem::class.java))
    }

    @Test
    fun readsAnEnumGivenAsItsNumber() {
        val message = WireFormat.read("""{"role":2}""", TextMessage::class.java)

        assertEquals(MessageRole.MESSAGE_ROLE_AGENT, message.role)
    }

    @Test
    fun readsAnEnumNumberItDoesNotKnowAsTheZeroValue() {
        val message = WireFormat.read("""{"role":99}""", TextMessage::class.java)

        assertEquals(MessageRole.MESSAGE_ROLE_UNSPECIFIED, message.role)
    }

    @Test(expected = JsonDataException::class)
    fun refusesATimeThatIsNotOne() {
        WireFormat.read("""{"timestamp":"the day before yesterday"}""", TextMessage::class.java)
    }

    @Test(expected = JsonDataException::class)
    fun refusesNull() {
        WireFormat.read("null", TextMessage::class.java)
    }

    @Test
    fun writesAsManyFractionDigitsAsTheTimeNeeds() {
        assertEquals(
            listOf("1970-01-01T00:00:00.000001Z", "1970-01-01T00:00:00.000000001Z"),
            listOf(timeOf(seconds = 0, nanos = 1_000), timeOf(seconds = 0, nanos = 1)),
        )
    }

    @Test
    fun writesATimeBeforeTheEpoch() {
        assertEquals("1969-12-31T23:59:59.999Z", timeOf(timestampOf(-1L)))
    }

    @Test
    fun writesALeapDay() {
        assertEquals("2024-02-29T12:00:00Z", timeOf(seconds = 1_709_208_000L))
    }

    @Test
    fun readsATimeWithAnOffsetAsTheSameMomentInUtc() {
        assertEquals(timeRead("2023-11-14T22:13:25Z"), timeRead("2023-11-14T16:13:25-06:00"))
        assertEquals(timeRead("2023-11-14T22:13:25Z"), timeRead("2023-11-15T03:43:25+05:30"))
    }

    @Test
    fun readsEveryDigitOfTheFraction() {
        assertEquals(Timestamp(seconds = 0, nanos = 123_456_789), timeRead("1970-01-01T00:00:00.123456789Z"))
        assertEquals(Timestamp(seconds = 0, nanos = 500_000_000), timeRead("1970-01-01T00:00:00.5Z"))
    }

    @Test
    fun readsATimeWrittenInLowerCase() {
        assertEquals(timeRead("2023-11-14T22:13:25Z"), timeRead("2023-11-14t22:13:25z"))
    }

    @Test
    fun readsBackWhatItWrites() {
        val times = listOf(
            timestampOf(0L),
            timestampOf(-86_400_001L),
            timestampOf(1_700_000_005_123L),
            Timestamp(seconds = 253_402_300_799L, nanos = 999_999_999),
            Timestamp(seconds = -62_135_596_800L),
        )

        assertEquals(times, times.map { time -> timeRead(timeOf(time)) })
    }

    @Test(expected = JsonDataException::class)
    fun refusesADayTheMonthDoesNotHave() {
        timeRead("2023-02-29T00:00:00Z")
    }

    @Test(expected = JsonDataException::class)
    fun refusesATimeWithNoZone() {
        timeRead("2023-11-14T22:13:25")
    }

    @Test
    fun keepsTheMillisecondsOfATime() {
        assertEquals(listOf(1_700_000_005_123L, -1L), listOf(1_700_000_005_123L, -1L).map { timestampOf(it).toEpochMillis() })
    }

    private fun timeOf(seconds: Long, nanos: Int = 0): String = timeOf(Timestamp(seconds = seconds, nanos = nanos))

    private fun timeOf(time: Timestamp): String =
        WireFormat.write(TextMessage(timestamp = time)).substringAfter("\"timestamp\":\"").substringBefore('"')

    private fun timeRead(time: String): Timestamp? =
        WireFormat.read("""{"timestamp":"$time"}""", TextMessage::class.java).timestamp

    private fun assertSameJson(expected: String, actual: String) {
        val tree = Moshi.Builder().build().adapter(Any::class.java)
        assertEquals(tree.fromJson(expected), tree.fromJson(actual))
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.message

import ai.yalo.chat.sdk.internal.proto.v2.Timestamp
import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.JsonDataException
import com.squareup.moshi.JsonReader
import com.squareup.moshi.JsonWriter
import com.squareup.moshi.Moshi
import com.squareup.wire.Message
import com.squareup.wire.WireJsonAdapterFactory

/**
 * Reads and writes the proto3 JSON the channel speaks.
 *
 * Unknown fields are skipped and an unknown enum value reads as the enum's zero
 * value, so a newer backend cannot break an older app.
 */
internal object WireFormat {

    private val compact: Moshi = moshi(writeIdentityValues = false)

    // For a host reading a field, which should never find it missing because it was zero.
    private val complete: Moshi = moshi(writeIdentityValues = true)

    fun write(message: Message<*, *>, everyField: Boolean = false): String {
        val moshi = if (everyField) complete else compact
        @Suppress("UNCHECKED_CAST")
        return (moshi.adapter(message.javaClass) as JsonAdapter<Message<*, *>>).toJson(message)
    }

    /**
     * Throws [JsonDataException] when [text] is JSON but not a [type], and
     * [java.io.IOException] when it is not JSON at all.
     */
    fun <M : Message<M, *>> read(text: String, type: Class<M>): M =
        compact.adapter(type).fromJson(text)
            ?: throw JsonDataException("Expected a ${type.simpleName}, found null")

    private fun moshi(writeIdentityValues: Boolean): Moshi = Moshi.Builder()
        .add(Timestamp::class.java, TimestampAdapter.nullSafe())
        .add(WireJsonAdapterFactory(writeIdentityValues = writeIdentityValues))
        .build()
}

internal fun timestampOf(epochMillis: Long): Timestamp = Timestamp(
    seconds = epochMillis.floorDiv(MILLIS_PER_SECOND),
    nanos = (epochMillis.mod(MILLIS_PER_SECOND) * NANOS_PER_MILLI).toInt(),
)

internal fun Timestamp.toEpochMillis(): Long = seconds * MILLIS_PER_SECOND + nanos / NANOS_PER_MILLI

/**
 * A timestamp as proto3 JSON writes it, an RFC 3339 string such as
 * `2023-11-14T22:13:25.123Z`.
 *
 * Worked out by hand rather than with `java.time`, which Android only has from
 * API 26 unless the app turns on desugaring.
 */
private object TimestampAdapter : JsonAdapter<Timestamp>() {

    private val RFC_3339 = Regex(
        """(\d{4})-(\d{2})-(\d{2})[Tt](\d{2}):(\d{2}):(\d{2})(?:\.(\d{1,9}))?(?:[Zz]|([+-])(\d{2}):(\d{2}))""",
    )

    override fun toJson(writer: JsonWriter, value: Timestamp?) {
        writer.value(value?.let(::format))
    }

    override fun fromJson(reader: JsonReader): Timestamp {
        val text = reader.nextString()
        return parse(text) ?: throw JsonDataException("Expected an RFC 3339 time at ${reader.path}, found $text")
    }

    private fun format(timestamp: Timestamp): String {
        val days = timestamp.seconds.floorDiv(SECONDS_PER_DAY)
        val secondOfDay = timestamp.seconds.mod(SECONDS_PER_DAY)
        val (year, month, day) = civilFromDays(days)
        return buildString {
            append(year.toString().padStart(4, '0')).append('-')
            append(twoDigits(month)).append('-')
            append(twoDigits(day)).append('T')
            append(twoDigits(secondOfDay / SECONDS_PER_HOUR)).append(':')
            append(twoDigits(secondOfDay % SECONDS_PER_HOUR / SECONDS_PER_MINUTE)).append(':')
            append(twoDigits(secondOfDay % SECONDS_PER_MINUTE))
            append(fractionOf(timestamp.nanos))
            append('Z')
        }
    }

    // The fewest of 3, 6 or 9 digits that keep the value, as protobuf writes it.
    private fun fractionOf(nanos: Int): String {
        val digits = nanos.toString().padStart(9, '0')
        return when {
            nanos == 0 -> ""
            nanos % 1_000_000 == 0 -> "." + digits.take(3)
            nanos % 1_000 == 0 -> "." + digits.take(6)
            else -> ".$digits"
        }
    }

    private fun parse(text: String): Timestamp? {
        val match = RFC_3339.matchEntire(text) ?: return null
        val parts = match.groupValues
        val year = parts[1].toLong()
        val month = parts[2].toInt()
        val day = parts[3].toInt()
        val hour = parts[4].toLong()
        val minute = parts[5].toLong()
        val second = parts[6].toLong()
        val valid = month in 1..12 && day in 1..daysIn(year, month) &&
            hour < 24 && minute < 60 && second < 60
        if (!valid) {
            return null
        }
        var seconds = daysFromCivil(year, month, day) * SECONDS_PER_DAY +
            hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second
        if (parts[8].isNotEmpty()) {
            val offset = parts[9].toLong() * SECONDS_PER_HOUR + parts[10].toLong() * SECONDS_PER_MINUTE
            seconds -= if (parts[8] == "+") offset else -offset
        }
        val nanos = parts[7].padEnd(9, '0').takeIf { parts[7].isNotEmpty() }?.toInt() ?: 0
        return Timestamp(seconds = seconds, nanos = nanos)
    }

    private fun twoDigits(value: Number): String = value.toString().padStart(2, '0')

    private fun daysIn(year: Long, month: Int): Int = when (month) {
        2 -> if (year % 4 == 0L && (year % 100 != 0L || year % 400 == 0L)) 29 else 28
        4, 6, 9, 11 -> 30
        else -> 31
    }

    // Days since 1970-01-01 in the proleptic Gregorian calendar, after Howard
    // Hinnant's days_from_civil.
    private fun daysFromCivil(year: Long, month: Int, day: Int): Long {
        val y = if (month <= 2) year - 1 else year
        val era = y.floorDiv(400L)
        val yearOfEra = y - era * 400
        val dayOfYear = (153 * (if (month > 2) month - 3 else month + 9) + 2) / 5 + day - 1
        val dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * DAYS_PER_ERA + dayOfEra - EPOCH_SHIFT
    }

    private fun civilFromDays(days: Long): Triple<Long, Int, Int> {
        val shifted = days + EPOCH_SHIFT
        val era = shifted.floorDiv(DAYS_PER_ERA)
        val dayOfEra = shifted - era * DAYS_PER_ERA
        val yearOfEra = (dayOfEra - dayOfEra / 1460 + dayOfEra / 36524 - dayOfEra / 146096) / 365
        val dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        val shiftedMonth = (5 * dayOfYear + 2) / 153
        val day = (dayOfYear - (153 * shiftedMonth + 2) / 5 + 1).toInt()
        val month = (if (shiftedMonth < 10) shiftedMonth + 3 else shiftedMonth - 9).toInt()
        val year = yearOfEra + era * 400 + if (month <= 2) 1 else 0
        return Triple(year, month, day)
    }

    private const val SECONDS_PER_MINUTE = 60L
    private const val SECONDS_PER_HOUR = 3_600L
    private const val SECONDS_PER_DAY = 86_400L
    private const val DAYS_PER_ERA = 146_097L

    /** Days from 0000-03-01, where the arithmetic counts from, to 1970-01-01. */
    private const val EPOCH_SHIFT = 719_468L
}

private const val MILLIS_PER_SECOND = 1_000L
private const val NANOS_PER_MILLI = 1_000_000L

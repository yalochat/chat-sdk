// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.message

import ai.yalo.chat.sdk.internal.proto.v2.Timestamp
import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.JsonDataException
import com.squareup.moshi.JsonReader
import com.squareup.moshi.JsonWriter
import com.squareup.moshi.Moshi
import com.squareup.moshi.adapters.Rfc3339DateJsonAdapter
import com.squareup.wire.Message
import com.squareup.wire.WireJsonAdapterFactory
import java.util.Date

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

// RFC 3339 to the millisecond, through java.util.Date because java.time needs API 26.
private object TimestampAdapter : JsonAdapter<Timestamp>() {

    private val dates = Rfc3339DateJsonAdapter()

    override fun toJson(writer: JsonWriter, value: Timestamp?) {
        dates.toJson(writer, value?.let { Date(it.toEpochMillis()) })
    }

    override fun fromJson(reader: JsonReader): Timestamp? = dates.fromJson(reader)?.let { timestampOf(it.time) }
}

private const val MILLIS_PER_SECOND = 1_000L
private const val NANOS_PER_MILLI = 1_000_000L

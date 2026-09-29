// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.common.hash

/**
 * xxhash32 over the UTF-8 bytes of [input], written in base 36.
 *
 * A port of the same function in the web SDK, which is what makes a session
 * scoped by context the same conversation on both clients. Every step has to
 * keep matching it, so change this only alongside the web one.
 *
 * Reference: https://github.com/Cyan4973/xxHash/blob/dev/doc/xxhash_spec.md
 */
internal fun xxhash32(input: String): String {
    val data: ByteArray = input.toByteArray(Charsets.UTF_8)
    val length: Int = data.size
    var index = 0
    var hash: Int

    if (length >= BLOCK) {
        var first: Int = PRIME1 + PRIME2
        var second: Int = PRIME2
        var third = 0
        var fourth: Int = -PRIME1
        val limit: Int = length - BLOCK
        do {
            first = round(first, readInt(data, index))
            second = round(second, readInt(data, index + Int.SIZE_BYTES))
            third = round(third, readInt(data, index + Int.SIZE_BYTES * 2))
            fourth = round(fourth, readInt(data, index + Int.SIZE_BYTES * 3))
            index += BLOCK
        } while (index <= limit)
        hash = Integer.rotateLeft(first, 1) +
            Integer.rotateLeft(second, 7) +
            Integer.rotateLeft(third, 12) +
            Integer.rotateLeft(fourth, 18)
    } else {
        hash = PRIME5
    }

    hash += length

    while (index + Int.SIZE_BYTES <= length) {
        hash += readInt(data, index) * PRIME3
        hash = Integer.rotateLeft(hash, 17) * PRIME4
        index += Int.SIZE_BYTES
    }

    while (index < length) {
        hash += (data[index].toInt() and BYTE) * PRIME5
        hash = Integer.rotateLeft(hash, 11) * PRIME1
        index += 1
    }

    hash = hash xor (hash ushr 15)
    hash *= PRIME2
    hash = hash xor (hash ushr 13)
    hash *= PRIME3
    hash = hash xor (hash ushr 16)

    return (hash.toLong() and UNSIGNED).toString(RADIX)
}

private fun round(accumulator: Int, lane: Int): Int =
    Integer.rotateLeft(accumulator + lane * PRIME2, 13) * PRIME1

private fun readInt(data: ByteArray, offset: Int): Int =
    (data[offset].toInt() and BYTE) or
        ((data[offset + 1].toInt() and BYTE) shl 8) or
        ((data[offset + 2].toInt() and BYTE) shl 16) or
        ((data[offset + 3].toInt() and BYTE) shl 24)

private const val PRIME1: Int = -1640531535
private const val PRIME2: Int = -2048144777
private const val PRIME3: Int = -1028477379
private const val PRIME4: Int = 668265263
private const val PRIME5: Int = 374761393

private const val BLOCK: Int = 16
private const val BYTE: Int = 0xFF
private const val RADIX: Int = 36
private const val UNSIGNED: Long = 0xFFFFFFFFL

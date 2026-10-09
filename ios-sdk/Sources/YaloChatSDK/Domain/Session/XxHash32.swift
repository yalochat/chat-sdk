// Copyright (c) Yalochat, Inc. All rights reserved.

/// xxhash32 over the UTF-8 bytes of `input`, written in base 36.
///
/// A port of the same function in the web and Android SDKs, which is what
/// makes a session scoped by context the same conversation on every client.
/// Change it only alongside theirs.
///
/// Reference: https://github.com/Cyan4973/xxHash/blob/dev/doc/xxhash_spec.md
func xxhash32(_ input: String) -> String {
    let data: [UInt8] = Array(input.utf8)
    let length: Int = data.count
    var index: Int = 0
    var hash: UInt32

    if length >= block {
        var first: UInt32 = prime1 &+ prime2
        var second: UInt32 = prime2
        var third: UInt32 = 0
        var fourth: UInt32 = 0 &- prime1
        repeat {
            first = round(first, lane(data, index))
            second = round(second, lane(data, index + 4))
            third = round(third, lane(data, index + 8))
            fourth = round(fourth, lane(data, index + 12))
            index += block
        } while index <= length - block
        hash = rotated(first, 1) &+ rotated(second, 7) &+ rotated(third, 12) &+ rotated(fourth, 18)
    } else {
        hash = prime5
    }

    hash &+= UInt32(truncatingIfNeeded: length)

    while index + 4 <= length {
        hash &+= lane(data, index) &* prime3
        hash = rotated(hash, 17) &* prime4
        index += 4
    }

    while index < length {
        hash &+= UInt32(data[index]) &* prime5
        hash = rotated(hash, 11) &* prime1
        index += 1
    }

    hash ^= hash >> 15
    hash &*= prime2
    hash ^= hash >> 13
    hash &*= prime3
    hash ^= hash >> 16

    return String(hash, radix: 36)
}

private func round(_ accumulator: UInt32, _ lane: UInt32) -> UInt32 {
    rotated(accumulator &+ lane &* prime2, 13) &* prime1
}

private func rotated(_ value: UInt32, _ bits: UInt32) -> UInt32 {
    (value << bits) | (value >> (32 - bits))
}

private func lane(_ data: [UInt8], _ offset: Int) -> UInt32 {
    UInt32(data[offset])
        | UInt32(data[offset + 1]) << 8
        | UInt32(data[offset + 2]) << 16
        | UInt32(data[offset + 3]) << 24
}

private let prime1: UInt32 = 2_654_435_761
private let prime2: UInt32 = 2_246_822_519
private let prime3: UInt32 = 3_266_489_917
private let prime4: UInt32 = 668_265_263
private let prime5: UInt32 = 374_761_393
private let block: Int = 16

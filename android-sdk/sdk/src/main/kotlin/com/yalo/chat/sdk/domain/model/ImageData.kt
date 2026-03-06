// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of flutter-sdk/lib/src/domain/models/image/image_data.dart
// ByteArray does not implement structural equals by default in Kotlin —
// equals/hashCode are overridden to ensure two instances with identical bytes compare equal.
data class ImageData(
    val path: String? = null,
    val bytes: ByteArray? = null,
    val mimeType: String = "image/jpeg",
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is ImageData) return false
        return path == other.path &&
            mimeType == other.mimeType &&
            when {
                bytes === other.bytes -> true
                bytes == null || other.bytes == null -> false
                else -> bytes.contentEquals(other.bytes)
            }
    }

    override fun hashCode(): Int {
        var result = path?.hashCode() ?: 0
        result = 31 * result + (bytes?.contentHashCode() ?: 0)
        result = 31 * result + mimeType.hashCode()
        return result
    }
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

internal actual object PlatformFiles {
    actual fun readBytes(path: String): ByteArray = java.io.File(path).readBytes()

    actual fun writeToDir(dirPath: String?, filename: String, bytes: ByteArray): String? {
        val dir = dirPath?.let { java.io.File(it) } ?: return null
        return try {
            val file = java.io.File(dir, filename)
            file.writeBytes(bytes)
            file.absolutePath
        } catch (_: Exception) {
            null
        }
    }
}

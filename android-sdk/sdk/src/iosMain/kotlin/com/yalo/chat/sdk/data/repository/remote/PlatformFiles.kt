// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.addressOf
import kotlinx.cinterop.convert
import kotlinx.cinterop.usePinned
import platform.Foundation.NSData
import platform.Foundation.NSFileManager
import platform.Foundation.dataWithBytes
import platform.Foundation.dataWithContentsOfFile
import platform.posix.memcpy

@OptIn(ExperimentalForeignApi::class)
internal actual object PlatformFiles {

    actual fun readBytes(path: String): ByteArray {
        val data = NSData.dataWithContentsOfFile(path)
            ?: throw Exception("Cannot read file: $path")
        return ByteArray(data.length.toInt()).also { arr ->
            if (arr.isNotEmpty()) arr.usePinned { pinned ->
                memcpy(pinned.addressOf(0), data.bytes, data.length)
            }
        }
    }

    actual fun writeToDir(dirPath: String?, filename: String, bytes: ByteArray): String? {
        val dir = dirPath ?: return null
        return try {
            NSFileManager.defaultManager.createDirectoryAtPath(
                path = dir,
                withIntermediateDirectories = true,
                attributes = null,
                error = null,
            )
            val filePath = if (dir.endsWith("/")) "$dir$filename" else "$dir/$filename"
            val data = bytes.usePinned { pinned ->
                NSData.dataWithBytes(pinned.addressOf(0), bytes.size.convert())
            }
            val ok = NSFileManager.defaultManager.createFileAtPath(
                path = filePath,
                contents = data,
                attributes = null,
            )
            if (ok) filePath else null
        } catch (_: Exception) {
            null
        }
    }
}

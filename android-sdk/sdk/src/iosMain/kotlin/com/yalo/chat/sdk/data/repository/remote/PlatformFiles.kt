// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

// iOS file operations — implemented in Phase 1 M3 (Image Picker milestone).
// Throws NotImplementedError to fail fast if accidentally called before the real
// implementation lands, rather than silently uploading empty bytes or dropping media.
internal actual object PlatformFiles {
    actual fun readBytes(path: String): ByteArray =
        throw NotImplementedError("PlatformFiles.readBytes not implemented for iOS — implement in Phase 1 M3")

    actual fun writeToDir(dirPath: String?, filename: String, bytes: ByteArray): String? =
        throw NotImplementedError("PlatformFiles.writeToDir not implemented for iOS — implement in Phase 1 M3")
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

// iOS file operations — implemented in Phase 1 M3 (Image Picker milestone).
// Stubs return safe no-op values so commonMain compiles for iOS targets in pre-work.
internal actual object PlatformFiles {
    actual fun readBytes(path: String): ByteArray = ByteArray(0)
    actual fun writeToDir(dirPath: String?, filename: String, bytes: ByteArray): String? = null
}

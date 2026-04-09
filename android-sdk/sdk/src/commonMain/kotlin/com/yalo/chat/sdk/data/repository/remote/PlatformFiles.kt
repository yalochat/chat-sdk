// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

// Platform-specific file operations needed by YaloMessageRepositoryRemote.
// androidMain: backed by java.io.File.
// iosMain: backed by Foundation NSURL / FileManager (wired in iOS M3).
internal expect object PlatformFiles {
    // Reads the file at the given absolute path and returns its bytes.
    fun readBytes(path: String): ByteArray

    // Writes bytes to a new file named [filename] inside [dirPath].
    // Returns the absolute path of the written file, or null on failure.
    fun writeToDir(dirPath: String?, filename: String, bytes: ByteArray): String?
}

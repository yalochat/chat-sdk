// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.log

import ai.yalo.chat.sdk.LogLevel
import android.util.Log

/**
 * What the SDK says about itself, under one logcat tag.
 *
 * Everything goes out under [TAG], so `adb logcat -s YaloChatSDK` shows all of
 * the SDK and nothing else, and [name] says which part of it a line came from.
 *
 * A message is built only when it is going to be written, so a chat left at its
 * default level pays nothing for the lines it never prints.
 *
 * No line at any level may carry a token or an address holding a signature.
 * Logcat is readable by more than the app that wrote to it.
 *
 * What was actually said is written only at [LogLevel.Debug], which a released
 * app is not meant to run at. Every other level says that a message moved and
 * what kind it was, never its content.
 */
internal class YaloLog(
    private val name: String,
    private val level: LogLevel = LogLevel.Warn,
) {

    fun debug(message: () -> String) {
        write(LogLevel.Debug, null, message)
    }

    fun info(message: () -> String) {
        write(LogLevel.Info, null, message)
    }

    fun warn(error: Throwable? = null, message: () -> String) {
        write(LogLevel.Warn, error, message)
    }

    fun error(error: Throwable? = null, message: () -> String) {
        write(LogLevel.Error, error, message)
    }

    private fun write(at: LogLevel, error: Throwable?, message: () -> String) {
        if (at < level) {
            return
        }
        val line = "$name: ${message()}"
        when (at) {
            LogLevel.Debug -> Log.d(TAG, line, error)
            LogLevel.Info -> Log.i(TAG, line, error)
            LogLevel.Warn -> Log.w(TAG, line, error)
            LogLevel.Error -> Log.e(TAG, line, error)
            LogLevel.Silent -> Unit
        }
    }

    internal companion object {
        const val TAG: String = "YaloChatSDK"
    }
}

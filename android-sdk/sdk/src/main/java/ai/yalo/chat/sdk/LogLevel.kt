// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

/**
 * How much the SDK says about itself in logcat.
 *
 * Each level includes the ones after it, so [Info] also writes warnings and
 * errors. [Silent] writes nothing at all.
 */
public enum class LogLevel {
    Debug,
    Info,
    Warn,
    Error,
    Silent,
}

// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import android.content.Context
import android.content.pm.ApplicationInfo

/**
 * Whether the host application is debuggable.
 *
 * The KMP Android library plugin produces a single variant and does not generate a
 * `BuildConfig` class, so the SDK reads the host app's manifest flag instead of its own
 * build type. This is also more accurate: a published SDK release AAR always reported
 * `BuildConfig.DEBUG == false`, even inside a debug build of the host app.
 */
internal fun Context.isHostDebuggable(): Boolean =
    (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

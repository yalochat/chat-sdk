// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.common

/** Replaces characters unsafe in filenames and platform storage keys with underscores. */
internal fun sanitizeStorageId(value: String): String =
    value.replace(Regex("[^a-zA-Z0-9_.\\-]"), "_")

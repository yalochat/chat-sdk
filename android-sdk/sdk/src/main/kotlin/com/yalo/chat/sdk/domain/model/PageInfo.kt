// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// Port of flutter-sdk/lib/src/common/page.dart
// All cursor fields are nullable Longs — matching Flutter's int? cursor fields.
data class PageInfo(
    val cursor: Long? = null,
    val nextCursor: Long? = null,
    val prevCursor: Long? = null,
    val pageSize: Int = 20,
    val total: Int? = null,
    val totalPages: Int? = null,
    val page: Int? = null,
)

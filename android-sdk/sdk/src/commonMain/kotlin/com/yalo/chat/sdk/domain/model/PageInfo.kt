// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

// All cursor fields are nullable Longs.
data class PageInfo(
    val cursor: Long? = null,
    val nextCursor: Long? = null,
    val prevCursor: Long? = null,
    val pageSize: Int = 20,
    val total: Int? = null,
    val totalPages: Int? = null,
    val page: Int? = null,
)

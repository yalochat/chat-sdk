// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable

// Port of flutter-sdk ChatAppBar — Phase 1 shows name only (no icon/actions).
// Phase 2 will add chatIconImage, shop/cart action buttons, and status text.
@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun ChatAppBar(title: String) {
    TopAppBar(
        title = { Text(text = title) },
    )
}

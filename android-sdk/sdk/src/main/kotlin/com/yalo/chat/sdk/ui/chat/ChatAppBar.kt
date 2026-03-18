// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

// Mirrors Flutter's ChatAppBar:
//  - chatIconImage avatar in the title row (when theme.chatIconImage is non-null)
//  - onShopPressed / onCartPressed as icon buttons in actions (when non-null)
@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun ChatAppBar(
    title: String,
    onBack: (() -> Unit)? = null,
    onShopPressed: (() -> Unit)? = null,
    onCartPressed: (() -> Unit)? = null,
) {
    val theme = LocalChatTheme.current
    TopAppBar(
        title = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (theme.chatIconImage != null) {
                    AsyncImage(
                        model = theme.chatIconImage,
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .size(32.dp)
                            .clip(CircleShape),
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                }
                Text(text = title)
            }
        },
        navigationIcon = {
            if (onBack != null) {
                IconButton(onClick = onBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                }
            }
        },
        actions = {
            if (onShopPressed != null) {
                IconButton(onClick = onShopPressed) {
                    Icon(theme.shopIcon, contentDescription = "Shop", tint = theme.actionIconColor)
                }
            }
            if (onCartPressed != null) {
                IconButton(onClick = onCartPressed) {
                    Icon(theme.cartIcon, contentDescription = "Cart", tint = theme.actionIconColor)
                }
            }
        },
        colors = TopAppBarDefaults.topAppBarColors(containerColor = theme.appBarBackgroundColor),
    )
}

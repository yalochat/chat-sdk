// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

// Port of flutter-sdk/lib/src/ui/chat/widgets/message_list/numeric_text_field.dart
// Simplified to icon buttons + display text; direct text editing omitted for now.

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

@Composable
internal fun ProductQuantityStepper(
    value: Double,
    unitName: String,
    onAdd: () -> Unit,
    onRemove: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val theme = LocalChatTheme.current
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = modifier,
    ) {
        IconButton(onClick = onRemove) {
            Icon(
                imageVector = theme.removeIcon,
                contentDescription = "Remove",
                tint = theme.numericControlIconColor,
            )
        }
        Text(
            text = "${formatQuantity(value)} $unitName",
            modifier = Modifier.padding(horizontal = 4.dp),
        )
        IconButton(onClick = onAdd) {
            Icon(
                imageVector = theme.addIcon,
                contentDescription = "Add",
                tint = theme.numericControlIconColor,
            )
        }
    }
}

// Formats a double quantity: shows integer if whole number, otherwise shows decimal.
// Shared by ProductCard.kt — kept internal so it's visible within the package.
internal fun formatQuantity(value: Double): String =
    if (value == kotlin.math.floor(value)) value.toLong().toString() else value.toString()

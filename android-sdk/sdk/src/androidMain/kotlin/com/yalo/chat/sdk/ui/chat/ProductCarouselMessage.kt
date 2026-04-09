// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

// Port of flutter-sdk/lib/src/ui/chat/widgets/message_list/assistant_product_message.dart
// with direction == Axis.horizontal.
//
// Renders a horizontal LazyRow of product cards (ProductVerticalCard: image top, details below).
// Supports expand/collapse with a "Show more" / "Show less" button at the end of the row,
// mirroring Flutter's horizontal ExpandButton behaviour.

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

private const val CAROUSEL_CARD_WIDTH_DP = 180

@Composable
internal fun ProductCarouselMessage(
    message: ChatMessage,
    onEvent: (MessagesEvent) -> Unit,
) {
    val theme = LocalChatTheme.current
    val products = message.products
    val expand = message.expand
    val messageId = message.id ?: return

    val visibleProducts = if (expand) products else products.take(3)
    val showToggle = products.size > 3

    LazyRow {
        items(visibleProducts, key = { it.sku }) { product ->
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = theme.cardBackgroundColor,
                border = BorderStroke(1.dp, theme.cardBorderColor),
                modifier = Modifier
                    .width(CAROUSEL_CARD_WIDTH_DP.dp)
                    .padding(end = 8.dp),
            ) {
                Column(modifier = Modifier.padding(12.dp)) {
                    ProductVerticalCard(
                        message = message,
                        product = product,
                        onAddUnit = {
                            onEvent(
                                MessagesEvent.ChatUpdateProductQuantity(
                                    messageId = messageId,
                                    productSku = product.sku,
                                    unitType = UnitType.UNIT,
                                    quantity = product.unitsAdded + product.unitStep,
                                )
                            )
                        },
                        onRemoveUnit = {
                            onEvent(
                                MessagesEvent.ChatUpdateProductQuantity(
                                    messageId = messageId,
                                    productSku = product.sku,
                                    unitType = UnitType.UNIT,
                                    quantity = (product.unitsAdded - product.unitStep).coerceAtLeast(0.0),
                                )
                            )
                        },
                        onAddSubunit = {
                            onEvent(
                                MessagesEvent.ChatUpdateProductQuantity(
                                    messageId = messageId,
                                    productSku = product.sku,
                                    unitType = UnitType.SUBUNIT,
                                    quantity = product.subunitsAdded + product.subunitStep,
                                )
                            )
                        },
                        onRemoveSubunit = {
                            onEvent(
                                MessagesEvent.ChatUpdateProductQuantity(
                                    messageId = messageId,
                                    productSku = product.sku,
                                    unitType = UnitType.SUBUNIT,
                                    quantity = (product.subunitsAdded - product.subunitStep).coerceAtLeast(0.0),
                                )
                            )
                        },
                    )
                }
            }
        }

        if (showToggle) {
            item {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.padding(horizontal = 8.dp),
                ) {
                    TextButton(
                        onClick = { onEvent(MessagesEvent.ChatToggleMessageExpand(messageId)) },
                    ) {
                        Text(
                            text = if (expand) "Show less" else "Show more",
                            style = theme.expandControlsStyle,
                        )
                    }
                }
            }
        }
    }
}

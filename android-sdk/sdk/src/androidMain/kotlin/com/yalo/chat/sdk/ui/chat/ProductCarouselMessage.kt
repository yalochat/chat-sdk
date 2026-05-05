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
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.model.Product
import com.yalo.chat.sdk.ui.theme.ChatTheme
import com.yalo.chat.sdk.ui.theme.ChatThemeProvider
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

private const val COLLAPSED_MAX_ITEMS = 3

@Composable
internal fun ProductCarouselMessage(
    message: ChatMessage,
    onEvent: (MessagesEvent) -> Unit,
) {
    val theme = LocalChatTheme.current
    val products = message.products
    val expand = message.expand
    val messageId = message.id ?: return
    val cardWidthDp = (LocalConfiguration.current.screenWidthDp * 0.6f).toInt()

    val visibleProducts = if (expand) products else products.take(COLLAPSED_MAX_ITEMS)
    val showToggle = products.size > COLLAPSED_MAX_ITEMS

    LazyRow {
        items(visibleProducts, key = { it.sku }) { product ->
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = theme.cardBackgroundColor,
                border = BorderStroke(1.dp, theme.cardBorderColor),
                modifier = Modifier
                    .width(cardWidthDp.dp)
                    .padding(end = 8.dp),
            ) {
                Column(modifier = Modifier.padding(12.dp)) {
                    ProductVerticalCard(
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

// ── Previews ──────────────────────────────────────────────────────────────────

private val CAROUSEL_PREVIEW_PRODUCTS = listOf(
    Product(sku = "c1", name = "Organic Milk 1L", price = 25.50, imagesUrl = emptyList(), unitName = "unit", unitStep = 1.0),
    Product(sku = "c2", name = "Free-range Eggs x12", price = 42.00, salePrice = 38.00, imagesUrl = emptyList(), unitName = "unit", unitStep = 1.0),
    Product(sku = "c3", name = "Whole Wheat Bread 600g", price = 18.00, imagesUrl = emptyList(), unitName = "unit", unitStep = 1.0),
    Product(sku = "c4", name = "Greek Yogurt 500g", price = 30.00, imagesUrl = emptyList(), unitName = "unit", unitStep = 1.0),
)

@Preview(showBackground = true, name = "Carousel (collapsed)")
@Composable
private fun ProductCarouselMessagePreview() {
    ChatThemeProvider(ChatTheme.Default) {
        ProductCarouselMessage(
            message = ChatMessage(
                id = 2L,
                role = MessageRole.AGENT,
                type = MessageType.ProductCarousel,
                status = MessageStatus.DELIVERED,
                products = CAROUSEL_PREVIEW_PRODUCTS,
                expand = false,
            ),
            onEvent = {},
        )
    }
}

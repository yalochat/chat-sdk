// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

// Renders a collapsible vertical list of product cards. Shows at most
// COLLAPSED_MAX_ITEMS products before offering a "Show more" expand button.
// When expanded, a "Show less" button appears at the bottom.

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
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
internal fun ProductListMessage(
    message: ChatMessage,
    onEvent: (MessagesEvent) -> Unit,
) {
    val theme = LocalChatTheme.current
    val products = message.products
    val expand = message.expand
    val messageId = message.id ?: return

    Column(modifier = Modifier.fillMaxWidth()) {
        val visibleCount = if (expand) products.size else minOf(COLLAPSED_MAX_ITEMS, products.size)

        for (index in 0 until visibleCount) {
            val product = products[index]
            Spacer(Modifier.height(8.dp))
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = theme.cardBackgroundColor,
                border = BorderStroke(1.dp, theme.cardBorderColor),
                modifier = Modifier.fillMaxWidth(),
            ) {
                Column(modifier = Modifier.padding(12.dp)) {
                    ProductHorizontalCard(
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

        // Expand / collapse button — only shown when products exceed the collapsed limit.
        if (products.size > COLLAPSED_MAX_ITEMS) {
            TextButton(
                onClick = { onEvent(MessagesEvent.ChatToggleMessageExpand(messageId)) },
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(
                    text = if (expand) "Show less" else "Show more",
                    style = theme.expandControlsStyle,
                )
            }
        }
    }
}

// ── Previews ──────────────────────────────────────────────────────────────────

private val PREVIEW_PRODUCTS = listOf(
    Product(sku = "p1", name = "Organic Milk 1L", price = 25.50, imagesUrl = emptyList(), unitName = "unit", unitStep = 1.0),
    Product(sku = "p2", name = "Free-range Eggs x12", price = 42.00, salePrice = 38.00, imagesUrl = emptyList(), unitName = "unit", unitStep = 1.0),
    Product(sku = "p3", name = "Whole Wheat Bread 600g", price = 18.00, imagesUrl = emptyList(), unitName = "unit", unitStep = 1.0),
    Product(sku = "p4", name = "Greek Yogurt 500g", price = 30.00, imagesUrl = emptyList(), unitName = "unit", unitStep = 1.0),
)

@Preview(showBackground = true, name = "Collapsed (3 visible + Show more)")
@Composable
private fun ProductListMessageCollapsedPreview() {
    ChatThemeProvider(ChatTheme.Default) {
        ProductListMessage(
            message = ChatMessage(
                id = 1L,
                role = MessageRole.AGENT,
                type = MessageType.Product,
                status = MessageStatus.DELIVERED,
                products = PREVIEW_PRODUCTS,
                expand = false,
            ),
            onEvent = {},
        )
    }
}

@Preview(showBackground = true, name = "Expanded (all 4 visible)")
@Composable
private fun ProductListMessageExpandedPreview() {
    ChatThemeProvider(ChatTheme.Default) {
        ProductListMessage(
            message = ChatMessage(
                id = 1L,
                role = MessageRole.AGENT,
                type = MessageType.Product,
                status = MessageStatus.DELIVERED,
                products = PREVIEW_PRODUCTS,
                expand = true,
            ),
            onEvent = {},
        )
    }
}

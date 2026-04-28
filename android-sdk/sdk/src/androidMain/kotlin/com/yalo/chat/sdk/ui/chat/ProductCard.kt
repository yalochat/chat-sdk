// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

// Port of flutter-sdk/lib/src/ui/chat/widgets/message_list/product_horizontal_card.dart
// and product_vertical_card.dart.
//
// ProductHorizontalCard — image left, details right (Row layout).
//   Used by ProductListMessage (vertical list of product messages).
//
// ProductVerticalCard — image top, details below (Column layout).
//   Used by ProductCarouselMessage (horizontal carousel).

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.painter.ColorPainter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.yalo.chat.sdk.domain.model.Product
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

// ── Shared price row ──────────────────────────────────────────────────────────

@Composable
private fun ProductPriceRow(product: Product) {
    val theme = LocalChatTheme.current
    Row(verticalAlignment = androidx.compose.ui.Alignment.CenterVertically) {
        androidx.compose.material3.Icon(
            imageVector = theme.currencyIcon,
            contentDescription = null,
            tint = theme.currencyIconColor,
            modifier = Modifier.size(16.dp),
        )
        val displayPrice = product.salePrice ?: product.price
        Text(
            text = formatPrice(displayPrice),
            style = theme.productPriceStyle,
            modifier = Modifier.padding(start = 2.dp),
        )
        if (product.salePrice != null) {
            Spacer(Modifier.width(4.dp))
            Text(
                text = formatPrice(product.price),
                style = theme.productSalePriceStrikeStyle,
            )
        }
    }
}

// ── Shared image ──────────────────────────────────────────────────────────────

@Composable
private fun ProductImage(
    imagesUrl: List<String>,
    modifier: Modifier = Modifier,
) {
    val theme = LocalChatTheme.current
    AsyncImage(
        model = imagesUrl.firstOrNull(),
        contentDescription = "Product image",
        contentScale = ContentScale.Crop,
        modifier = modifier
            .clip(RoundedCornerShape(8.dp)),
        placeholder = ColorPainter(theme.imagePlaceholderBackgroundColor),
        error = ColorPainter(theme.imagePlaceholderBackgroundColor),
    )
}

// ── ProductHorizontalCard (image left | details right) ────────────────────────
// Used in the vertical product list. Mirrors Flutter's ProductHorizontalCard.

@Composable
internal fun ProductHorizontalCard(
    product: Product,
    onAddUnit: () -> Unit,
    onRemoveUnit: () -> Unit,
    onAddSubunit: () -> Unit,
    onRemoveSubunit: () -> Unit,
) {
    val theme = LocalChatTheme.current
    Row(modifier = Modifier.fillMaxWidth()) {
        ProductImage(
            imagesUrl = product.imagesUrl,
            modifier = Modifier
                .weight(2f)
                .aspectRatio(3f / 4f),
        )
        Spacer(Modifier.width(8.dp))
        Column(
            modifier = Modifier
                .weight(4f)
                .padding(top = 4.dp),
        ) {
            Text(text = product.name, style = theme.productTitleStyle, maxLines = 2)
            val subunitsText = subunitsLabel(product)
            if (subunitsText != null) {
                Text(text = subunitsText, style = theme.productSubunitsStyle)
            }
            ProductPriceRow(product)
            Spacer(Modifier.height(4.dp))
            ProductQuantityStepper(
                value = product.unitsAdded,
                unitName = formatUnit(product.unitsAdded, product.unitName),
                onAdd = onAddUnit,
                onRemove = onRemoveUnit,
            )
            if (subunitsText != null) {
                ProductQuantityStepper(
                    value = product.subunitsAdded,
                    unitName = formatUnit(product.subunitsAdded, product.subunitName ?: ""),
                    onAdd = onAddSubunit,
                    onRemove = onRemoveSubunit,
                )
            }
        }
    }
}

// ── ProductVerticalCard (image top | details below) ───────────────────────────
// Used in the horizontal carousel. Mirrors Flutter's ProductVerticalCard.

@Composable
internal fun ProductVerticalCard(
    product: Product,
    onAddUnit: () -> Unit,
    onRemoveUnit: () -> Unit,
    onAddSubunit: () -> Unit,
    onRemoveSubunit: () -> Unit,
) {
    val theme = LocalChatTheme.current
    Column(modifier = Modifier.fillMaxWidth()) {
        ProductImage(
            imagesUrl = product.imagesUrl,
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(4f / 3f),
        )
        Spacer(Modifier.height(8.dp))
        val subunitsText = subunitsLabel(product)
        ProductPriceRow(product)
        if (subunitsText != null) {
            Text(text = subunitsText, style = theme.productSubunitsStyle)
        }
        Text(text = product.name, style = theme.productTitleStyle, maxLines = 2)
        Spacer(Modifier.height(4.dp))
        ProductQuantityStepper(
            value = product.unitsAdded,
            unitName = formatUnit(product.unitsAdded, product.unitName),
            onAdd = onAddUnit,
            onRemove = onRemoveUnit,
        )
        if (subunitsText != null) {
            ProductQuantityStepper(
                value = product.subunitsAdded,
                unitName = formatUnit(product.subunitsAdded, product.subunitName ?: ""),
                onAdd = onAddSubunit,
                onRemove = onRemoveSubunit,
            )
        }
    }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// Returns the subunits label only when the product has more than 1 subunit and a subunit name.
// Mirrors Flutter: `product.subunits > 1 && product.subunitName != null`.
private fun subunitsLabel(product: Product): String? =
    if (product.subunits > 1.0 && product.subunitName != null) {
        "${formatQuantity(product.subunits)} ${formatUnit(product.subunits, product.subunitName)}"
    } else null

private fun formatPrice(price: Double): String = "%.2f".format(price)

// Mirrors Flutter's BuildContext.formatUnit() in format.dart.
// Resolves ICU plural patterns like "{amount, plural, one {unit} other {units}}"
// to the appropriate singular or plural form based on amount.
// For non-ICU strings the input is returned unchanged.
private fun formatUnit(amount: Double, pattern: String): String {
    val singular = Regex("""one \{([^}]*)\}""").find(pattern)?.groupValues?.get(1)
    val plural = Regex("""other \{([^}]*)\}""").find(pattern)?.groupValues?.get(1)
    return when {
        singular != null && plural != null -> if (amount == 1.0) singular else plural
        else -> pattern
    }
}

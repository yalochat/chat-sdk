// Copyright (c) Yalochat, Inc. All rights reserved.

// Port of android-sdk ProductListMessage.kt.
// Vertical list of ProductHorizontalCard views, collapsed to 3 items with a Show more button.

import SwiftUI
import ChatSdk

private let collapsedMaxItems = 3

struct ProductListView: View {

    let message: ChatMessage
    let isExpanded: Bool
    var onToggleExpand: () -> Void = {}
    var onUpdateQuantity: (String, Bool, Double) -> Void = { _, _, _ in }

    @State private var cardContentWidth: CGFloat = 0

    private var products: [Product] {
        message.products
    }

    var body: some View {
        let visibleProducts = isExpanded ? products : Array(products.prefix(collapsedMaxItems))

        VStack(spacing: 8) {
            ForEach(Array(visibleProducts.enumerated()), id: \.element.sku) { _, product in
                let imageWidth = max(0, (cardContentWidth - 8) / 3)
                ProductHorizontalCard(
                    product: product,
                    imageWidth: imageWidth > 0 ? imageWidth : 80,
                    onAddUnit: {
                        onUpdateQuantity(product.sku, false, product.unitsAdded + product.unitStep)
                    },
                    onRemoveUnit: {
                        onUpdateQuantity(product.sku, false, max(product.unitsAdded - product.unitStep, 0))
                    },
                    onAddSubunit: {
                        onUpdateQuantity(product.sku, true, product.subunitsAdded + product.subunitStep)
                    },
                    onRemoveSubunit: {
                        onUpdateQuantity(product.sku, true, max(product.subunitsAdded - product.subunitStep, 0))
                    }
                )
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }

            if products.count > collapsedMaxItems {
                Button(action: onToggleExpand) {
                    Text(isExpanded ? "Show less" : "Show more")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { cardContentWidth = geo.size.width - 24 }
                    .onChange(of: geo.size.width) { cardContentWidth = $0 - 24 }
            }
        )
    }
}

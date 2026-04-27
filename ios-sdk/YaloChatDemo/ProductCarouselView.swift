// Copyright (c) Yalochat, Inc. All rights reserved.

// Port of android-sdk ProductCarouselMessage.kt.
// Horizontal scroll of ProductVerticalCard views, collapsed to 3 with a Show more item.

import SwiftUI
import ChatSdk

private let collapsedMaxItems = 3
private let cardWidth: CGFloat = 180

struct ProductCarouselView: View {

    let message: ChatMessage
    let isExpanded: Bool
    var onToggleExpand: () -> Void = {}
    var onUpdateQuantity: (String, Bool, Double) -> Void = { _, _, _ in }

    private var products: [Product] {
        message.products
    }

    var body: some View {
        let visibleProducts = isExpanded ? products : Array(products.prefix(collapsedMaxItems))
        let showToggle = products.count > collapsedMaxItems

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(Array(visibleProducts.enumerated()), id: \.element.sku) { _, product in
                    ProductVerticalCard(
                        product: product,
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
                    .frame(width: cardWidth)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }

                if showToggle {
                    Button(action: onToggleExpand) {
                        Text(isExpanded ? "Show less" : "Show more")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                            .frame(width: 80)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

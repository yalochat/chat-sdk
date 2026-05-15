// Copyright (c) Yalochat, Inc. All rights reserved.

// Horizontal scroll of ProductVerticalCard views, collapsed to 3 with a Show more item.

import SwiftUI
import ChatSdk

private let collapsedMaxItems = 3

struct ProductCarouselView: View {

    let message: ChatMessage
    let isExpanded: Bool
    var onToggleExpand: () -> Void = {}
    var onUpdateQuantity: (String, Bool, Double) -> Void = { _, _, _ in }

    @State private var containerWidth: CGFloat = 0
    @Environment(\.chatTheme) private var theme

    private var products: [Product] {
        message.products
    }

    private var cardWidth: CGFloat { containerWidth > 0 ? containerWidth * 0.6 : 180 }

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
                    .background(theme.cardBackgroundColor)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.cardBorderColor, lineWidth: 1)
                    )
                }

                if showToggle {
                    Button(action: onToggleExpand) {
                        Text(isExpanded ? "Show less" : "Show more")
                            .font(.subheadline)
                            .foregroundColor(theme.expandControlColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                            .frame(width: 80)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { containerWidth = geo.size.width }
                    .onChange(of: geo.size.width) { newValue in containerWidth = newValue }
            }
        )
    }
}

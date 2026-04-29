// Copyright (c) Yalochat, Inc. All rights reserved.

// Port of android-sdk ProductCard.kt.
//
// ProductHorizontalCard — image left, details right. Used in the vertical product list.
// ProductVerticalCard   — image top, details below. Used in the horizontal carousel.

import SwiftUI
import ChatSdk

// MARK: - Horizontal card (product list)

struct ProductHorizontalCard: View {

    let product: Product
    var onAddUnit: () -> Void = {}
    var onRemoveUnit: () -> Void = {}
    var onAddSubunit: () -> Void = {}
    var onRemoveSubunit: () -> Void = {}

    private var hasSubunits: Bool {
        product.subunits > 1.0 && product.subunitName != nil
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            ProductImage(urlString: product.imagesUrl.first)
                .frame(width: 80, height: 100)
                .clipped()
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                if hasSubunits, let subunitName = product.subunitName {
                    Text("\(formatQuantity(product.subunits)) \(formatIcuUnit(product.subunits, subunitName))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                ProductPriceRow(product: product)

                ProductQuantityStepper(
                    value: product.unitsAdded,
                    unitName: formatIcuUnit(product.unitsAdded, product.unitName),
                    onAdd: onAddUnit,
                    onRemove: onRemoveUnit
                )

                if hasSubunits, let subunitName = product.subunitName {
                    ProductQuantityStepper(
                        value: product.subunitsAdded,
                        unitName: formatIcuUnit(product.subunits, subunitName),
                        onAdd: onAddSubunit,
                        onRemove: onRemoveSubunit
                    )
                }
            }
        }
    }
}

// MARK: - Vertical card (carousel)

struct ProductVerticalCard: View {

    let product: Product
    var onAddUnit: () -> Void = {}
    var onRemoveUnit: () -> Void = {}
    var onAddSubunit: () -> Void = {}
    var onRemoveSubunit: () -> Void = {}

    private var hasSubunits: Bool {
        product.subunits > 1.0 && product.subunitName != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ProductImage(urlString: product.imagesUrl.first)
                .frame(maxWidth: .infinity)
                .aspectRatio(4 / 3, contentMode: .fill)
                .clipped()
                .cornerRadius(8)

            ProductPriceRow(product: product)

            if hasSubunits, let subunitName = product.subunitName {
                Text("\(formatQuantity(product.subunits)) \(formatIcuUnit(product.subunits, subunitName))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(product.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            ProductQuantityStepper(
                value: product.unitsAdded,
                unitName: formatIcuUnit(product.unitsAdded, product.unitName),
                onAdd: onAddUnit,
                onRemove: onRemoveUnit
            )

            if hasSubunits, let subunitName = product.subunitName {
                ProductQuantityStepper(
                    value: product.subunitsAdded,
                    unitName: formatIcuUnit(product.subunits, subunitName),
                    onAdd: onAddSubunit,
                    onRemove: onRemoveSubunit
                )
            }
        }
    }
}

// MARK: - Shared helpers

private struct ProductPriceRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: 4) {
            let salePrice = product.salePrice?.doubleValue
            let displayPrice = salePrice ?? product.price
            Text(formatPrice(displayPrice))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
            if salePrice != nil {
                Text(formatPrice(product.price))
                    .font(.caption)
                    .strikethrough()
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct ProductImage: View {
    let urlString: String?

    var body: some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Color(.systemGray5)
                    }
                }
            } else {
                Color(.systemGray5)
            }
        }
    }
}

private func formatPrice(_ value: Double) -> String {
    String(format: "%.2f", value)
}

private func formatQuantity(_ value: Double) -> String {
    value == value.rounded(.towardZero) && !value.isInfinite
        ? String(Int64(value))
        : String(value)
}

// Mirrors Flutter format.dart formatUnit() — resolves ICU plural patterns.
// Handles: {amount, plural, =1 {caja} other {cajas}} and plain strings.
// Matching priority: exact (=N) → CLDR keyword (zero/one/other) → "other" → original.
private func formatIcuUnit(_ amount: Double, _ pattern: String) -> String {
    guard pattern.contains("{") else { return pattern }
    let amountInt = Int(amount.rounded())
    // Extract cases string from {varName, plural, <cases>}
    let outerRe = try? NSRegularExpression(
        pattern: #"\{[^,]+,\s*plural\s*,\s*(.*)\}$"#,
        options: [.dotMatchesLineSeparators]
    )
    let ns = pattern as NSString
    guard let match = outerRe?.firstMatch(in: pattern, range: NSRange(location: 0, length: ns.length)),
          let casesNS = Range(match.range(at: 1), in: pattern) else { return pattern }
    let casesStr = String(pattern[casesNS])
    // Parse individual cases: "=1 {caja} other {cajas}"
    let caseRe = try? NSRegularExpression(pattern: #"(\S+)\s*\{([^}]*)\}"#)
    var cases: [String: String] = [:]
    caseRe?.enumerateMatches(in: casesStr, range: NSRange(casesStr.startIndex..., in: casesStr)) { m, _, _ in
        guard let m,
              let k = Range(m.range(at: 1), in: casesStr),
              let v = Range(m.range(at: 2), in: casesStr) else { return }
        cases[String(casesStr[k])] = String(casesStr[v])
    }
    let cldr = amountInt == 0 ? "zero" : amountInt == 1 ? "one" : "other"
    return cases["=\(amountInt)"] ?? cases[cldr] ?? cases["other"] ?? pattern
}

// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

struct ProductQuantityStepper: View {

    let value: Double
    let unitName: String
    var onAdd: () -> Void = {}
    var onRemove: () -> Void = {}

    @Environment(\.chatTheme) private var theme

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onRemove) {
                Image(systemName: theme.removeIconName)
                    .font(.caption)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .foregroundColor(value > 0 ? theme.numericControlIconColor : theme.messageFooterColor)
            .disabled(value <= 0)

            Text("\(formatQuantity(value)) \(unitName)")
                .font(.caption)
                .padding(.horizontal, 4)

            Button(action: onAdd) {
                Image(systemName: theme.addIconName)
                    .font(.caption)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .foregroundColor(theme.numericControlIconColor)
        }
    }
}

private func formatQuantity(_ value: Double) -> String {
    value == value.rounded(.towardZero) && !value.isInfinite
        ? String(Int64(value))
        : String(value)
}

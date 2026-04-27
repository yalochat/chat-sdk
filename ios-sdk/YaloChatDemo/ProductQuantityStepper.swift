// Copyright (c) Yalochat, Inc. All rights reserved.

// Port of android-sdk ProductQuantityStepper.kt.

import SwiftUI

struct ProductQuantityStepper: View {

    let value: Double
    let unitName: String
    var onAdd: () -> Void = {}
    var onRemove: () -> Void = {}

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onRemove) {
                Image(systemName: "minus")
                    .font(.caption)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .foregroundColor(value > 0 ? .accentColor : Color(.systemGray4))
            .disabled(value <= 0)

            Text("\(formatQuantity(value)) \(unitName)")
                .font(.caption)
                .padding(.horizontal, 4)

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.caption)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
        }
    }
}

func formatQuantity(_ value: Double) -> String {
    value == value.rounded(.towardZero) && !value.isInfinite
        ? String(Int64(value))
        : String(value)
}

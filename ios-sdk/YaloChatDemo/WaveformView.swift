// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

// Bar-chart waveform mirroring Flutter WaveformPainter.
// Each amplitude is in dBFS (–∞…0). Bar height = max(5 %, 10^(dBFS/20)) × maxHeight.
// Bars occupy 80 % of available width; remaining 20 % is distributed as inter-bar gaps.
struct WaveformView: View {

    let amplitudes: [Double]
    let color: Color

    var body: some View {
        Canvas { context, size in
            let count = max(1, amplitudes.count)
            let barW = size.width * 0.8 / CGFloat(count)
            let gap = count > 1 ? size.width * 0.2 / CGFloat(count - 1) : 0

            for (i, dBFS) in amplitudes.enumerated() {
                let linear = pow(10.0, dBFS / 20.0)
                let fraction = max(0.05, min(1.0, linear))
                let bh = size.height * fraction
                let x = CGFloat(i) * (barW + gap)
                let y = (size.height - bh) / 2
                let rect = CGRect(x: x, y: y, width: max(barW, 1), height: bh)
                context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(color))
            }
        }
    }
}

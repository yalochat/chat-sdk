// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// A rectangle with each corner rounded on its own. A radius larger than half
/// the shorter side is capped there, so `.capsule` rounds the ends fully.
public struct ChatShape: InsettableShape, Sendable, Equatable {
    public var topLeading: CGFloat
    public var topTrailing: CGFloat
    public var bottomTrailing: CGFloat
    public var bottomLeading: CGFloat
    private var inset: CGFloat = 0

    /// Fully rounded ends, whatever the height.
    public static let capsule: ChatShape = ChatShape(radius: .infinity)

    public init(radius: CGFloat) {
        self.init(topLeading: radius, topTrailing: radius, bottomTrailing: radius, bottomLeading: radius)
    }

    public init(
        topLeading: CGFloat = 0,
        topTrailing: CGFloat = 0,
        bottomTrailing: CGFloat = 0,
        bottomLeading: CGFloat = 0
    ) {
        self.topLeading = topLeading
        self.topTrailing = topTrailing
        self.bottomTrailing = bottomTrailing
        self.bottomLeading = bottomLeading
    }

    public func path(in rect: CGRect) -> Path {
        let frame: CGRect = rect.insetBy(dx: inset, dy: inset)
        let limit: CGFloat = max(min(frame.width, frame.height) / 2, 0)
        let radius: (CGFloat) -> CGFloat = { corner in
            min(max(corner - inset, 0), limit)
        }
        let topLeft: CGFloat = radius(topLeading)
        let topRight: CGFloat = radius(topTrailing)
        let bottomRight: CGFloat = radius(bottomTrailing)
        let bottomLeft: CGFloat = radius(bottomLeading)
        var path: Path = Path()
        path.move(to: CGPoint(x: frame.minX + topLeft, y: frame.minY))
        path.addLine(to: CGPoint(x: frame.maxX - topRight, y: frame.minY))
        path.addArc(
            center: CGPoint(x: frame.maxX - topRight, y: frame.minY + topRight),
            radius: topRight,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY - bottomRight))
        path.addArc(
            center: CGPoint(x: frame.maxX - bottomRight, y: frame.maxY - bottomRight),
            radius: bottomRight,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: frame.minX + bottomLeft, y: frame.maxY))
        path.addArc(
            center: CGPoint(x: frame.minX + bottomLeft, y: frame.maxY - bottomLeft),
            radius: bottomLeft,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: frame.minX, y: frame.minY + topLeft))
        path.addArc(
            center: CGPoint(x: frame.minX + topLeft, y: frame.minY + topLeft),
            radius: topLeft,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }

    public func inset(by amount: CGFloat) -> ChatShape {
        var shape: ChatShape = self
        shape.inset += amount
        return shape
    }
}

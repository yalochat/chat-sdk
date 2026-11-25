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
    private var tail: CGSize = .zero
    private var tailAtTrailing: Bool = false

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
        let outer: CGRect = rect.insetBy(dx: inset, dy: inset)
        let frame: CGRect = CGRect(
            x: outer.minX,
            y: outer.minY,
            width: outer.width,
            height: max(outer.height - tail.height, 0)
        )
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
        // The tail hangs under the bottom edge where the rounding of its corner ends.
        if tail.width > 0, tail.height > 0 {
            // A short bubble gets a narrower tail, never wider than its straight bottom edge.
            let width: CGFloat = min(tail.width, max(frame.width - bottomLeft - bottomRight, 0))
            if tailAtTrailing {
                let edge: CGFloat = frame.maxX - bottomRight
                path.addLine(to: CGPoint(x: edge, y: outer.maxY))
                path.addLine(to: CGPoint(x: edge - width, y: frame.maxY))
            } else {
                let edge: CGFloat = frame.minX + bottomLeft
                path.addLine(to: CGPoint(x: edge + width, y: frame.maxY))
                path.addLine(to: CGPoint(x: edge, y: outer.maxY))
                path.addLine(to: CGPoint(x: edge, y: frame.maxY))
            }
        }
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

    /// This shape with a triangle of `size` under its bottom edge, on the trailing side when `atTrailing`.
    /// The bottom `size.height` of the rect it is drawn in is left for the triangle.
    func withTail(_ size: CGSize, atTrailing: Bool) -> ChatShape {
        var shape: ChatShape = self
        shape.tail = size
        shape.tailAtTrailing = atTrailing
        return shape
    }

    public func inset(by amount: CGFloat) -> ChatShape {
        var shape: ChatShape = self
        shape.inset += amount
        return shape
    }
}

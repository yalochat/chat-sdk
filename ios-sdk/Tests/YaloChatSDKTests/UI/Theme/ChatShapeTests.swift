// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import Testing
@testable import YaloChatSDK

struct ChatShapeTests {
    private let rect: CGRect = CGRect(x: 0, y: 0, width: 200, height: 40)
    private let topLeftCorner: CGPoint = CGPoint(x: 1, y: 1)
    private let bottomRightCorner: CGPoint = CGPoint(x: 199, y: 39)

    @Test func squareCornersCoverTheWholeRectangle() {
        let path: Path = ChatShape(radius: 0).path(in: rect)

        #expect(path.boundingRect == rect)
        #expect(path.contains(topLeftCorner))
    }

    @Test func roundsOnlyTheCornersItNames() {
        let path: Path = ChatShape(topLeading: 12).path(in: rect)

        #expect(!path.contains(topLeftCorner))
        #expect(path.contains(bottomRightCorner))
    }

    @Test func capsuleRoundsTheEndsFully() {
        let path: Path = ChatShape.capsule.path(in: rect)

        #expect(path.boundingRect == rect)
        #expect(!path.contains(CGPoint(x: 2, y: 2)))
        #expect(path.contains(CGPoint(x: 20, y: 20)))
    }

    @Test func insettingShrinksTheShape() {
        let path: Path = ChatShape(radius: 8).inset(by: 2).path(in: rect)

        #expect(path.boundingRect == rect.insetBy(dx: 2, dy: 2))
    }

    @Test func aTrailingTailHangsUnderTheBottomTrailingCorner() {
        let tall: CGRect = CGRect(x: 0, y: 0, width: 200, height: 64)
        let path: Path = ChatShape(radius: 16).withTail(CGSize(width: 48, height: 24), atTrailing: true).path(in: tall)

        #expect(path.contains(CGPoint(x: 182, y: 60)))
        #expect(!path.contains(CGPoint(x: 18, y: 60)))
        #expect(path.contains(CGPoint(x: 100, y: 30)))
    }

    @Test func aLeadingTailHangsUnderTheBottomLeadingCorner() {
        let tall: CGRect = CGRect(x: 0, y: 0, width: 200, height: 64)
        let path: Path = ChatShape(radius: 16).withTail(CGSize(width: 48, height: 24), atTrailing: false).path(in: tall)

        #expect(path.contains(CGPoint(x: 18, y: 60)))
        #expect(!path.contains(CGPoint(x: 182, y: 60)))
    }

    @Test func aTailIsNeverWiderThanTheStraightBottomEdge() {
        let narrow: CGRect = CGRect(x: 0, y: 0, width: 60, height: 64)
        let path: Path = ChatShape(radius: 16).withTail(CGSize(width: 48, height: 24), atTrailing: true).path(in: narrow)

        #expect(path.boundingRect.minX == 0)
        #expect(!path.contains(CGPoint(x: 15, y: 41)))
    }
}

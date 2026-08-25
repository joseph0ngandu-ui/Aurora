//
//  LeafIcon.swift
// Aurora
//
//  Minimalist leaf silhouette icon
//

import SwiftUI

struct LeafIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // Start at bottom center (stem)
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.95))

        // Curve to left side (upper left curve)
        path.addCurve(
            to: CGPoint(x: width * 0.1, y: height * 0.3),
            control1: CGPoint(x: width * 0.3, y: height * 0.8),
            control2: CGPoint(x: width * 0.05, y: height * 0.5)
        )

        // Curve to top point
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.05),
            control1: CGPoint(x: width * 0.15, y: height * 0.15),
            control2: CGPoint(x: width * 0.3, y: height * 0.05)
        )

        // Curve to right side (upper right curve)
        path.addCurve(
            to: CGPoint(x: width * 0.9, y: height * 0.3),
            control1: CGPoint(x: width * 0.7, y: height * 0.05),
            control2: CGPoint(x: width * 0.85, y: height * 0.15)
        )

        // Curve back to bottom center (right side)
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.95),
            control1: CGPoint(x: width * 0.95, y: height * 0.5),
            control2: CGPoint(x: width * 0.7, y: height * 0.8)
        )

        path.closeSubpath()

        return path
    }
}

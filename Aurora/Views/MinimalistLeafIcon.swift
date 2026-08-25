//
//  MinimalistLeafIcon.swift
// Aurora
//
//  A simple minimalist leaf icon used in the Eden branding.
//

import SwiftUI

struct MinimalistLeafIcon: View {
    let size: CGFloat
    let color: Color

    init(size: CGFloat, color: Color) {
        self.size = size
        self.color = color
    }

    var body: some View {
        LeafShape()
            .stroke(color, lineWidth: max(1.5, size * 0.08))
            .frame(width: size, height: size)
            .overlay(
                LeafVeinShape()
                    .stroke(color.opacity(0.9), lineWidth: max(1.0, size * 0.06))
            )
            .accessibilityLabel(Text("Leaf"))
    }
}

// A simple stylized leaf outline
private struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Outline: a teardrop/leaf-like bezier
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w * 0.05, y: h * 0.55),
            control1: CGPoint(x: w * 0.25, y: h * 0.05),
            control2: CGPoint(x: w * 0.05, y: h * 0.25)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w * 0.05, y: h * 0.85),
            control2: CGPoint(x: w * 0.25, y: h * 0.98)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.95, y: h * 0.55),
            control1: CGPoint(x: w * 0.75, y: h * 0.98),
            control2: CGPoint(x: w * 0.95, y: h * 0.85)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: w * 0.95, y: h * 0.25),
            control2: CGPoint(x: w * 0.75, y: h * 0.05)
        )
        return path
    }
}

// A single central vein curve
private struct LeafVeinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.5, y: h * 0.05))
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.95),
            control1: CGPoint(x: w * 0.35, y: h * 0.4),
            control2: CGPoint(x: w * 0.65, y: h * 0.6)
        )
        return path
    }
}

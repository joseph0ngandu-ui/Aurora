//
//  EquityCurveView.swift
// Aurora - Redesigned
//
//  Equity curve chart component with gradient and smooth path
//
//

import SwiftUI

struct EquityCurveView: View {
    @EnvironmentObject var botManager: BotManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Text("Equity Curve")
                    .font(AuroraTypography.h6)
                    .foregroundColor(
                        colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary)

                Spacer()

                Text("Last 30 Days")
                    .font(AuroraTypography.labelSmall)
                    .foregroundColor(
                        colorScheme == .dark ? DarkMode.textTertiary : LightMode.textTertiary
                    )
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    )
            }

            // Chart
            GeometryReader { geometry in
                if botManager.equityCurve.isEmpty {
                    emptyState(geometry: geometry)
                } else {
                    chartPath(geometry: geometry)
                }
            }
        }
    }

    private func chartPath(geometry: GeometryProxy) -> some View {
        let points = botManager.equityCurve
        let values = points.map { $0.value }
        let maxValue = values.max() ?? 1
        let minValue = values.min() ?? 0
        let range = max(maxValue - minValue, 1.0)  // Avoid division by zero

        let width = geometry.size.width
        let height = geometry.size.height
        let stepX = width / CGFloat(max(points.count - 1, 1))

        return ZStack {
            // Gradient Fill
            Path { path in
                path.move(to: CGPoint(x: 0, y: height))

                for (index, value) in values.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = height - (CGFloat(value - minValue) / CGFloat(range)) * height
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                path.addLine(to: CGPoint(x: width, y: height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [
                        AuroraColors.lime.opacity(0.2),
                        AuroraColors.lime.opacity(0.0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Line Stroke
            Path { path in
                for (index, value) in values.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = height - (CGFloat(value - minValue) / CGFloat(range)) * height

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [AuroraColors.lime, AuroraColors.mint],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
            .shadow(color: AuroraColors.lime.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }

    private func emptyState(geometry: GeometryProxy) -> some View {
        ZStack {
            // Placeholder Line
            Path { path in
                path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
            }
            .stroke(
                Color.gray.opacity(0.2),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 5])
            )

            Text("No data available")
                .font(AuroraTypography.bodySmall)
                .foregroundColor(
                    colorScheme == .dark ? DarkMode.textTertiary : LightMode.textTertiary)
        }
    }
}

#Preview {
    EquityCurveView()
        .environmentObject(BotManager())
        .padding()
        .background(Color.black)
}

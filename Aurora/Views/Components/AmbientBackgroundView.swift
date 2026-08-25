//
//  AmbientBackgroundView.swift
// Aurora
//
//  A subtle, animated background with moving gradient orbs
//  to create a "living" feel for the app.
//  Enhanced with customizable color schemes per page.
//

import SwiftUI

enum AmbientColorScheme {
    case overview  // Lime, Forest, Gold (default)
    case positions  // Mint, Cyan, Blue
    case analytics  // Purple, Indigo, Pink
    case strategies  // Orange, Red, Yellow
    case settings  // Gray, Silver, White

    var colors: (Color, Color, Color) {
        switch self {
        case .overview:
            return (AuroraColors.lime, AuroraColors.forest, AuroraColors.gold)
        case .positions:
            return (AuroraColors.mint, Color.cyan, Color.blue)
        case .analytics:
            return (Color.purple, Color.indigo, Color.pink)
        case .strategies:
            return (Color.orange, Color.red, Color.yellow)
        case .settings:
            return (Color.gray, Color(white: 0.7), Color.white)
        }
    }
}

struct AmbientBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager

    var colorTheme: AmbientColorScheme = .overview

    @State private var animate = false
    @State private var currentColors: (Color, Color, Color)

    init(colorTheme: AmbientColorScheme = .overview) {
        self.colorTheme = colorTheme
        _currentColors = State(initialValue: colorTheme.colors)
    }

    var body: some View {
        ZStack {
            // Base Background
            (colorScheme == .dark ? DarkMode.primary : LightMode.primary)
                .ignoresSafeArea()

            // Orb 1 - Top Left
            Circle()
                .fill(themeManager.currentAccent.opacity(themeManager.glowOpacity * 0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: animate ? -50 : -100, y: animate ? -50 : -100)
                .animation(
                    Animation.easeInOut(duration: 10 / themeManager.animationSpeed).repeatForever(
                        autoreverses: true),
                    value: animate
                )

            // Orb 2 - Bottom Right
            Circle()
                .fill(currentColors.1.opacity(themeManager.glowOpacity * 0.4))
                .frame(width: 350, height: 350)
                .blur(radius: 70)
                .offset(x: animate ? 100 : 50, y: animate ? 100 : 200)
                .animation(
                    Animation.easeInOut(duration: 12 / themeManager.animationSpeed).repeatForever(
                        autoreverses: true),
                    value: animate
                )

            // Orb 3 - Center/Random
            Circle()
                .fill(currentColors.2.opacity(themeManager.glowOpacity * 0.2))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: animate ? -100 : 100, y: animate ? 50 : -50)
                .animation(
                    Animation.easeInOut(duration: 15 / themeManager.animationSpeed).repeatForever(
                        autoreverses: true),
                    value: animate
                )

            // Overlay to smooth everything out
            (colorScheme == .dark ? DarkMode.primary : LightMode.primary)
                .opacity(0.3)
                .ignoresSafeArea()
                .blendMode(.overlay)
        }
        .onAppear {
            animate = true
            // Smoothly transition to the target colors
            withAnimation(.easeInOut(duration: 1.5)) {
                currentColors = colorTheme.colors
            }
        }
        .onChange(of: colorTheme) { _, newTheme in
            // Smooth color transition when theme changes
            withAnimation(.easeInOut(duration: 1.5)) {
                currentColors = newTheme.colors
            }
        }
    }
}

#Preview("Overview") {
    AmbientBackgroundView(colorTheme: .overview)
}

#Preview("Positions") {
    AmbientBackgroundView(colorTheme: .positions)
}

#Preview("Analytics") {
    AmbientBackgroundView(colorTheme: .analytics)
}

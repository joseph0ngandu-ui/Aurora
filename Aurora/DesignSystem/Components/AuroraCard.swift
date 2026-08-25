//
//  AuroraCard.swift
// Aurora - Redesigned
//
//  Reusable glassmorphic card component with elevation and glow
//

import SwiftUI

struct AuroraCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    var elevation: Int = 1
    var glowColor: Color? = nil
    var padding: CGFloat = Spacing.lg
    
    init(
        elevation: Int = 1,
        glowColor: Color? = nil,
        padding: CGFloat = Spacing.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.elevation = elevation
        self.glowColor = glowColor
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(cardBackground)
            .shadow(
                color: shadowColor,
                radius: CGFloat(elevation * 8),
                x: 0,
                y: CGFloat(elevation * 2)
            )
            .if(glowColor != nil && colorScheme == .dark) { view in
                view
                    .shadow(color: glowColor!.opacity(0.3), radius: 20, x: 0, y: 0)
                    .shadow(color: glowColor!.opacity(0.2), radius: 40, x: 0, y: 0)
            }
    }
    
    private var cardBackground: some View {
        ZStack {
            // Base card with neumorphism
            RoundedRectangle(cornerRadius: BorderRadius.xl)
                .fill(colorScheme == .dark ? DarkMode.secondary : LightMode.secondary)
            
            // Glass overlay
            RoundedRectangle(cornerRadius: BorderRadius.xl)
                .fill(colorScheme == .dark ? DarkMode.glass : LightMode.glass)
                .blur(radius: colorScheme == .dark ? DarkMode.glassBlur : LightMode.glassBlur)
            
            // Border
            RoundedRectangle(cornerRadius: BorderRadius.xl)
                .strokeBorder(
                    colorScheme == .dark ? DarkMode.border : LightMode.border,
                    lineWidth: 1
                )
        }
    }
    
    private var shadowColor: Color {
        if colorScheme == .dark {
            return .clear // Use glow instead in dark mode
        } else {
            return LightMode.shadowColorMedium
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AuroraCard(elevation: 1) {
            VStack(spacing: 12) {
                Text("Standard Card")
                    .font(AuroraTypography.h4)
                Text("This is a basic glassmorphic card")
                    .font(AuroraTypography.bodyMedium)
            }
        }
        
        AuroraCard(elevation: 2, glowColor: AuroraColors.lime) {
            VStack(spacing: 12) {
                Text("Card with Glow")
                    .font(AuroraTypography.h4)
                Text("This card has a lime glow effect")
                    .font(AuroraTypography.bodyMedium)
            }
        }
    }
    .padding()
    .background(DarkMode.primary)
}

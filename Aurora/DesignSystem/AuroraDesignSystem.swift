//
//  AuroraDesignSystem.swift
// Aurora
//
//  Complete Design System - Colors, Typography, Spacing, Animations
//  Ultra-modern, bleeding-edge design language
//

import SwiftUI

// MARK: - Colors

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AuroraColors {
    // Primary Brand Colors
    static let lime = Color(hex: "#B3DD62")
    static let gold = Color(hex: "#DDAD71")
    static let forest = Color(hex: "#2C5E54")
    static let mint = Color(hex: "#ABDAC5")
    static let pure = Color(hex: "#FFFFFF")
    
    // Extended Palette
    static let limeGlow = Color(hex: "#B3DD62").opacity(0.3)
    static let goldShimmer = Color(hex: "#DDAD71").opacity(0.2)
    static let forestDeep = Color(hex: "#1A3A32")
    static let mintFresh = Color(hex: "#ABDAC5").opacity(0.15)
}

struct LightMode {
    // Backgrounds
    static let primary = Color(hex: "#FAFBFC")
    static let secondary = Color(hex: "#F4F6F8")
    static let tertiary = Color(hex: "#FFFFFF")
    
    // Text
    static let textPrimary = Color(hex: "#1A1F2E")
    static let textSecondary = Color(hex: "#6B7280")
    static let textTertiary = Color(hex: "#9CA3AF")
    
    // Borders & Dividers
    static let border = Color(hex: "#E5E7EB")
    static let borderSubtle = Color(hex: "#F3F4F6")
    
    // Shadows
    static let shadowColor = Color.black.opacity(0.05)
    static let shadowColorMedium = Color.black.opacity(0.08)
    static let shadowColorStrong = Color.black.opacity(0.12)
    
    // Glass Effect
    static let glass = Color.white.opacity(0.7)
    static let glassBlur: CGFloat = 20
}

struct DarkMode {
    // Backgrounds - Deep, Rich Tones
    static let primary = Color(hex: "#0A0E13")
    static let secondary = Color(hex: "#141922")
    static let tertiary = Color(hex: "#1E2530")
    
    // Text
    static let textPrimary = Color(hex: "#FFFFFF")
    static let textSecondary = Color(hex: "#B8C1CC")
    static let textTertiary = Color(hex: "#6B7280")
    
    // Borders & Dividers
    static let border = Color(hex: "#2D3748")
    static let borderSubtle = Color(hex: "#1E2530")
    
    // Glow Effects
    static let glowLime = AuroraColors.lime.opacity(0.15)
    static let glowGold = AuroraColors.gold.opacity(0.12)
    static let glowMint = AuroraColors.mint.opacity(0.1)
    
    // Glass Effect
    static let glass = Color.white.opacity(0.05)
    static let glassBlur: CGFloat = 30
}

struct SemanticColors {
    // Success States
    static let successPrimary = AuroraColors.lime
    static let successSecondary = AuroraColors.mint
    static let successBackground = AuroraColors.lime.opacity(0.1)
    
    // Error/Loss States
    static let errorPrimary = Color(hex: "#EF4444")
    static let errorSecondary = Color(hex: "#DC2626")
    static let errorBackground = Color(hex: "#EF4444").opacity(0.1)
    
    // Warning States
    static let warningPrimary = AuroraColors.gold
    static let warningSecondary = Color(hex: "#F59E0B")
    static let warningBackground = AuroraColors.gold.opacity(0.1)
    
    // Info States
    static let infoPrimary = Color(hex: "#3B82F6")
    static let infoSecondary = Color(hex: "#60A5FA")
    static let infoBackground = Color(hex: "#3B82F6").opacity(0.1)
    
    // Neutral States
    static let neutral = Color(hex: "#6B7280")
    static let neutralBackground = Color(hex: "#6B7280").opacity(0.1)
}

// MARK: - Typography

struct AuroraTypography {
    // Display (Hero Headlines)
    static let displayLarge = Font.system(size: 64, weight: .bold)
    static let displayMedium = Font.system(size: 48, weight: .bold)
    static let displaySmall = Font.system(size: 36, weight: .semibold)
    
    // Headlines
    static let h1 = Font.system(size: 32, weight: .bold)
    static let h2 = Font.system(size: 28, weight: .bold)
    static let h3 = Font.system(size: 24, weight: .semibold)
    static let h4 = Font.system(size: 20, weight: .semibold)
    static let h5 = Font.system(size: 18, weight: .semibold)
    static let h6 = Font.system(size: 16, weight: .medium)
    
    // Body
    static let bodyLarge = Font.system(size: 16, weight: .regular)
    static let bodyMedium = Font.system(size: 14, weight: .regular)
    static let bodySmall = Font.system(size: 12, weight: .regular)
    
    // Labels
    static let labelLarge = Font.system(size: 14, weight: .medium)
    static let labelMedium = Font.system(size: 12, weight: .medium)
    static let labelSmall = Font.system(size: 10, weight: .medium)
    
    // Monospace (Numbers, Data)
    static let monoLarge = Font.system(size: 48, weight: .semibold).monospacedDigit()
    static let monoMedium = Font.system(size: 32, weight: .semibold).monospacedDigit()
    static let monoSmall = Font.system(size: 16, weight: .medium).monospacedDigit()
}

// MARK: - Spacing

struct Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
    static let xxxxl: CGFloat = 96
}

// MARK: - Border Radius

struct BorderRadius {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let full: CGFloat = 9999
}

// MARK: - Animations

struct AnimationDuration {
    static let instant: Double = 0.1
    static let fast: Double = 0.2
    static let normal: Double = 0.3
    static let slow: Double = 0.5
    static let verySlow: Double = 0.8
}

struct SpringAnimations {
    static let bounce = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let smooth = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let gentle = Animation.spring(response: 0.6, dampingFraction: 0.9)
}

struct EasingCurves {
    static let easeOut = Animation.easeOut(duration: AnimationDuration.normal)
    static let easeIn = Animation.easeIn(duration: AnimationDuration.normal)
    static let easeInOut = Animation.easeInOut(duration: AnimationDuration.normal)
    static let linear = Animation.linear(duration: AnimationDuration.normal)
}

// MARK: - Haptic Feedback

struct HapticFeedback {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Helper Extensions

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

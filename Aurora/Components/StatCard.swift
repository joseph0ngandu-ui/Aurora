//
//  StatCard.swift
// Aurora - Redesigned
//
//  Premium stat card with glassmorphism and animations
//
//

import SwiftUI

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    var subtext: String? = nil
    var trend: Double? = nil
    let color: Color
    
    @State private var isHovered = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header with icon and trend
            HStack {
                iconCircle
                
                Spacer()
                
                if let trend = trend {
                    trendBadge(trend: trend)
                }
            }
            
            // Label
            Text(label)
                .font(AuroraTypography.labelMedium)
                .foregroundColor(colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary)
                .lineLimit(1)
            
            // Value
            Text(value)
                .font(AuroraTypography.monoMedium)
                .foregroundStyle(valueGradient)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // Subtext with fixed height
            Group {
                if let subtext = subtext {
                    Text(subtext)
                        .font(AuroraTypography.bodySmall)
                        .foregroundColor(colorScheme == .dark ? DarkMode.textTertiary : LightMode.textTertiary)
                        .lineLimit(1)
                } else {
                    Text(" ")
                        .font(AuroraTypography.bodySmall)
                }
            }
            .frame(height: 16)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .background(
            GlassCardBackground()
                .shadow(
                    color: colorScheme == .dark ? color.opacity(0.1) : LightMode.shadowColorMedium,
                    radius: isHovered ? 20 : 10,
                    x: 0,
                    y: isHovered ? 8 : 4
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(SpringAnimations.gentle, value: isHovered)
        .onTapGesture {
            withAnimation(SpringAnimations.bounce) {
                isHovered = true
            }
            HapticFeedback.selection()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(SpringAnimations.gentle) {
                    isHovered = false
                }
            }
        }
    }
    
    // MARK: - Icon Circle
    
    private var iconCircle: some View {
        ZStack {
            // Glow effect in dark mode
            if colorScheme == .dark {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .blur(radius: 8)
            }
            
            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.9), color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Trend Badge
    
    private func trendBadge(trend: Double) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.system(size: 10, weight: .bold))
            
            Text("\(abs(trend), specifier: "%.1f")%")
                .font(AuroraTypography.labelSmall)
        }
        .foregroundColor(trend >= 0 ? SemanticColors.successPrimary : SemanticColors.errorPrimary)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(
            Capsule()
                .fill(
                    (trend >= 0 ? SemanticColors.successBackground : SemanticColors.errorBackground)
                )
        )
    }
    
    // MARK: - Value Gradient
    
    private var valueGradient: LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            StatCard(
                icon: "target",
                label: "Win Rate",
                value: "68.5%",
                trend: 2.3,
                color: SemanticColors.successPrimary
            )
            
            StatCard(
                icon: "chart.line.uptrend.xyaxis",
                label: "Total Trades",
                value: "1,247",
                subtext: "This month",
                color: AuroraColors.gold
            )
        }
    }
    .padding()
    .background(Color.black)
}

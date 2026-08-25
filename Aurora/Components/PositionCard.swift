//
//  PositionCard.swift
// Aurora - Redesigned
//
//  Premium position card with glassmorphism and animations
//

import SwiftUI

struct PositionCard: View {
    let position: Position
    
    @State private var appeared = false
    @State private var animatedPnL: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            // Header with symbol, direction, and P&L
            header
            
            // Trading data grid
            dataGrid
            
            // Confidence section
            confidenceSection
        }
        .padding(Spacing.lg)
        .background(cardBackground)
        .scaleEffect(appeared ? 1.0 : 0.95)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(SpringAnimations.smooth.delay(0.1)) {
                appeared = true
            }
            animatePnL()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            // Symbol
            Text(position.symbol)
                .font(AuroraTypography.h3)
                .foregroundColor(colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary)
            
            // Direction badge
            directionBadge
            
            Spacer()
            
            // P&L
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(position.pnl >= 0 ? "+" : "")\(animatedPnL, specifier: "%.2f")")
                    .font(AuroraTypography.monoMedium)
                    .foregroundColor(position.pnl >= 0 ? SemanticColors.successPrimary : SemanticColors.errorPrimary)
                
                Text("P&L")
                    .font(AuroraTypography.labelSmall)
                    .foregroundColor(colorScheme == .dark ? DarkMode.textTertiary : LightMode.textTertiary)
            }
        }
    }
    
    private var directionBadge: some View {
        Text(position.direction)
            .font(AuroraTypography.labelSmall)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: position.direction == "LONG"
                                ? [SemanticColors.successPrimary, SemanticColors.successSecondary]
                                : [SemanticColors.errorPrimary, SemanticColors.errorSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(
                color: (position.direction == "LONG" ? SemanticColors.successPrimary : SemanticColors.errorPrimary).opacity(0.4),
                radius: 8,
                x: 0,
                y: 2
            )
    }
    
    // MARK: - Data Grid
    
    private var dataGrid: some View {
        HStack(spacing: Spacing.lg) {
            dataItem(label: "Entry", value: String(format: "%.2f", position.entry))
            
            Divider()
                .frame(height: 40)
                .background(colorScheme == .dark ? DarkMode.border : LightMode.border)
            
            dataItem(label: "Current", value: String(format: "%.2f", position.current))
            
            Divider()
                .frame(height: 40)
                .background(colorScheme == .dark ? DarkMode.border : LightMode.border)
            
            dataItem(label: "Bars", value: "\(position.bars)/12")
        }
    }
    
    private func dataItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(label)
                .font(AuroraTypography.labelSmall)
                .foregroundColor(colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary)
            
            Text(value)
                .font(AuroraTypography.labelLarge)
                .foregroundColor(colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Confidence Section
    
    private var confidenceSection: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                Image(systemName: "sparkles")
                    .font(AuroraTypography.bodySmall)
                    .foregroundColor(AuroraColors.gold)
                
                Text("AI Confidence")
                    .font(AuroraTypography.labelMedium)
                    .foregroundColor(colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary)
                
                Spacer()
                
                Text("\(Int(position.confidence * 100))%")
                    .font(AuroraTypography.labelLarge)
                    .foregroundColor(colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary)
            }
            
            // Animated progress bar
            AnimatedProgressBar(
                progress: position.confidence,
                colors: [AuroraColors.gold, AuroraColors.lime],
                height: 8
            )
        }
    }
    
    // MARK: - Card Background
    
    private var cardBackground: some View {
        ZStack {
            // Base card
            RoundedRectangle(cornerRadius: BorderRadius.xl)
                .fill(colorScheme == .dark ? DarkMode.secondary : LightMode.secondary)
            
            // Glass overlay
            RoundedRectangle(cornerRadius: BorderRadius.xl)
                .fill(colorScheme == .dark ? DarkMode.glass : LightMode.glass)
                .blur(radius: colorScheme == .dark ? DarkMode.glassBlur : LightMode.glassBlur)
            
            // Border with color based on P&L
            RoundedRectangle(cornerRadius: BorderRadius.xl)
                .strokeBorder(
                    position.pnl >= 0
                        ? SemanticColors.successPrimary.opacity(0.3)
                        : SemanticColors.errorPrimary.opacity(0.3),
                    lineWidth: 1
                )
        }
        .shadow(
            color: colorScheme == .dark ? .clear : LightMode.shadowColorMedium,
            radius: 16,
            x: 0,
            y: 4
        )
        .if(colorScheme == .dark) { view in
            view.shadow(
                color: (position.pnl >= 0 ? SemanticColors.successPrimary : SemanticColors.errorPrimary).opacity(0.2),
                radius: 24,
                x: 0,
                y: 0
            )
        }
    }
    
    // MARK: - Animations
    
    private func animatePnL() {
        let steps = 30
        let startValue = 0.0
        let endValue = position.pnl
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                animatedPnL = startValue + (endValue - startValue) * (Double(i) / Double(steps))
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PositionCard(
            position: Position(
                symbol: "XAUUSD",
                direction: "LONG",
                entry: 1950.34,
                current: 1958.20,
                pnl: 15.72,
                confidence: 0.94,
                bars: 3
            )
        )
        
        PositionCard(
            position: Position(
                symbol: "EURUSD",
                direction: "SHORT",
                entry: 1.0945,
                current: 1.0920,
                pnl: -8.50,
                confidence: 0.78,
                bars: 7
            )
        )
    }
    .padding()
    .background(DarkMode.primary)
}

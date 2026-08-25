//
//  PositionsView.swift
// Aurora
//
//  Active positions monitoring screen with proper type conversion
//

import SwiftUI

struct PositionsView: View {
    @EnvironmentObject var botManager: BotManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Background
            AmbientBackgroundView(colorTheme: .positions)
                .ignoresSafeArea()
                .zIndex(0)

            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.md) {
                    // Header
                    header

                    // Positions list or empty state
                    if botManager.positions.isEmpty {
                        emptyState
                    } else {
                        positionsList
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, Spacing.lg)
            }
            .zIndex(1)

            // Loading Overlay
            if botManager.isLoading {
                LoadingView()
                    .zIndex(2)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Always refresh positions when this tab appears
            Task {
                await botManager.fetchPositions()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Active Positions")
                .font(AuroraTypography.h3)
                .foregroundColor(
                    colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary)

            Spacer()

            HStack(spacing: Spacing.xxs) {
                Text("\(botManager.activePositions)")
                    .font(AuroraTypography.h4)
                    .foregroundColor(SemanticColors.successPrimary)

                Text("open")
                    .font(AuroraTypography.bodyMedium)
                    .foregroundColor(
                        colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Positions List

    private var positionsList: some View {
        VStack(spacing: Spacing.md) {
            ForEach(botManager.positions) { position in
                // Convert PositionResponse to Position for UI
                PositionCard(position: position.toUIPosition())
                    .padding(.horizontal, Spacing.lg)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AuroraColors.forest.opacity(0.2), AuroraColors.mint.opacity(0.1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 50))
                    .foregroundColor(AuroraColors.forest)
            }

            // Text
            VStack(spacing: Spacing.xs) {
                Text("No Active Positions")
                    .font(AuroraTypography.h4)
                    .foregroundColor(
                        colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary)

                Text("When Eden opens positions, they'll appear here")
                    .font(AuroraTypography.bodyMedium)
                    .foregroundColor(
                        colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            // Bot status indicator
            if botManager.isRunning {
                HStack(spacing: Spacing.xs) {
                    PulseIndicator(color: SemanticColors.successPrimary, size: 8)
                    Text("Bot is actively monitoring markets")
                        .font(AuroraTypography.labelMedium)
                        .foregroundColor(
                            colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary)
                }
                .padding(.top, Spacing.md)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - PositionResponse Extension for UI Conversion

extension PositionResponse {
    /// Convert API PositionResponse to UI Position model for display
    func toUIPosition() -> Position {
        return Position(
            symbol: self.symbol,
            direction: self.type == "BUY" || self.type.contains("LONG") ? "LONG" : "SHORT",
            entry: self.openPrice,
            current: self.currentPrice ?? self.openPrice,
            pnl: self.profit ?? 0.0,
            confidence: 0.85,  // Default confidence - can be enhanced with AI confidence from backend
            bars: calculateBars()
        )
    }

    /// Calculate how many bars (candles) the position has been open
    private func calculateBars() -> Int {
        let formatter = ISO8601DateFormatter()
        guard let openDate = formatter.date(from: self.openTime) else {
            return 0
        }

        let timeInterval = Date().timeIntervalSince(openDate)
        let minutes = Int(timeInterval / 60)

        // Assuming 5-minute bars (adjust based on your timeframe)
        return min(minutes / 5, 12)
    }
}

#Preview {
    PositionsView()
        .environmentObject(BotManager())
}

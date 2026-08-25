//
//  RecentTradesView.swift
// Aurora - Redesigned
//
//  Recent trades list component with glassmorphism and animations
//
//

import SwiftUI

struct RecentTradesView: View {
    @EnvironmentObject var botManager: BotManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header is now handled by parent view for better layout control
            // or we can keep it here if we want the card to be self-contained
            
            if botManager.trades.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(botManager.trades.prefix(5).enumerated()), id: \.element.id) { index, trade in
                        TradeRow(trade: trade)
                            .padding(.vertical, Spacing.md)
                            .padding(.horizontal, Spacing.lg)
                            .background(
                                Color.white.opacity(0.03)
                                    .opacity(index % 2 == 0 ? 0 : 1)
                            )
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .animation(
                                SpringAnimations.snappy.delay(Double(index) * 0.05),
                                value: botManager.trades.map(\.id)
                            )
                        
                        if index < min(botManager.trades.count, 5) - 1 {
                            Divider()
                                .background(colorScheme == .dark ? DarkMode.border : LightMode.border)
                                .padding(.leading, Spacing.lg)
                        }
                    }
                }
            }
        }
        .background(GlassCardBackground())
        .clipShape(RoundedRectangle(cornerRadius: BorderRadius.xl))
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32))
                .foregroundColor(AuroraColors.mint.opacity(0.5))
            
            Text("No recent trades")
                .font(AuroraTypography.bodyMedium)
                .foregroundColor(colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
    }
}

#Preview {
    RecentTradesView()
        .environmentObject(BotManager())
        .padding()
        .background(Color.black)
}

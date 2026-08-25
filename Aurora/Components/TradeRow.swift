//
//  TradeRow.swift
// Aurora - Redesigned
//
//  Individual trade row component
//
//

import SwiftUI

struct TradeRow: View {
    let trade: TradeResponse
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Status Indicator
            Circle()
                .fill((trade.profit ?? 0) >= 0 ? SemanticColors.successPrimary : SemanticColors.errorPrimary)
                .frame(width: 8, height: 8)
                .shadow(
                    color: ((trade.profit ?? 0) >= 0 ? SemanticColors.successPrimary : SemanticColors.errorPrimary).opacity(0.5),
                    radius: 4,
                    x: 0,
                    y: 0
                )
            
            // Symbol & Time
            VStack(alignment: .leading, spacing: 2) {
                Text(trade.symbol)
                    .font(AuroraTypography.bodyMedium)
                    .foregroundColor(colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary)
                
                if let closeTime = trade.closeTime {
                    Text(formatTime(closeTime))
                        .font(AuroraTypography.labelSmall)
                        .foregroundColor(colorScheme == .dark ? DarkMode.textTertiary : LightMode.textTertiary)
                }
            }
            
            Spacer()
            
            // P&L & R-Multiple
            VStack(alignment: .trailing, spacing: 2) {
                Text("\((trade.profit ?? 0) >= 0 ? "+" : "")\(trade.profit ?? 0, specifier: "%.2f")")
                    .font(AuroraTypography.monoMedium)
                    .foregroundColor((trade.profit ?? 0) >= 0 ? SemanticColors.successPrimary : SemanticColors.errorPrimary)
                
                if let rMultiple = trade.rMultiple {
                    Text("\(rMultiple, specifier: "%.1f")R")
                        .font(AuroraTypography.labelSmall)
                        .foregroundColor(colorScheme == .dark ? DarkMode.textTertiary : LightMode.textTertiary)
                }
            }
        }
        .contentShape(Rectangle()) // Make full row tappable if needed
    }
    
    private func formatTime(_ timeString: String) -> String {
        // Simple formatter, can be improved with DateFormatter
        // Assuming ISO string or similar, just taking time part for now
        if timeString.contains("T") {
            let parts = timeString.components(separatedBy: "T")
            if parts.count > 1 {
                return String(parts[1].prefix(5))
            }
        }
        return timeString
    }
}

#Preview {
    TradeRow(trade: TradeResponse(
        id: "1",
        ticket: "12345",
        symbol: "EURUSD",
        type: "SELL",
        volume: 0.1,
        openPrice: 1.0850,
        closePrice: 1.0840,
        stopLoss: 1.0860,
        takeProfit: 1.0830,
        profit: 10.0,
        commission: 0,
        swap: 0,
        openTime: "2023-10-27T10:00:00",
        closeTime: "2023-10-27T14:30:00",
        duration: 16200,
        comment: nil,
        rMultiple: 1.5
    ))
    .padding()
    .background(Color.black)
}

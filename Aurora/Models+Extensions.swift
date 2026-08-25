//
//  Models+Extensions.swift
// Aurora
//
//  Extensions to convert between API response models and UI models
//

import Foundation

// MARK: - Position Response to UI Model Conversion

extension PositionResponse {
    /// Convert API Position to UI Position model
    func toUIModel() -> Position {
        let direction = type.uppercased().contains("BUY") ? "LONG" : "SHORT"
        let currentPrice = self.currentPrice ?? openPrice
        let pnl = self.profit ?? 0.0

        // Calculate confidence based on profit and risk
        let confidence = calculateConfidence(profit: pnl, volume: volume)

        // Calculate bars held (approximate based on time)
        let bars = calculateBarsHeld(openTime: openTime)

        return Position(
            symbol: symbol,
            direction: direction,
            entry: openPrice,
            current: currentPrice,
            pnl: pnl,
            confidence: confidence,
            bars: bars
        )
    }

    private func calculateConfidence(profit: Double, volume: Double) -> Double {
        // Simple confidence calculation based on profit ratio
        let profitRatio = abs(profit / (volume * 100))
        let confidence = min(max(profitRatio, 0.5), 1.0)  // Clamp between 0.5 and 1.0
        return confidence
    }

    private func calculateBarsHeld(openTime: String) -> Int {
        // Parse open time and calculate approximate bars (assuming H4 timeframe)
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: openTime) {
            let hours = Date().timeIntervalSince(date) / 3600
            return Int(hours / 4)  // Assuming H4 bars
        }
        return 0
    }
}

// MARK: - Trade Response to UI Model Conversion

extension TradeResponse {
    /// Convert API Trade to UI Trade model
    func toUIModel() -> Trade {
        return Trade(
            symbol: symbol,
            pnl: profit ?? 0.0,
            time: formatTime(closeTime ?? openTime),
            rValue: rMultiple ?? 0.0
        )
    }

    private func formatTime(_ isoTime: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoTime) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        }
        return "00:00"
    }
}

// MARK: - BotManager Computed Properties

extension BotManager {
    /// Recent trades converted to UI model for backward compatibility
    var recentTrades: [Trade] {
        return trades.map { $0.toUIModel() }
    }

    /// Active positions converted to UI model
    var activePositionsList: [Position] {
        return positions.map { $0.toUIModel() }
    }

    /// Equity curve converted to UI model
    var equityCurvePoints: [EquityPoint] {
        return equityCurve
    }
}

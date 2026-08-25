//
//  SharedDataService.swift
// Aurora
//
//  Shared data service for communication between app and widgets
//  Uses App Groups to share data with widget extensions
//

import Foundation
import WidgetKit

class SharedDataService {
    static let shared = SharedDataService()
    
    // MARK: - App Group Configuration
    // Ensure this App Group is enabled on:
    // - App target (com.eden.joseph.Eden)
    // - AuroraWidget target
    // - EdenControlWidget target
    private let appGroupIdentifier = "group.com.eden.joseph.Eden"
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
    
    private init() {}
    
    // MARK: - Widget Data Model
    struct WidgetData: Codable {
        let isRunning: Bool
        let balance: Double
        let dailyPnL: Double
        let activePositions: Int
        let winRate: Double
        let totalTrades: Int
        let profitFactor: Double
        let riskTier: String
        let lastUpdate: Date
        
        // Computed properties for widget display
        var isInProfit: Bool { dailyPnL > 0 }
        var statusText: String { isRunning ? "ACTIVE" : "STOPPED" }
        var profitStatusText: String {
            isInProfit ? "IN PROFIT" : (dailyPnL < 0 ? "IN LOSS" : "BREAK EVEN")
        }
    }
    
    // MARK: - Save Widget Data
    func saveWidgetData(_ data: WidgetData) {
        guard let defaults = userDefaults else {
            print("⚠️ Failed to access App Group UserDefaults")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(data)
            defaults.set(encoded, forKey: "widgetData")
            defaults.synchronize()
            
            WidgetCenter.shared.reloadAllTimelines()
            print("✓ Widget data saved and reloaded")
        } catch {
            print("✗ Failed to encode widget data: \(error)")
        }
    }
    
    // MARK: - Load Widget Data
    func loadWidgetData() -> WidgetData? {
        guard let defaults = userDefaults,
              let data = defaults.data(forKey: "widgetData") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let widgetData = try decoder.decode(WidgetData.self, from: data)
            return widgetData
        } catch {
            print("✗ Failed to decode widget data: \(error)")
            return nil
        }
    }
    
    // MARK: - Convenience Save Methods
    func saveBotStatus(
        isRunning: Bool,
        balance: Double,
        dailyPnL: Double,
        activePositions: Int,
        winRate: Double,
        totalTrades: Int,
        profitFactor: Double,
        riskTier: String
    ) {
        let data = WidgetData(
            isRunning: isRunning,
            balance: balance,
            dailyPnL: dailyPnL,
            activePositions: activePositions,
            winRate: winRate,
            totalTrades: totalTrades,
            profitFactor: profitFactor,
            riskTier: riskTier,
            lastUpdate: Date()
        )
        saveWidgetData(data)
    }
    
    // MARK: - Widget Reload
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func reloadSpecificWidget(kind: String) {
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }
}

// MARK: - Widget Data Extensions
extension SharedDataService.WidgetData {
    var formattedBalance: String {
        String(format: "$%.2f", balance)
    }
    var formattedDailyPnL: String {
        let sign = dailyPnL >= 0 ? "+" : ""
        return String(format: "%@$%.2f", sign, dailyPnL)
    }
    var formattedWinRate: String {
        String(format: "%.1f%%", winRate)
    }
    var formattedProfitFactor: String {
        String(format: "%.2fx", profitFactor)
    }
    var timeSinceUpdate: String {
        let interval = Date().timeIntervalSince(lastUpdate)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        return "\(Int(interval / 3600))h ago"
    }
}

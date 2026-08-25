//
//  BotBehaviorView.swift
// Aurora
//
//  Bot trading preferences and risk settings
//

import SwiftUI

enum RiskLevel: String, CaseIterable {
    case conservative = "Conservative"
    case moderate = "Moderate"
    case aggressive = "Aggressive"

    var color: Color {
        switch self {
        case .conservative: return AuroraColors.mint
        case .moderate: return AuroraColors.gold
        case .aggressive: return Color.red
        }
    }
}

struct BotBehaviorView: View {
    @State private var riskLevel: RiskLevel = .moderate
    @State private var maxTradesPerDay: Double = 10
    @State private var autoTradingEnabled = true
    @State private var defaultStopLoss: Double = 2.0
    @State private var defaultTakeProfit: Double = 4.0

    // Currency pairs
    @State private var allowedPairs: Set<String> = ["EUR/USD", "GBP/USD", "USD/JPY"]
    @State private var availablePairs = [
        "EUR/USD", "GBP/USD", "USD/JPY", "AUD/USD", "USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY",
    ]

    // Trading hours
    @State private var tradingHoursEnabled = false
    @State private var tradingStart = Date()
    @State private var tradingEnd = Date()

    var body: some View {
        ZStack {
            AmbientBackgroundView(colorTheme: .settings)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bot Behavior")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Configure trading parameters and risk settings")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Auto Trading Toggle
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Auto Trading")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)

                                Text(
                                    autoTradingEnabled ? "Bot is actively trading" : "Bot is paused"
                                )
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            }

                            Spacer()

                            Toggle("", isOn: $autoTradingEnabled)
                                .labelsHidden()
                                .tint(AuroraColors.lime)
                                .onChange(of: autoTradingEnabled) { _, newValue in
                                    HapticFeedback.impact(.medium)
                                    saveSettings()
                                }
                        }
                    }
                    .padding(20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))

                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal)

                    // Risk Level
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Risk Level")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        HStack(spacing: 12) {
                            ForEach(RiskLevel.allCases, id: \.self) { level in
                                RiskLevelButton(
                                    level: level,
                                    isSelected: riskLevel == level,
                                    action: {
                                        withAnimation(SpringAnimations.snappy) {
                                            riskLevel = level
                                            HapticFeedback.selection()
                                            saveSettings()
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))

                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal)

                    // Trade Limits
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Max Trades Per Day")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Text("\(Int(maxTradesPerDay))")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AuroraColors.lime)
                        }
                        .padding(.horizontal, 20)

                        Slider(value: $maxTradesPerDay, in: 1...50, step: 1)
                            .tint(AuroraColors.lime)
                            .padding(.horizontal, 20)
                            .onChange(of: maxTradesPerDay) { _, _ in
                                saveSettings()
                            }
                    }
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))

                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal)

                    // Stop Loss & Take Profit
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Default Risk Parameters")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            HStack {
                                Text("Stop Loss")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)

                                Spacer()

                                Text("\(String(format: "%.1f", defaultStopLoss))%")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color.red)
                            }

                            Slider(value: $defaultStopLoss, in: 0.5...10, step: 0.5)
                                .tint(Color.red)
                                .onChange(of: defaultStopLoss) { _, _ in
                                    saveSettings()
                                }
                        }
                        .padding(.horizontal, 20)

                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            HStack {
                                Text("Take Profit")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)

                                Spacer()

                                Text("\(String(format: "%.1f", defaultTakeProfit))%")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(AuroraColors.lime)
                            }

                            Slider(value: $defaultTakeProfit, in: 0.5...20, step: 0.5)
                                .tint(AuroraColors.lime)
                                .onChange(of: defaultTakeProfit) { _, _ in
                                    saveSettings()
                                }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))

                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal)

                    // Allowed Currency Pairs
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Allowed Currency Pairs")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12
                        ) {
                            ForEach(availablePairs, id: \.self) { pair in
                                CurrencyPairButton(
                                    pair: pair,
                                    isSelected: allowedPairs.contains(pair),
                                    action: {
                                        if allowedPairs.contains(pair) {
                                            allowedPairs.remove(pair)
                                        } else {
                                            allowedPairs.insert(pair)
                                        }
                                        HapticFeedback.selection()
                                        saveSettings()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))

                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal)

                    // Trading Hours
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Trading Hours")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Toggle("", isOn: $tradingHoursEnabled)
                                .labelsHidden()
                                .tint(AuroraColors.lime)
                                .onChange(of: tradingHoursEnabled) { _, _ in
                                    saveSettings()
                                }
                        }
                        .padding(.horizontal, 20)

                        if tradingHoursEnabled {
                            Text("Bot will only trade during specified hours")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))

                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
            fetchAvailablePairs()
        }
    }

    // MARK: - Methods
    private func fetchAvailablePairs() {
        Task {
            do {
                let pairs = try await TradingService.shared.getAvailablePairs()
                if !pairs.isEmpty {
                    await MainActor.run {
                        self.availablePairs = pairs
                    }
                }
            } catch {
                print("❌ Failed to fetch pairs: \(error)")
            }
        }
    }

    private func loadSettings() {
        if let savedRisk = UserDefaults.standard.string(forKey: "riskLevel"),
            let risk = RiskLevel(rawValue: savedRisk)
        {
            riskLevel = risk
        }

        maxTradesPerDay = UserDefaults.standard.double(forKey: "maxTradesPerDay")
        if maxTradesPerDay == 0 { maxTradesPerDay = 10 }

        autoTradingEnabled = UserDefaults.standard.bool(forKey: "autoTradingEnabled")
        defaultStopLoss = UserDefaults.standard.double(forKey: "defaultStopLoss")
        if defaultStopLoss == 0 { defaultStopLoss = 2.0 }

        defaultTakeProfit = UserDefaults.standard.double(forKey: "defaultTakeProfit")
        if defaultTakeProfit == 0 { defaultTakeProfit = 4.0 }
    }

    private func saveSettings() {
        UserDefaults.standard.set(riskLevel.rawValue, forKey: "riskLevel")
        UserDefaults.standard.set(maxTradesPerDay, forKey: "maxTradesPerDay")
        UserDefaults.standard.set(autoTradingEnabled, forKey: "autoTradingEnabled")
        UserDefaults.standard.set(defaultStopLoss, forKey: "defaultStopLoss")
        UserDefaults.standard.set(defaultTakeProfit, forKey: "defaultTakeProfit")
    }
}

// MARK: - Risk Level Button
struct RiskLevelButton: View {
    let level: RiskLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(level.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .gray)

                Rectangle()
                    .fill(level.color)
                    .frame(height: 4)
                    .cornerRadius(2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? level.color.opacity(0.2) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? level.color.opacity(0.5) : Color.white.opacity(0.1),
                        lineWidth: 1)
            )
        }
    }
}

// MARK: - Currency Pair Button
struct CurrencyPairButton: View {
    let pair: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? AuroraColors.lime : .gray)
                    .font(.system(size: 16))

                Text(pair)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .gray)

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AuroraColors.lime.opacity(0.1) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? AuroraColors.lime.opacity(0.3) : Color.white.opacity(0.1),
                        lineWidth: 1)
            )
        }
    }
}

#Preview {
    NavigationStack {
        BotBehaviorView()
    }
}

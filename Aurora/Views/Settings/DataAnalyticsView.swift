//
//  DataAnalyticsView.swift
// Aurora
//
//  Data collection and analytics preferences
//

import SwiftUI

enum SyncFrequency: String, CaseIterable {
    case realtime = "Real-time"
    case hourly = "Hourly"
    case daily = "Daily"

    var icon: String {
        switch self {
        case .realtime: return "bolt.fill"
        case .hourly: return "clock.fill"
        case .daily: return "calendar.fill"
        }
    }
}

struct DataAnalyticsView: View {
    @State private var dataCollectionEnabled = true
    @State private var performanceLogsEnabled = true
    @State private var syncFrequency: SyncFrequency = .hourly
    @State private var storageUsed: Double = 45.2  // MB
    @State private var showClearCacheAlert = false
    @State private var showExportAlert = false

    var body: some View {
        ZStack {
            AmbientBackgroundView(colorTheme: .settings)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data & Analytics")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Manage data collection and storage preferences")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Data Collection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Data Collection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ToggleRow(title: "Enable Data Collection", isOn: $dataCollectionEnabled)
                            .onChange(of: dataCollectionEnabled) { _, _ in
                                saveSettings()
                            }

                        if dataCollectionEnabled {
                            Text("Collect trade data, performance metrics, and analytics")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                        }

                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, 20)

                        ToggleRow(title: "Performance Logs", isOn: $performanceLogsEnabled)
                            .onChange(of: performanceLogsEnabled) { _, _ in
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

                    // Sync Frequency
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sync Frequency")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            ForEach(SyncFrequency.allCases, id: \.self) { frequency in
                                SyncFrequencyButton(
                                    frequency: frequency,
                                    isSelected: syncFrequency == frequency,
                                    action: {
                                        withAnimation(SpringAnimations.snappy) {
                                            syncFrequency = frequency
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

                    // Storage Usage
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Storage")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Text("\(String(format: "%.1f", storageUsed)) MB")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AuroraColors.gold)
                        }
                        .padding(.horizontal, 20)

                        // Storage bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [AuroraColors.lime, AuroraColors.gold],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * CGFloat(storageUsed / 100),
                                        height: 8)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal, 20)

                        Text("Trade history, logs, and cached analytics data")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
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

                    // Actions
                    VStack(spacing: 12) {
                        // Export Button
                        Button(action: {
                            showExportAlert = true
                            HapticFeedback.selection()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16))

                                Text("Export Trade History")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [
                                        AuroraColors.lime.opacity(0.8),
                                        AuroraColors.mint.opacity(0.8),
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: AuroraColors.lime.opacity(0.3), radius: 12, x: 0, y: 4)
                        }

                        // Clear Cache Button
                        Button(action: {
                            showClearCacheAlert = true
                            HapticFeedback.selection()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 16))

                                Text("Clear Cache")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.red.opacity(0.4), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
        }
        .alert("Clear Cache", isPresented: $showClearCacheAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                clearCache()
            }
        } message: {
            Text(
                "This will remove cached analytics data and temporary files. Trade history will be preserved."
            )
        }
        .alert("Export Trade History", isPresented: $showExportAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Export CSV") {
                exportTradeHistory()
            }
        } message: {
            Text("Export your complete trade history as a CSV file")
        }
    }

    // MARK: - Methods
    private func loadSettings() {
        dataCollectionEnabled = UserDefaults.standard.bool(forKey: "dataCollectionEnabled")
        performanceLogsEnabled = UserDefaults.standard.bool(forKey: "performanceLogsEnabled")

        if let savedFreq = UserDefaults.standard.string(forKey: "syncFrequency"),
            let freq = SyncFrequency(rawValue: savedFreq)
        {
            syncFrequency = freq
        }

        // Calculate cache size
        let currentUsage = URLCache.shared.currentDiskUsage
        storageUsed = Double(currentUsage) / 1024 / 1024
    }

    private func saveSettings() {
        UserDefaults.standard.set(dataCollectionEnabled, forKey: "dataCollectionEnabled")
        UserDefaults.standard.set(performanceLogsEnabled, forKey: "performanceLogsEnabled")
        UserDefaults.standard.set(syncFrequency.rawValue, forKey: "syncFrequency")
    }

    private func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        HapticFeedback.notification(.success)
        withAnimation {
            storageUsed = 0
        }
        print("🗑️ Cache cleared")
    }

    private func exportTradeHistory() {
        Task {
            do {
                let trades = try await TradingService.shared.getTradeHistory(limit: 1000)
                let csvString = generateCSV(from: trades)

                // Save to temporary file
                let fileName = "Aurora_Trade_History_\(Date().timeIntervalSince1970).csv"
                let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                try csvString.write(to: path, atomically: true, encoding: .utf8)

                await MainActor.run {
                    HapticFeedback.notification(.success)
                    shareFile(url: path)
                }
            } catch {
                print("❌ Failed to export trades: \(error)")
            }
        }
    }

    private func generateCSV(from trades: [TradeResponse]) -> String {
        var csv = "ID,Symbol,Type,Entry Price,Exit Price,Size,Profit,Open Time,Close Time\n"

        for trade in trades {
            let entryPrice = trade.openPrice
            let exitPrice = trade.closePrice ?? 0
            let profit = trade.profit ?? 0
            let openTime = trade.openTime
            let closeTime = trade.closeTime ?? ""

            let line =
                "\(trade.id),\(trade.symbol),\(trade.type),\(entryPrice),\(exitPrice),\(trade.volume),\(profit),\(openTime),\(closeTime)\n"
            csv.append(line)
        }

        return csv
    }

    private func shareFile(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Sync Frequency Button
struct SyncFrequencyButton: View {
    let frequency: SyncFrequency
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: frequency.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? AuroraColors.lime : .gray)
                    .frame(width: 32)

                Text(frequency.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSelected ? .white : .gray)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AuroraColors.lime)
                        .font(.system(size: 18))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AuroraColors.lime.opacity(0.1) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? AuroraColors.lime.opacity(0.3) : Color.white.opacity(0.1),
                        lineWidth: 1)
            )
        }
    }
}

#Preview {
    NavigationStack {
        DataAnalyticsView()
    }
}

//
//  NotificationsView.swift
// Aurora
//
//  Notification preferences for trades, system events, and performance
//

import SwiftUI

struct NotificationsView: View {
    // Trade Alerts
    @State private var tradeOpenAlerts = true
    @State private var tradeCloseAlerts = true
    @State private var tradeModifyAlerts = false

    // System Events
    @State private var botStartedAlerts = true
    @State private var botStoppedAlerts = true
    @State private var errorAlerts = true

    // Performance Updates
    @State private var dailySummary = true
    @State private var milestoneAlerts = true
    @State private var weeklyReport = false

    // Options
    @State private var soundEnabled = true
    @State private var hapticEnabled = true
    @State private var quietHoursEnabled = false
    @State private var quietHoursStart = Date()
    @State private var quietHoursEnd = Date()

    var body: some View {
        ZStack {
            AmbientBackgroundView(colorTheme: .settings)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Customize alerts and notification preferences")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Trade Alerts Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Trade Alerts")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ToggleRow(title: "Trade Opened", isOn: $tradeOpenAlerts)
                        ToggleRow(title: "Trade Closed", isOn: $tradeCloseAlerts)
                        ToggleRow(title: "Trade Modified", isOn: $tradeModifyAlerts)
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

                    // System Events Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("System Events")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ToggleRow(title: "Bot Started", isOn: $botStartedAlerts)
                        ToggleRow(title: "Bot Stopped", isOn: $botStoppedAlerts)
                        ToggleRow(title: "Error Alerts", isOn: $errorAlerts)
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

                    // Performance Updates Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Performance Updates")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ToggleRow(title: "Daily Summary", isOn: $dailySummary)
                        ToggleRow(title: "Milestone Alerts", isOn: $milestoneAlerts)
                        ToggleRow(title: "Weekly Report", isOn: $weeklyReport)
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

                    // Notification Options
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Options")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ToggleRow(title: "Sound", isOn: $soundEnabled)
                        ToggleRow(title: "Haptic Feedback", isOn: $hapticEnabled)
                        ToggleRow(title: "Quiet Hours", isOn: $quietHoursEnabled)
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
        }
        .onChange(of: tradeOpenAlerts) { _, newValue in saveSettings() }
        .onChange(of: tradeCloseAlerts) { _, newValue in saveSettings() }
        .onChange(of: soundEnabled) { _, newValue in saveSettings() }
        .onChange(of: hapticEnabled) { _, newValue in saveSettings() }
    }

    // MARK: - Methods
    private func loadSettings() {
        tradeOpenAlerts = UserDefaults.standard.bool(forKey: "notif_tradeOpen")
        tradeCloseAlerts = UserDefaults.standard.bool(forKey: "notif_tradeClose")
        soundEnabled = UserDefaults.standard.bool(forKey: "notif_sound")
        hapticEnabled = UserDefaults.standard.bool(forKey: "notif_haptic")

        // Check current permission status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .denied {
                // Handle denied state if needed
            }
        }
    }

    private func saveSettings() {
        UserDefaults.standard.set(tradeOpenAlerts, forKey: "notif_tradeOpen")
        UserDefaults.standard.set(tradeCloseAlerts, forKey: "notif_tradeClose")
        UserDefaults.standard.set(soundEnabled, forKey: "notif_sound")
        UserDefaults.standard.set(hapticEnabled, forKey: "notif_haptic")

        if tradeOpenAlerts || tradeCloseAlerts {
            NotificationManager.shared.requestAuthorization { granted in
                if !granted {
                    // Revert toggles if permission denied? Or just warn?
                    // For now, we just let the user know via console
                    print("Notification permission not granted")
                }
            }
        }
    }
}

// MARK: - Toggle Row Component
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AuroraColors.lime)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}

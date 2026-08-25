//
//  AuroraApp.swift
//  Aurora
//
//  Created by Aurora Trading System
//

import SwiftUI

@main
struct AuroraApp: App {
    @StateObject private var botManager = BotManager()
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(botManager)
                .environmentObject(sessionManager)
                .environmentObject(themeManager)
                .onAppear {
                    // BotManager handles authentication state changes
                    if sessionManager.isAuthenticated {
                        print("✅ User already authenticated")
                    } else {
                        print("ℹ️ Starting in guest mode")
                    }

                    // BotManager handles WebSocket connection

                    // Fetch initial public data (no auth required)
                    fetchInitialData()
                }
            // Remove forced dark mode - respect system preference
            // .preferredColorScheme(.dark)
        }
    }

    // MARK: - Initial Data Fetching

    /// Fetch initial data using BotManager
    private func fetchInitialData() {
        print("📡 Fetching initial data via BotManager...")
        // BotManager already loads initial data in its init()
        // This is just for explicit refresh if needed
    }
}

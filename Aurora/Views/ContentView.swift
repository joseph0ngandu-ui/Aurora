//
//  ContentView.swift
// Aurora - Redesigned
//
//  Main container view with tab navigation and premium background
//  HeaderView removed - authentication and bot control moved to Settings
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Dynamic background based on theme
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab Content (no header)
                TabView(selection: $selectedTab) {
                    OverviewView()
                        .tag(0)
                    
                    PositionsView()
                        .tag(1)
                    
                    AnalyticsView()
                        .tag(2)
                    
                    StrategiesView()
                        .tag(3)
                    
                    SettingsView()
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.xs)
            }
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? DarkMode.primary : LightMode.primary
    }
}

#Preview("Dark Mode") {
    ContentView()
        .environmentObject(BotManager())
        .environmentObject(SessionManager.shared)
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    ContentView()
        .environmentObject(BotManager())
        .environmentObject(SessionManager.shared)
        .preferredColorScheme(.light)
}

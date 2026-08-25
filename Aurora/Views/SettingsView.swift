//
//  SettingsView.swift
// Aurora
//
//  Modular settings hub with authentication and bot control features
//  Now includes all features previously in HeaderView
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showLoginSheet = false
    @State private var showAuthAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackgroundView(colorTheme: .settings)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header with App Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Settings")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

                            Text("Configure Aurora and manage your account")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Authentication Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Account")
                            
                            if sessionManager.isAuthenticated {
                                // Profile Card
                                profileCard
                            } else {
                                // Sign In Card
                                signInCard
                            }
                        }
                        .padding(.horizontal)
                        
                        // Bot Control Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Bot Control")
                            
                            botControlCard
                        }
                        .padding(.horizontal)

                        // Trading Account Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Trading")

                            NavigationLink(
                                destination: TradingAccountView().environmentObject(botManager)
                            ) {
                                SettingItem(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Trading Account",
                                    subtitle: "MetaTrader 5 configuration",
                                    iconColor: AuroraColors.lime
                                )
                            }

                            NavigationLink(destination: APIConnectionsView()) {
                                SettingItem(
                                    icon: "antenna.radiowaves.left.and.right",
                                    title: "API Connections",
                                    subtitle: "Server URLs and tokens",
                                    iconColor: AuroraColors.gold
                                )
                            }
                        }
                        .padding(.horizontal)

                        // Preferences Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Preferences")

                            NavigationLink(destination: NotificationsView()) {
                                SettingItem(
                                    icon: "bell.badge",
                                    title: "Notifications",
                                    subtitle: "Alerts and updates",
                                    iconColor: AuroraColors.mint
                                )
                            }

                            NavigationLink(destination: ThemeAppearanceView()) {
                                SettingItem(
                                    icon: "paintbrush.fill",
                                    title: "Theme & Appearance",
                                    subtitle: "Colors and visual style",
                                    iconColor: Color.purple
                                )
                            }

                            NavigationLink(destination: SecurityLoginView()) {
                                SettingItem(
                                    icon: "lock.shield.fill",
                                    title: "Security & Login",
                                    subtitle: "Authentication and privacy",
                                    iconColor: Color.blue
                                )
                            }
                        }
                        .padding(.horizontal)

                        // System Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "System")

                            NavigationLink(destination: BotBehaviorView()) {
                                SettingItem(
                                    icon: "gearshape.2.fill",
                                    title: "Bot Behavior",
                                    subtitle: "Trading rules and risk settings",
                                    iconColor: AuroraColors.gold
                                )
                            }

                            NavigationLink(destination: DataAnalyticsView()) {
                                SettingItem(
                                    icon: "chart.bar.fill",
                                    title: "Data & Analytics",
                                    subtitle: "Collection and sync preferences",
                                    iconColor: Color.cyan
                                )
                            }
                        }
                        .padding(.horizontal)

                        // About Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "About")

                            NavigationLink(destination: AboutAuroraView()) {
                                SettingItem(
                                    icon: "info.circle.fill",
                                    title: "About Aurora",
                                    subtitle: "Version, support, and legal",
                                    iconColor: .gray
                                )
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 60)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
                    .environmentObject(sessionManager)
            }
            .alert("Authentication Required", isPresented: $showAuthAlert) {
                Button("Sign In") {
                    showLoginSheet = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please sign in to control the trading bot")
            }
        }
    }
    
    // MARK: - Sign In Card
    
    private var signInCard: some View {
        Button(action: {
            HapticFeedback.selection()
            showLoginSheet = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AuroraColors.forest, AuroraColors.mint.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sign In")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Access all features and sync your data")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(GlassCardBackground())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Profile Card
    
    private var profileCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AuroraColors.lime, AuroraColors.mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(sessionManager.currentUser?.username ?? sessionManager.currentUser?.email ?? "User")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if let user = sessionManager.currentUser {
                        Text(user.email)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            Button(action: {
                HapticFeedback.selection()
                sessionManager.logout()
            }) {
                HStack {
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 15, weight: .semibold))
                    
                    Text("Sign Out")
                        .font(.system(size: 15, weight: .semibold))
                    
                    Spacer()
                }
                .foregroundColor(.red.opacity(0.9))
                .padding(16)
            }
        }
        .background(GlassCardBackground())
    }
    
    // MARK: - Bot Control Card
    
    private var botControlCard: some View {
        VStack(spacing: 16) {
            // Bot Status Display
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: botManager.isRunning
                                    ? [SemanticColors.successPrimary, SemanticColors.successSecondary]
                                    : [SemanticColors.errorPrimary, SemanticColors.errorSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    PulseIndicator(
                        color: botManager.isRunning ? SemanticColors.successPrimary : SemanticColors.errorPrimary,
                        size: 8
                    )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bot Status")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(botManager.isRunning ? "Active Trading" : "Paused")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Bot Control Button
            Button(action: handleBotControl) {
                HStack {
                    Image(systemName: botManager.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text(botManager.isRunning ? "Stop Bot" : "Start Bot")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    LinearGradient(
                        colors: botManager.isRunning
                            ? [SemanticColors.errorPrimary, SemanticColors.errorSecondary]
                            : [SemanticColors.successPrimary, SemanticColors.successSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(GlassCardBackground())
    }
    
    // MARK: - Actions
    
    private func handleBotControl() {
        HapticFeedback.impact(.medium)
        
        // Check if authenticated for bot control
        guard sessionManager.isAuthenticated else {
            showAuthAlert = true
            return
        }
        
        // Proceed with bot toggle
        botManager.toggleBot()
    }
}

// MARK: - Section Header Component
struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.gray.opacity(0.8))
            .padding(.horizontal, 4)
            .padding(.top, 8)
    }
}

#Preview {
    SettingsView()
        .environmentObject(BotManager())
        .environmentObject(SessionManager.shared)
}

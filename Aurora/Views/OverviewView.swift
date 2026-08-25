//
//  OverviewView.swift
// Aurora
//
//  Main dashboard with stats, equity curve, and recent trades
//  Redesigned with "Next Level" animations and glassmorphism.
//

import SwiftUI

struct OverviewView: View {
    @EnvironmentObject var botManager: BotManager
    @State private var mt5AccountNumber = ""
    @State private var mt5AccountName = ""
    @State private var mt5Broker = ""

    var body: some View {
        ZStack(alignment: .top) {
            // 1. Ambient Background
            AmbientBackgroundView()
                .zIndex(0)

            // 2. Main Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Logo and Name Header
                    logoHeader
                        .padding(.top, 60)

                    // Balance Card Section
                    BalanceCardView()
                        .padding(.horizontal)

                    // MT5 Account Info Card
                    if !mt5AccountNumber.isEmpty {
                        accountInfoCard
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Stats Grid
                    statsGrid

                    // Equity Curve
                    equityCurveSection

                    // Recent Trades
                    recentTradesSection

                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
            .zIndex(1)

            // 3. Loading Overlay
            if botManager.isLoading {
                LoadingView()
                    .zIndex(2)
                    .transition(.opacity)
            }
        }
        .onAppear {
            loadMT5AccountInfo()
            // Always refresh live data when dashboard appears
            Task {
                await botManager.refreshData()
            }
        }
    }

    // MARK: - Logo Header

    private var logoHeader: some View {
        HStack(spacing: 12) {
            // Logo Icon
            // Logo Icon
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .shadow(color: AuroraColors.lime.opacity(0.5), radius: 8, x: 0, y: 0)

            // App Name
            VStack(alignment: .leading, spacing: 2) {
                Text("Aurora")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AuroraColors.lime, AuroraColors.mint, AuroraColors.forest],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("AI Trading Platform")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .tracking(0.5)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Components

    private var accountInfoCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 24))
                .foregroundColor(AuroraColors.lime)

            VStack(alignment: .leading, spacing: 4) {
                Text("Trading Account")
                    .font(AuroraTypography.labelSmall)
                    .foregroundColor(AuroraColors.mint.opacity(0.7))

                Text("\(mt5AccountNumber) - \(mt5AccountName)")
                    .font(AuroraTypography.h6)
                    .foregroundColor(.white)

                Text(mt5Broker)
                    .font(AuroraTypography.bodySmall)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AuroraColors.lime)
        }
        .padding(16)
        .background(
            GlassCardBackground()
        )
        .padding(.horizontal)
    }

    private var statsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
            ],
            alignment: .center,
            spacing: 16
        ) {
            StatCard(
                icon: "target",
                label: "Win Rate",
                value: String(format: "%.1f%%", botManager.winRate),
                trend: 2.3,
                color: AuroraColors.lime
            )

            StatCard(
                icon: "shield.fill",
                label: "Risk Tier",
                value: botManager.riskTier,
                subtext: String(format: "%.1f%% per trade", botManager.riskPerTrade),
                color: AuroraColors.gold
            )

            StatCard(
                icon: "chart.line.uptrend.xyaxis",
                label: "Active Trades",
                value: "\(botManager.activePositions)",
                subtext: "\(botManager.totalTrades) total",
                color: AuroraColors.mint
            )

            StatCard(
                icon: "chart.bar.fill",
                label: "Profit Factor",
                value: String(format: "%.2f", botManager.profitFactor),
                trend: 5.1,
                color: AuroraColors.forest
            )
        }
        .padding(.horizontal)
    }

    private var equityCurveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance")
                .font(AuroraTypography.h5)
                .foregroundColor(.white)
                .padding(.horizontal)

            EquityCurveView()
                .frame(height: 250)
                .padding(16)
                .background(GlassCardBackground())
                .padding(.horizontal)
        }
    }

    private var recentTradesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(AuroraTypography.h5)
                .foregroundColor(.white)
                .padding(.horizontal)

            RecentTradesView()
                .padding(.horizontal)
        }
    }

    // MARK: - Methods
    private func loadMT5AccountInfo() {
        mt5AccountNumber = UserDefaults.standard.string(forKey: "mt5AccountNumber") ?? ""
        mt5AccountName = UserDefaults.standard.string(forKey: "mt5AccountName") ?? ""
        mt5Broker = UserDefaults.standard.string(forKey: "mt5Broker") ?? ""
    }
}

// MARK: - Helper Components

struct GlassCardBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.6))

            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    OverviewView()
        .environmentObject(BotManager())
        .background(Color.black)
}

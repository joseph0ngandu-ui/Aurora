//
//  HeaderView.swift
// Aurora - Redesigned
//
//  Ultra-modern header with glassmorphism, smooth animations, and authentication
//  Now supports dynamic collapsing based on scroll position.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var botManager: BotManager
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.colorScheme) var colorScheme

    @State private var showLoginSheet = false
    @State private var showAuthAlert = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Logo Section
            HStack(spacing: 10) {
                logoIcon

                VStack(alignment: .leading, spacing: 1) {
                    Text("Aurora")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(logoGradient)

                    Text("AI Trading")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(textSecondary)
                        .tracking(0.5)
                }
            }

            Spacer()

            // Right side controls
            HStack(spacing: 8) {
                // Login/Profile button
                if sessionManager.isAuthenticated {
                    profileButton
                } else {
                    loginButton
                }

                // Bot Control Button
                botControlButton
            }
        }
        .padding(Spacing.md)
        .background(glassBackground)
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

    private var logoIcon: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .shadow(color: AuroraColors.lime.opacity(0.5), radius: 5, x: 0, y: 0)
    }

    private var logoGradient: LinearGradient {
        LinearGradient(
            colors: [AuroraColors.lime, AuroraColors.mint, AuroraColors.forest],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Login Button

    private var loginButton: some View {
        Button(action: {
            HapticFeedback.selection()
            showLoginSheet = true
        }) {
            HStack(spacing: 4) {
                Image(systemName: "person.circle")
                    .font(.system(size: 13, weight: .semibold))

                Text("Sign In")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(height: 32)
            .background(
                LinearGradient(
                    colors: [AuroraColors.forest, AuroraColors.mint.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }

    // MARK: - Profile Button

    private var profileButton: some View {
        Menu {
            if let user = sessionManager.currentUser {
                Text(user.email)
                    .font(.system(size: 12))

                Divider()
            }

            Button(action: {
                HapticFeedback.selection()
                sessionManager.logout()
            }) {
                Label("Sign Out", systemImage: "arrow.right.square")
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 13, weight: .semibold))

                Text("Profile")
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(height: 32)
            .background(
                LinearGradient(
                    colors: [AuroraColors.forest, AuroraColors.mint.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }

    // MARK: - Bot Control Button

    private var botControlButton: some View {
        Button(action: handleBotControl) {
            HStack(spacing: 4) {
                PulseIndicator(
                    color: botManager.isRunning
                        ? SemanticColors.successPrimary : SemanticColors.errorPrimary,
                    size: 6
                )

                Text(botManager.isRunning ? "Active" : "Paused")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(height: 32)
            .background(
                LinearGradient(
                    colors: botManager.isRunning
                        ? [SemanticColors.successPrimary, SemanticColors.successSecondary]
                        : [SemanticColors.errorPrimary, SemanticColors.errorSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: (botManager.isRunning
                    ? SemanticColors.successPrimary : SemanticColors.errorPrimary).opacity(0.3),
                radius: 8,
                x: 0,
                y: 2
            )
        }
    }

    // MARK: - Computed Properties for Theme

    private var textSecondary: Color {
        colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary
    }

    private var glassBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: BorderRadius.lg)
                .fill(colorScheme == .dark ? DarkMode.secondary : LightMode.secondary)

            RoundedRectangle(cornerRadius: BorderRadius.lg)
                .fill(colorScheme == .dark ? DarkMode.glass : LightMode.glass)
                .blur(radius: colorScheme == .dark ? DarkMode.glassBlur : LightMode.glassBlur)

            RoundedRectangle(cornerRadius: BorderRadius.lg)
                .strokeBorder(
                    colorScheme == .dark ? DarkMode.border : LightMode.border,
                    lineWidth: 1
                )
        }
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

#Preview("Dark Mode") {
    VStack {
        HeaderView()
        Spacer()
    }
    .environmentObject(BotManager())
    .environmentObject(SessionManager.shared)
    .padding()
    .background(DarkMode.primary)
    .preferredColorScheme(.dark)
}

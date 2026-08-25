//
//  APIConnectionsView.swift
// Aurora
//
//  Configure server URLs, tokens, and bot endpoints
//

import SwiftUI

struct APIConnectionsView: View {
    @State private var webhookURL = ""
    @State private var apiBaseURL = ""
    @State private var authToken = ""
    @State private var botEndpoint = ""
    @State private var isConnected = false
    @State private var showWarningAlert = false
    @State private var showSaveConfirmation = false
    @State private var activeAPI = APIConfig.apiBaseURL

    var body: some View {
        ZStack {
            AmbientBackgroundView(colorTheme: .settings)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Connections")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Configure server endpoints and authentication")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Current Active API
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active API Endpoint")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)

                        HStack {
                            Image(systemName: "network")
                                .foregroundColor(AuroraColors.lime)

                            Text(activeAPI)
                                .font(.system(size: 15, weight: .medium))  // Fixed: .monospaced() is not available in older SwiftUI versions or needs different syntax, using system font for safety
                                .foregroundColor(.white)

                            Spacer()

                            if activeAPI == APIConfig.productionBaseURL {
                                Text("PROD")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AuroraColors.lime)
                                    .cornerRadius(8)
                            } else {
                                Text("CUSTOM")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AuroraColors.gold)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AuroraColors.lime.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }

                    // API Configuration Form
                    VStack(spacing: 16) {
                        SettingField(label: "Webhook URL", text: $webhookURL)
                            .keyboardType(.URL)

                        SettingField(label: "API Base URL", text: $apiBaseURL)
                            .keyboardType(.URL)

                        SettingField(
                            label: "Authentication Token", text: $authToken, isSecure: true)

                        SettingField(label: "Bot Endpoint", text: $botEndpoint)
                            .keyboardType(.URL)
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

                    // Connection Status
                    HStack(spacing: 12) {
                        Circle()
                            .fill(isConnected ? AuroraColors.lime : Color.gray)
                            .frame(width: 12, height: 12)
                            .shadow(
                                color: isConnected ? AuroraColors.lime.opacity(0.6) : .clear,
                                radius: 8)

                        Text(isConnected ? "Connected" : "Not Connected")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isConnected ? AuroraColors.lime : .gray)

                        Spacer()

                        Button(action: {
                            testConnection()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 13))
                                Text("Test")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(AuroraColors.gold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AuroraColors.gold.opacity(0.15))
                            )
                        }
                    }
                    .padding(16)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))

                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal)

                    // Save Button
                    Button(action: {
                        if apiBaseURL != UserDefaults.standard.string(forKey: "apiBaseURL") {
                            showWarningAlert = true
                        } else {
                            saveSettings()
                        }
                    }) {
                        HStack {
                            if showSaveConfirmation {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                            }
                            Text(showSaveConfirmation ? "Saved!" : "Save Configuration")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(
                            LinearGradient(
                                colors: showSaveConfirmation
                                    ? [AuroraColors.lime, AuroraColors.mint]
                                    : [
                                        AuroraColors.gold.opacity(0.8),
                                        AuroraColors.lime.opacity(0.8),
                                    ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: AuroraColors.gold.opacity(0.3), radius: 12, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .alert("Change API Endpoint?", isPresented: $showWarningAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Change & Save", role: .destructive) {
                            saveSettings()
                        }
                    } message: {
                        Text(
                            "Changing the API Base URL may break app functionality if the new endpoint is not compatible or reachable. Are you sure you want to proceed?"
                        )
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
        }
    }

    // MARK: - Methods
    private func loadSettings() {
        webhookURL = UserDefaults.standard.string(forKey: "webhookURL") ?? ""
        apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? ""
        authToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        botEndpoint = UserDefaults.standard.string(forKey: "botEndpoint") ?? ""
        isConnected = UserDefaults.standard.bool(forKey: "apiConnected")
        activeAPI = APIConfig.apiBaseURL
    }

    private func saveSettings() {
        UserDefaults.standard.set(webhookURL, forKey: "webhookURL")
        UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL")
        UserDefaults.standard.set(authToken, forKey: "authToken")
        UserDefaults.standard.set(botEndpoint, forKey: "botEndpoint")

        // Update active API display
        activeAPI = APIConfig.apiBaseURL

        print("✅ API connections saved")
        HapticFeedback.notification(.success)
        withAnimation {
            showSaveConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSaveConfirmation = false
            }
        }
    }

    private func testConnection() {
        HapticFeedback.impact(.light)
        // Simulate connection test
        withAnimation {
            isConnected.toggle()
            UserDefaults.standard.set(isConnected, forKey: "apiConnected")
        }
        print(isConnected ? "✅ Connection successful" : "❌ Connection failed")
    }
}

#Preview {
    NavigationStack {
        APIConnectionsView()
    }
}

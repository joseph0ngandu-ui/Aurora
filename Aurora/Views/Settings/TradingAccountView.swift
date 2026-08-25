//
//  TradingAccountView.swift
// Aurora
//
//  MetaTrader 5 account configuration
//

import SwiftUI

struct TradingAccountView: View {
    @EnvironmentObject var botManager: BotManager

    // MetaTrader Account Settings
    @State private var mt5AccountNumber = ""
    @State private var mt5AccountName = ""
    @State private var mt5Broker = ""
    @State private var mt5Server = ""
    @State private var mt5Password = ""
    @State private var accountId: Int?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    @State private var showSaveConfirmation = false

    var body: some View {
        ZStack {
            AmbientBackgroundView(colorTheme: .settings)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trading Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Configure the MT5 account Eden is trading on")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // MT5 Form
                    VStack(spacing: 16) {
                        SettingField(label: "Account Number", text: $mt5AccountNumber)
                            .keyboardType(.numberPad)

                        SettingField(label: "Account Name", text: $mt5AccountName)

                        SettingField(label: "Broker", text: $mt5Broker)

                        SettingField(label: "Server", text: $mt5Server)

                        SettingField(label: "Password", text: $mt5Password, isSecure: true)
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
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.6 : 1)

                    // Account Status
                    if !mt5AccountNumber.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AuroraColors.lime)
                                    .font(.system(size: 20))

                                Text("Account Connected")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Account \(mt5AccountNumber) - \(mt5AccountName)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)

                                Text("\(mt5Broker) - \(mt5Server)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(20)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AuroraColors.lime.opacity(0.15),
                                                AuroraColors.lime.opacity(0.05),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(AuroraColors.lime.opacity(0.3), lineWidth: 1)
                            }
                        )
                        .padding(.horizontal)
                    }

                    // Save Button
                    Button(action: {
                        saveSettings()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 8)
                            } else if showSaveConfirmation {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                            }
                            Text(showSaveConfirmation ? "Saved!" : "Save Account")
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
                                        AuroraColors.lime.opacity(0.8),
                                        AuroraColors.gold.opacity(0.8),
                                    ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: AuroraColors.lime.opacity(0.3), radius: 12, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .disabled(isLoading)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error occurred")
        }
    }

    // MARK: - Methods
    private func loadSettings() {
        // First load from UserDefaults for immediate display
        mt5AccountNumber = UserDefaults.standard.string(forKey: "mt5AccountNumber") ?? ""
        mt5AccountName = UserDefaults.standard.string(forKey: "mt5AccountName") ?? ""
        mt5Broker = UserDefaults.standard.string(forKey: "mt5Broker") ?? ""
        mt5Server = UserDefaults.standard.string(forKey: "mt5Server") ?? ""
        mt5Password = UserDefaults.standard.string(forKey: "mt5Password") ?? ""

        // Then fetch from backend
        isLoading = true
        Task {
            do {
                let account = try await AccountService.shared.getPrimaryMT5Account()
                await MainActor.run {
                    self.accountId = account.id
                    self.mt5AccountNumber = account.accountNumber
                    self.mt5AccountName = account.accountName
                    self.mt5Broker = account.broker
                    self.mt5Server = account.server
                    // Password is not returned by API for security
                    self.isLoading = false

                    // Update UserDefaults to match backend
                    self.saveToUserDefaults()
                }
            } catch {
                print("⚠️ Failed to fetch primary account: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    // Don't show error alert here as it might just mean no account exists yet
                }
            }
        }
    }

    private func saveSettings() {
        isLoading = true

        Task {
            do {
                if let id = accountId {
                    // Update existing
                    let update = MT5AccountUpdate(
                        accountName: mt5AccountName,
                        password: mt5Password.isEmpty ? nil : mt5Password,
                        isPrimary: true,
                        isActive: true
                    )
                    let _ = try await AccountService.shared.updateMT5Account(
                        id: id, account: update)
                } else {
                    // Create new
                    let create = MT5AccountCreate(
                        accountNumber: mt5AccountNumber,
                        accountName: mt5AccountName,
                        broker: mt5Broker,
                        server: mt5Server,
                        password: mt5Password,
                        isPrimary: true
                    )
                    let response = try await AccountService.shared.createMT5Account(create)
                    await MainActor.run {
                        self.accountId = response.id
                    }
                }

                await MainActor.run {
                    self.isLoading = false
                    self.saveToUserDefaults()
                    self.botManager.saveSettings()

                    HapticFeedback.notification(.success)
                    withAnimation {
                        self.showSaveConfirmation = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.showSaveConfirmation = false
                        }
                    }

                    print("✅ MT5 Account saved to backend: \(mt5AccountNumber)")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                    print("❌ Failed to save MT5 account: \(error)")
                }
            }
        }
    }

    private func saveToUserDefaults() {
        UserDefaults.standard.set(mt5AccountNumber, forKey: "mt5AccountNumber")
        UserDefaults.standard.set(mt5AccountName, forKey: "mt5AccountName")
        UserDefaults.standard.set(mt5Broker, forKey: "mt5Broker")
        UserDefaults.standard.set(mt5Server, forKey: "mt5Server")
        if !mt5Password.isEmpty {
            UserDefaults.standard.set(mt5Password, forKey: "mt5Password")
        }
    }
}

#Preview {
    NavigationStack {
        TradingAccountView()
            .environmentObject(BotManager())
    }
}

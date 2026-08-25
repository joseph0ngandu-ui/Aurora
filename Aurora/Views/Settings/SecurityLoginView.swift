//
//  SecurityLoginView.swift
// Aurora
//
//  Security and authentication settings
//

import LocalAuthentication
import SwiftUI

struct SecurityLoginView: View {
    @State private var isSignedIn = true
    @State private var userEmail = "trader@example.com"
    @State private var twoFactorEnabled = false
    @State private var biometricEnabled = false
    @State private var showPasswordReset = false
    @State private var sessionTimeout: Double = 30  // minutes

    var body: some View {
        ZStack {
            AmbientBackgroundView(colorTheme: .settings)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Security & Login")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Manage security settings")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Session Management
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Session Timeout")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Text("\(Int(sessionTimeout)) min")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AuroraColors.lime)
                        }
                        .padding(.horizontal, 20)

                        Slider(value: $sessionTimeout, in: 5...60, step: 5)
                            .tint(AuroraColors.lime)
                            .padding(.horizontal, 20)
                            .onChange(of: sessionTimeout) { _, _ in
                                saveSettings()
                            }

                        Text(
                            "Automatically refresh session after \(Int(sessionTimeout)) minutes"
                        )
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
        sessionTimeout = UserDefaults.standard.double(forKey: "sessionTimeout")
        if sessionTimeout == 0 { sessionTimeout = 30 }
    }

    private func saveSettings() {
        UserDefaults.standard.set(sessionTimeout, forKey: "sessionTimeout")
    }
}

#Preview {
    NavigationStack {
        SecurityLoginView()
    }
}

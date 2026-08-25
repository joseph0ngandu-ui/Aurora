//
//  LoginView.swift
// Aurora
//
//  Login screen for user authentication with better error handling
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorTitle: String = "Error"
    @State private var errorDetail: String = ""
    @State private var isRegistering: Bool = false
    @State private var username: String = ""

    var body: some View {
        ZStack {
            // Background
            (colorScheme == .dark ? DarkMode.primary : LightMode.primary)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    Spacer()
                        .frame(height: Spacing.xxxl)

                    // Logo and Title
                    logoSection

                    // Form
                    formSection

                    // Action Button
                    actionButton

                    // Toggle between login/register
                    toggleButton

                    // Guest/Skip Button
                    guestButton

                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
            }
        }
        .alert(errorTitle, isPresented: $showError) {
            Button("OK", role: .cancel) {
                sessionManager.errorMessage = nil
            }
        } message: {
            Text(errorDetail)
        }
        .onChange(of: sessionManager.isAuthenticated) {
            if sessionManager.isAuthenticated {
                dismiss()
            }
        }
        .onChange(of: sessionManager.errorMessage) {
            if let error = sessionManager.errorMessage {
                errorTitle = isRegistering ? "Registration Failed" : "Login Failed"
                errorDetail = error
                showError = true
            }
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: Spacing.md) {
            // Logo
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AuroraColors.lime, AuroraColors.mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                    .opacity(0.5)

                // Logo Image
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .shadow(color: AuroraColors.lime.opacity(0.3), radius: 10, x: 0, y: 5)
            }

            // Title
            Text("Welcome to Eden")
                .font(AuroraTypography.h1)
                .foregroundStyle(
                    LinearGradient(
                        colors: [AuroraColors.lime, AuroraColors.mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text(isRegistering ? "Create your account" : "Sign in to continue")
                .font(AuroraTypography.bodyMedium)
                .foregroundColor(
                    colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary)
        }
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: Spacing.md) {
            // Username (only for registration)
            if isRegistering {
                LoginTextField(
                    icon: "person.fill",
                    placeholder: "Username (optional)",
                    text: $username
                )
            }

            // Email
            LoginTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            // Password
            LoginSecureField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password
            )
        }
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button(action: handleAction) {
            HStack(spacing: Spacing.sm) {
                if sessionManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(
                        systemName: isRegistering ? "person.badge.plus" : "arrow.right.circle.fill"
                    )
                    .font(AuroraTypography.h6)
                }

                Text(isRegistering ? "Create Account" : "Sign In")
                    .font(AuroraTypography.labelLarge)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                LinearGradient(
                    colors: [AuroraColors.lime, AuroraColors.mint],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(BorderRadius.md)
            .shadow(color: AuroraColors.lime.opacity(0.4), radius: 16, x: 0, y: 4)
        }
        .disabled(sessionManager.isLoading || email.isEmpty || password.isEmpty)
        .opacity((sessionManager.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
    }

    // MARK: - Toggle Button

    private var toggleButton: some View {
        Button(action: {
            withAnimation(SpringAnimations.snappy) {
                isRegistering.toggle()
                // Clear error when switching
                sessionManager.errorMessage = nil
            }
        }) {
            HStack(spacing: Spacing.xxs) {
                Text(isRegistering ? "Already have an account?" : "Don't have an account?")
                    .font(AuroraTypography.bodySmall)
                    .foregroundColor(
                        colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary)

                Text(isRegistering ? "Sign In" : "Register")
                    .font(AuroraTypography.labelMedium)
                    .foregroundColor(AuroraColors.lime)
            }
        }
        .padding(.top, Spacing.sm)
    }

    // MARK: - Guest Button

    private var guestButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text("Continue as Guest")
                .font(AuroraTypography.bodyMedium)
                .foregroundColor(
                    colorScheme == .dark ? DarkMode.textTertiary : LightMode.textTertiary
                )
                .padding(.vertical, Spacing.sm)
        }
    }

    // MARK: - Actions

    private func handleAction() {
        // Hide keyboard
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        if isRegistering {
            sessionManager.register(
                email: email,
                password: password,
                username: username.isEmpty ? nil : username
            ) { result in
                switch result {
                case .success:
                    // Success - view will dismiss automatically
                    break
                case .failure:
                    // Error will be shown via .onChange
                    break
                }
            }
        } else {
            sessionManager.login(email: email, password: password) { result in
                switch result {
                case .success:
                    // Success - view will dismiss automatically
                    break
                case .failure:
                    // Error will be shown via .onChange
                    break
                }
            }
        }
    }
}

// MARK: - Custom Text Field

struct LoginTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AuroraColors.lime)
                .frame(width: 24)

            TextField(placeholder, text: $text)
                .font(AuroraTypography.bodyMedium)
                .foregroundColor(
                    colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary
                )
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
        }
        .padding(Spacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: BorderRadius.md)
                    .fill(colorScheme == .dark ? DarkMode.secondary : LightMode.secondary)

                RoundedRectangle(cornerRadius: BorderRadius.md)
                    .strokeBorder(
                        colorScheme == .dark ? DarkMode.border : LightMode.border,
                        lineWidth: 1
                    )
            }
        )
    }
}

// MARK: - Custom Secure Field

struct LoginSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    @Environment(\.colorScheme) var colorScheme
    @State private var isSecured: Bool = true

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AuroraColors.lime)
                .frame(width: 24)

            if isSecured {
                SecureField(placeholder, text: $text)
                    .font(AuroraTypography.bodyMedium)
                    .foregroundColor(
                        colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary
                    )
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder, text: $text)
                    .font(AuroraTypography.bodyMedium)
                    .foregroundColor(
                        colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary
                    )
                    .autocorrectionDisabled()
            }

            Button(action: { isSecured.toggle() }) {
                Image(systemName: isSecured ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16))
                    .foregroundColor(
                        colorScheme == .dark ? DarkMode.textTertiary : LightMode.textTertiary)
            }
        }
        .padding(Spacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: BorderRadius.md)
                    .fill(colorScheme == .dark ? DarkMode.secondary : LightMode.secondary)

                RoundedRectangle(cornerRadius: BorderRadius.md)
                    .strokeBorder(
                        colorScheme == .dark ? DarkMode.border : LightMode.border,
                        lineWidth: 1
                    )
            }
        )
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionManager.shared)
}

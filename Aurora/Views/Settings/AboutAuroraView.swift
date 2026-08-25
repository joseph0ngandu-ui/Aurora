//
//  AboutAuroraView.swift
// Aurora
//
//  App information, support, and legal links
//

import SwiftUI

struct AboutAuroraView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        ZStack {
            AmbientBackgroundView(colorTheme: .settings)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with Logo
                    VStack(spacing: 16) {
                        // Aurora Logo
                        // Aurora Logo
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .shadow(color: AuroraColors.lime.opacity(0.3), radius: 15, x: 0, y: 5)
                            .padding(.top, 20)

                        Text("Aurora")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("Automated Trading Intelligence")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)

                        Text("Version \(appVersion) (\(buildNumber))")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AuroraColors.lime)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AuroraColors.lime.opacity(0.1))
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)

                    // What's New
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(AuroraColors.gold)
                                .font(.system(size: 18))

                            Text("What's New")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 12) {
                            ChangelogItem(
                                version: "1.0.0",
                                items: [
                                    "Modular settings hub with dedicated pages",
                                    "Enhanced theme customization",
                                    "Improved bot behavior controls",
                                    "New security features with biometric auth",
                                ]
                            )
                        }
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

                    // Support & Resources
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Support & Resources")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        AboutLinkItem(
                            icon: "envelope.fill",
                            title: "Email Support",
                            subtitle: "joseph.0.ngandu@icloud.com",
                            iconColor: AuroraColors.mint,
                            action: {
                                print("📧 Opening email...")
                            }
                        )

                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, 20)

                        AboutLinkItem(
                            icon: "book.fill",
                            title: "Documentation",
                            subtitle: "User guides and tutorials",
                            iconColor: AuroraColors.gold,
                            action: {
                                print("📚 Opening docs...")
                            }
                        )

                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, 20)

                        AboutLinkItem(
                            icon: "questionmark.circle.fill",
                            title: "FAQ",
                            subtitle: "Frequently asked questions",
                            iconColor: AuroraColors.lime,
                            action: {
                                print("❓ Opening FAQ...")
                            }
                        )
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

                    // Legal
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Legal")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        AboutLinkItem(
                            icon: "doc.text.fill",
                            title: "Terms of Service",
                            iconColor: .gray,
                            action: {
                                print("📄 Opening terms...")
                            }
                        )

                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, 20)

                        AboutLinkItem(
                            icon: "lock.shield.fill",
                            title: "Privacy Policy",
                            iconColor: .gray,
                            action: {
                                print("🔒 Opening privacy policy...")
                            }
                        )

                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, 20)

                        AboutLinkItem(
                            icon: "command",
                            title: "Open Source Licenses",
                            iconColor: .gray,
                            action: {
                                print("⚖️ Opening licenses...")
                            }
                        )
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

                    // Footer
                    VStack(spacing: 8) {
                        Text("Made with")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)

                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(Color.red)
                                .font(.system(size: 12))

                            Text("for traders")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }

                        Text("© 2025 Aurora AI. All rights reserved.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Changelog Item
struct ChangelogItem: View {
    let version: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("v\(version)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AuroraColors.lime)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(AuroraColors.lime)
                        .frame(width: 4, height: 4)
                        .padding(.top, 6)

                    Text(item)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
    }
}

// MARK: - About Link Item
struct AboutLinkItem: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.selection()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavigationStack {
        AboutAuroraView()
    }
}

//
//  ThemeAppearanceView.swift
// Aurora
//
//  Theme customization: dark/light mode, accent colors, glow intensity
//

import SwiftUI

struct ThemeAppearanceView: View {
    @ObservedObject var themeManager = ThemeManager.shared

    var body: some View {
        ZStack {
            AmbientBackgroundView(colorTheme: .settings)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Theme & Appearance")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Customize the visual style of Eden")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Theme Mode Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Color Scheme")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        HStack(spacing: 12) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                ThemeButton(
                                    title: theme.rawValue,
                                    isSelected: themeManager.colorScheme == theme,
                                    action: {
                                        withAnimation(SpringAnimations.snappy) {
                                            themeManager.updateColorScheme(theme)
                                            HapticFeedback.selection()
                                        }
                                    }
                                )
                            }
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

                    // Accent Color Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Accent Color")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        HStack(spacing: 16) {
                            ForEach(AccentColor.allCases, id: \.self) { accent in
                                AccentColorButton(
                                    color: accent.color,
                                    name: accent.rawValue,
                                    isSelected: themeManager.accentColor == accent,
                                    action: {
                                        withAnimation(SpringAnimations.snappy) {
                                            themeManager.updateAccentColor(accent)
                                            HapticFeedback.selection()
                                        }
                                    }
                                )
                            }
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

                    // Glow Intensity Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Glow Intensity")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Text("\(Int(themeManager.glowIntensity))%")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AuroraColors.lime)
                        }
                        .padding(.horizontal, 20)

                        Slider(value: $themeManager.glowIntensity, in: 0...100, step: 10)
                            .tint(AuroraColors.lime)
                            .padding(.horizontal, 20)
                            .onChange(of: themeManager.glowIntensity) { _, _ in
                                themeManager.saveSettings()
                            }
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

                    // Animation Speed Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Animation Speed")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Text(
                                themeManager.animationSpeed == 0.5
                                    ? "Slow"
                                    : themeManager.animationSpeed == 1.0 ? "Normal" : "Fast"
                            )
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AuroraColors.gold)
                        }
                        .padding(.horizontal, 20)

                        Slider(value: $themeManager.animationSpeed, in: 0.5...1.5, step: 0.5)
                            .tint(AuroraColors.gold)
                            .padding(.horizontal, 20)
                            .onChange(of: themeManager.animationSpeed) { _, _ in
                                themeManager.saveSettings()
                            }
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

                    // Preview Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preview")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        VStack(spacing: 12) {
                            HStack {
                                Circle()
                                    .fill(themeManager.currentAccent)
                                    .frame(width: 40, height: 40)
                                    .shadow(
                                        color: themeManager.currentAccent.opacity(
                                            themeManager.glowOpacity), radius: 12)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Aurora Trading Bot")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text("Active • \(themeManager.accentColor.rawValue) accent")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }

                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.08))
                            )
                        }
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

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Theme Button Component
struct ThemeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? AuroraColors.lime.opacity(0.2) : Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? AuroraColors.lime.opacity(0.5) : Color.white.opacity(0.1),
                            lineWidth: 1)
                )
        }
    }
}

// MARK: - Accent Color Button Component
struct AccentColorButton: View {
    let color: Color
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(
                                Color.white.opacity(isSelected ? 0.6 : 0.2),
                                lineWidth: isSelected ? 3 : 1)
                    )
                    .shadow(
                        color: color.opacity(isSelected ? 0.6 : 0.2), radius: isSelected ? 12 : 4)

                Text(name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .white : .gray)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ThemeAppearanceView()
    }
}

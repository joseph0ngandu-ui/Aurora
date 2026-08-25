//
//  ThemeManager.swift
// Aurora
//
//  Theme management system - handles app-wide theme state
//

import Combine
import SwiftUI

// MARK: - Enums

enum AppTheme: String, CaseIterable {
    case auto = "Auto"
    case dark = "Dark"
    case light = "Light"
}

enum AccentColor: String, CaseIterable {
    case lime = "Lime"
    case gold = "Gold"
    case mint = "Mint"
    case purple = "Purple"
    case blue = "Blue"

    var color: Color {
        switch self {
        case .lime: return AuroraColors.lime
        case .gold: return AuroraColors.gold
        case .mint: return AuroraColors.mint
        case .purple: return Color.purple
        case .blue: return Color.blue
        }
    }
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    // Published properties that the UI will react to
    @Published var colorScheme: AppTheme = .dark
    @Published var accentColor: AccentColor = .lime
    @Published var glowIntensity: Double = 50
    @Published var animationSpeed: Double = 1.0

    // Singleton instance
    static let shared = ThemeManager()

    private init() {
        loadSettings()
    }

    // MARK: - Computed Properties

    /// Get the current accent color as a SwiftUI Color
    var currentAccent: Color {
        accentColor.color
    }

    /// Get glow opacity based on intensity
    var glowOpacity: Double {
        glowIntensity / 100.0
    }

    /// Get animation duration multiplier
    var animationMultiplier: Double {
        animationSpeed
    }

    // MARK: - Settings Management

    func loadSettings() {
        // Load theme settings from UserDefaults
        if let savedScheme = UserDefaults.standard.string(forKey: "appTheme"),
            let scheme = AppTheme(rawValue: savedScheme)
        {
            colorScheme = scheme
        }

        if let savedAccent = UserDefaults.standard.string(forKey: "accentColor"),
            let accent = AccentColor(rawValue: savedAccent)
        {
            accentColor = accent
        }

        let savedGlow = UserDefaults.standard.double(forKey: "glowIntensity")
        if savedGlow > 0 {
            glowIntensity = savedGlow
        }

        let savedSpeed = UserDefaults.standard.double(forKey: "animationSpeed")
        if savedSpeed > 0 {
            animationSpeed = savedSpeed
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(colorScheme.rawValue, forKey: "appTheme")
        UserDefaults.standard.set(accentColor.rawValue, forKey: "accentColor")
        UserDefaults.standard.set(glowIntensity, forKey: "glowIntensity")
        UserDefaults.standard.set(animationSpeed, forKey: "animationSpeed")
    }

    // MARK: - Update Methods

    func updateColorScheme(_ scheme: AppTheme) {
        colorScheme = scheme
        saveSettings()
    }

    func updateAccentColor(_ color: AccentColor) {
        accentColor = color
        saveSettings()
    }

    func updateGlowIntensity(_ intensity: Double) {
        glowIntensity = intensity
        saveSettings()
    }

    func updateAnimationSpeed(_ speed: Double) {
        animationSpeed = speed
        saveSettings()
    }
}

// MARK: - Environment Key

private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

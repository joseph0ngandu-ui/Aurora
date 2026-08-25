//
//  GlassButton.swift
// Aurora - Redesigned
//
//  Premium glassmorphic button with multiple styles
//

import SwiftUI

struct GlassButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
    enum ButtonStyle {
        case primary, secondary, success, danger, ghost
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticFeedback.impact(.medium)
            action()
        }) {
            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(AuroraTypography.h6)
                }
                
                Text(title)
                    .font(AuroraTypography.labelLarge)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity)
            .background(buttonBackground)
            .foregroundColor(buttonForeground)
            .cornerRadius(BorderRadius.md)
            .shadow(color: shadowColor, radius: isPressed ? 8 : 16, x: 0, y: isPressed ? 2 : 4)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(SpringAnimations.snappy, value: isPressed)
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
    
    private var buttonBackground: some View {
        Group {
            switch style {
            case .primary:
                LinearGradient(
                    colors: [AuroraColors.lime, AuroraColors.mint],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .secondary:
                Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.1)
            case .success:
                LinearGradient(
                    colors: [SemanticColors.successPrimary, SemanticColors.successSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .danger:
                LinearGradient(
                    colors: [SemanticColors.errorPrimary, SemanticColors.errorSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .ghost:
                Color.clear
            }
        }
    }
    
    private var buttonForeground: Color {
        switch style {
        case .primary, .success, .danger:
            return .white
        case .secondary, .ghost:
            return colorScheme == .dark ? DarkMode.textPrimary : LightMode.textPrimary
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary, .success:
            return AuroraColors.lime.opacity(0.4)
        case .danger:
            return SemanticColors.errorPrimary.opacity(0.4)
        default:
            return .clear
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

#Preview {
    VStack(spacing: 16) {
        GlassButton("Primary Button", icon: "sparkles", style: .primary) {
            print("Primary tapped")
        }
        
        GlassButton("Secondary Button", icon: "gear", style: .secondary) {
            print("Secondary tapped")
        }
        
        GlassButton("Success Button", icon: "checkmark", style: .success) {
            print("Success tapped")
        }
        
        GlassButton("Danger Button", icon: "xmark", style: .danger) {
            print("Danger tapped")
        }
        
        GlassButton("Ghost Button", style: .ghost) {
            print("Ghost tapped")
        }
    }
    .padding()
    .background(DarkMode.primary)
}

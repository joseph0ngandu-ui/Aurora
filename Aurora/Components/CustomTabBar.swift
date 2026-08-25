//
//  CustomTabBar.swift
// Aurora - Redesigned
//
//  Floating glassmorphic tab bar with smooth animations
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    
    let tabs = [
        TabItem(icon: "chart.line.uptrend.xyaxis", text: "Overview", index: 0),
        TabItem(icon: "chart.bar.fill", text: "Positions", index: 1),
        TabItem(icon: "chart.pie.fill", text: "Analytics", index: 2),
        TabItem(icon: "sparkles", text: "Strategies", index: 3),
        TabItem(icon: "gearshape.fill", text: "Settings", index: 4)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab.index,
                    animation: animation
                ) {
                    withAnimation(SpringAnimations.snappy) {
                        selectedTab = tab.index
                    }
                    HapticFeedback.selection()
                }
            }
        }
        .padding(Spacing.xs)
        .background(tabBarBackground)
    }
    
    private var tabBarBackground: some View {
        ZStack {
            // Base background
            RoundedRectangle(cornerRadius: BorderRadius.xl)
                .fill(colorScheme == .dark ? DarkMode.secondary : LightMode.secondary)
            
            // Glass overlay
            RoundedRectangle(cornerRadius: BorderRadius.xl)
                .fill(colorScheme == .dark ? DarkMode.glass : LightMode.glass)
                .blur(radius: colorScheme == .dark ? DarkMode.glassBlur / 2 : LightMode.glassBlur)
            
            // Border
            RoundedRectangle(cornerRadius: BorderRadius.xl)
                .strokeBorder(
                    colorScheme == .dark ? DarkMode.border : LightMode.border,
                    lineWidth: 1
                )
        }
        .shadow(
            color: colorScheme == .dark ? .clear : LightMode.shadowColorStrong,
            radius: 24,
            x: 0,
            y: 8
        )
    }
}

struct TabItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    let index: Int
}

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                
                Text(tab.text)
                    .font(AuroraTypography.labelSmall)
            }
            .foregroundColor(isSelected ? .white : textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(
                ZStack {
                    if isSelected {
                        // Selected background with gradient
                        RoundedRectangle(cornerRadius: BorderRadius.md)
                            .fill(
                                LinearGradient(
                                    colors: [AuroraColors.lime, AuroraColors.mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "TAB", in: animation)
                            .shadow(
                                color: AuroraColors.lime.opacity(0.4),
                                radius: 12,
                                x: 0,
                                y: 4
                            )
                    }
                }
            )
        }
        .buttonStyle(TabButtonStyle())
    }
    
    private var textColor: Color {
        colorScheme == .dark ? DarkMode.textTertiary : LightMode.textTertiary
    }
}

struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(SpringAnimations.snappy, value: configuration.isPressed)
    }
}

#Preview {
    VStack {
        Spacer()
        
        CustomTabBar(selectedTab: .constant(0))
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)
    }
    .background(DarkMode.primary)
}

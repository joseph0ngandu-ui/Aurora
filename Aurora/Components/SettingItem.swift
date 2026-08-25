//
//  SettingItem.swift
// Aurora
//
//  Reusable settings list item with icon, title, subtitle, and chevron
//

import SwiftUI

struct SettingItem: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconColor: Color

    init(icon: String, title: String, subtitle: String? = nil, iconColor: Color = AuroraColors.lime) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [iconColor.opacity(0.3), iconColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            // Title and subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.6))
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
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack(spacing: 12) {
        SettingItem(
            icon: "chart.line.uptrend.xyaxis",
            title: "Trading Account",
            subtitle: "MetaTrader 5 configuration",
            iconColor: AuroraColors.lime
        )

        SettingItem(
            icon: "antenna.radiowaves.left.and.right",
            title: "API Connections",
            subtitle: "Server URLs and tokens",
            iconColor: AuroraColors.gold
        )

        SettingItem(
            icon: "bell.badge",
            title: "Notifications",
            iconColor: AuroraColors.mint
        )
    }
    .padding()
    .background(Color.black)
}

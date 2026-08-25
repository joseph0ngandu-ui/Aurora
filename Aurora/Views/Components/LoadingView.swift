//
//  LoadingView.swift
//  Aurora
//
//  Created for Aurora
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Glassmorphic Background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Animated Logo/Spinner
                ZStack {
                    // Outer Glow
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AuroraColors.lime.opacity(0.5),
                                    AuroraColors.mint.opacity(0.2),
                                    AuroraColors.lime.opacity(0.0),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 2.0).repeatForever(autoreverses: false),
                            value: isAnimating
                        )

                    // Inner Pulse
                    Circle()
                        .fill(AuroraColors.lime.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .opacity(isAnimating ? 0.6 : 0.3)
                        .animation(
                            Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: isAnimating
                        )

                    // Icon
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 30))
                        .foregroundColor(AuroraColors.lime)
                        .shadow(color: AuroraColors.lime, radius: 10)
                }

                // Text
                VStack(spacing: 8) {
                    Text("Connecting to Aurora")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Synchronizing market data...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ZStack {
        AmbientBackgroundView()
        LoadingView()
    }
}

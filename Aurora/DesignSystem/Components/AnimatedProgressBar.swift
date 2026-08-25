//
//  AnimatedProgressBar.swift
// Aurora - Redesigned
//
//  Smooth animated progress bar with gradient
//

import SwiftUI

struct AnimatedProgressBar: View {
    let progress: Double
    let colors: [Color]
    let height: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        colors: [Color] = [AuroraColors.lime, AuroraColors.mint],
        height: CGFloat = 8
    ) {
        self.progress = progress
        self.colors = colors
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)
                
                // Progress fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * animatedProgress,
                        height: height
                    )
                    .shadow(color: colors.first!.opacity(0.4), radius: 8, x: 0, y: 0)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.easeOut(duration: AnimationDuration.slow)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) {
            withAnimation(SpringAnimations.smooth) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Win Rate: 75%")
                .font(AuroraTypography.labelMedium)
            AnimatedProgressBar(progress: 0.75)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Confidence: 50%")
                .font(AuroraTypography.labelMedium)
            AnimatedProgressBar(
                progress: 0.5,
                colors: [AuroraColors.gold, AuroraColors.lime],
                height: 12
            )
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Risk Level: 30%")
                .font(AuroraTypography.labelMedium)
            AnimatedProgressBar(
                progress: 0.3,
                colors: [SemanticColors.errorPrimary, SemanticColors.warningPrimary],
                height: 6
            )
        }
    }
    .padding()
    .background(DarkMode.primary)
}

//
//  PulseIndicator.swift
// Aurora - Redesigned
//
//  Animated pulse indicator for active states
//

import SwiftUI

struct PulseIndicator: View {
    let color: Color
    let size: CGFloat
    
    @State private var isPulsing = false
    
    init(color: Color = AuroraColors.lime, size: CGFloat = 12) {
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Inner dot
            Circle()
                .fill(color)
                .frame(width: size, height: size)
            
            // Pulse rings
            Circle()
                .stroke(color.opacity(0.4), lineWidth: 2)
                .frame(width: size * 1.5, height: size * 1.5)
                .scaleEffect(isPulsing ? 1.5 : 1.0)
                .opacity(isPulsing ? 0 : 1)
            
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 1)
                .frame(width: size * 2, height: size * 2)
                .scaleEffect(isPulsing ? 2.0 : 1.0)
                .opacity(isPulsing ? 0 : 0.5)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    HStack(spacing: 32) {
        VStack(spacing: 8) {
            PulseIndicator(color: AuroraColors.lime, size: 12)
            Text("Active")
                .font(AuroraTypography.bodySmall)
        }
        
        VStack(spacing: 8) {
            PulseIndicator(color: SemanticColors.errorPrimary, size: 12)
            Text("Error")
                .font(AuroraTypography.bodySmall)
        }
        
        VStack(spacing: 8) {
            PulseIndicator(color: AuroraColors.gold, size: 16)
            Text("Warning")
                .font(AuroraTypography.bodySmall)
        }
    }
    .padding()
    .background(DarkMode.primary)
}

//
//  BalanceCardView.swift
// Aurora
//
//  Displays account balance and P&L stats.
//  Moved out of HeaderView for better layout control.
//

import SwiftUI

struct BalanceCardView: View {
    @EnvironmentObject var botManager: BotManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var balanceVisible = true
    @State private var displayBalance: Double = 0
    @State private var displayDailyPnL: Double = 0
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Balance Header
            HStack {
                Text("Account Balance")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(textSecondary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(SpringAnimations.snappy) {
                        balanceVisible.toggle()
                    }
                    HapticFeedback.selection()
                }) {
                    Image(systemName: balanceVisible ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 14))
                        .foregroundColor(textTertiary)
                }
            }
            
            // Balance Amount
            Text(balanceVisible ? "$\(displayBalance, specifier: "%.2f")" : "••••••")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(balanceGradient)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Daily P&L and Total Return
            HStack(spacing: Spacing.md) {
                // Daily P&L
                HStack(spacing: 4) {
                    Image(systemName: displayDailyPnL >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 11, weight: .bold))
                    
                    Text("\(displayDailyPnL >= 0 ? "+" : "")\(displayDailyPnL, specifier: "%.2f")")
                        .font(.system(size: 13, weight: .semibold))
                    
                    Text("today")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textTertiary)
                }
                .foregroundColor(displayDailyPnL >= 0 ? SemanticColors.successPrimary : SemanticColors.errorPrimary)
                
                Text("•")
                    .font(.system(size: 12))
                    .foregroundColor(textTertiary)
                
                // Total Return
                HStack(spacing: 4) {
                    Text("\(botManager.totalReturn, specifier: "%.1f")%")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AuroraColors.forest)
                    
                    Text("total")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textTertiary)
                }
            }
            .frame(height: 24)
        }
        .padding(Spacing.md)
        .background(glassBackground)
        .onAppear {
            animateNumbers()
        }
        // Use the iOS 17 onChange variant with two parameters (oldValue, newValue)
        .onChange(of: botManager.balance) { _, _ in
            animateNumbers()
        }
    }
    
    // MARK: - Computed Properties
    
    private var textSecondary: Color {
        colorScheme == .dark ? DarkMode.textSecondary : LightMode.textSecondary
    }
    
    private var textTertiary: Color {
        colorScheme == .dark ? DarkMode.textTertiary : LightMode.textTertiary
    }
    
    private var balanceGradient: LinearGradient {
        LinearGradient(
            colors: [SemanticColors.successPrimary, SemanticColors.successSecondary],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var glassBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: BorderRadius.lg)
                .fill(colorScheme == .dark ? DarkMode.secondary : LightMode.secondary)
            
            RoundedRectangle(cornerRadius: BorderRadius.lg)
                .fill(colorScheme == .dark ? DarkMode.glass : LightMode.glass)
                .blur(radius: colorScheme == .dark ? DarkMode.glassBlur : LightMode.glassBlur)
            
            RoundedRectangle(cornerRadius: BorderRadius.lg)
                .strokeBorder(
                    colorScheme == .dark ? DarkMode.border : LightMode.border,
                    lineWidth: 1
                )
        }
    }
    
    // MARK: - Animations
    
    private func animateNumbers() {
        // Animate balance
        let startBalance = displayBalance
        let endBalance = botManager.balance
        let balanceSteps = 30
        
        for i in 0...balanceSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                displayBalance = startBalance + (endBalance - startBalance) * (Double(i) / Double(balanceSteps))
            }
        }
        
        // Animate daily P&L
        let startPnL = displayDailyPnL
        let endPnL = botManager.dailyPnL
        
        for i in 0...balanceSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                displayDailyPnL = startPnL + (endPnL - startPnL) * (Double(i) / Double(balanceSteps))
            }
        }
    }
}

#Preview {
    BalanceCardView()
        .environmentObject(BotManager())
        .padding()
        .background(Color.black)
}

import SwiftUI

struct BudgetProgressCard: View {
    let budget: Budget
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text(budget.category.rawValue)
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                // Status Icon
                Image(systemName: budget.status.icon)
                    .font(.title3)
                    .foregroundColor(budget.status.color)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(budget.status.color)
                            .frame(
                                width: geometry.size.width * min(budget.spentPercentage, 1.0),
                                height: 8
                            )
                            .animation(.easeInOut(duration: 0.3), value: budget.spentPercentage)
                    }
                }
                .frame(height: 8)
                
                // Amount Information
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Spent")
                            .font(.caption2)
                            .foregroundColor(themeManager.secondaryText)
                        
                        Text(formatCurrency(budget.spentAmount))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.primaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Remaining")
                            .font(.caption2)
                            .foregroundColor(themeManager.secondaryText)
                        
                        Text(formatCurrency(budget.remainingAmount))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(budget.remainingAmount >= 0 ? themeManager.accentGreen : .red)
                    }
                }
            }
            
            // Progress Percentage
            HStack {
                Text("\(Int(budget.spentPercentage * 100))% of \(formatCurrency(budget.budgetAmount)) budget")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
                
                Spacer()
                
                if budget.spentPercentage >= 0.8 {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundColor(budget.status.color)
                        
                        Text(budget.spentPercentage >= 1.0 ? "Over budget" : "Nearly exceeded")
                            .font(.caption2)
                            .foregroundColor(budget.status.color)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

#Preview {
    let sampleBudget = Budget(
        name: "Food & Dining",
        category: .food,
        budgetAmount: 500.00,
        period: .monthly
    )
    // Simulate some spending
    var budget = sampleBudget
    budget.spentAmount = 425.00
    
    return BudgetProgressCard(budget: budget)
        .environmentObject(ThemeManager())
        .padding()
}
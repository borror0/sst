import SwiftUI

struct GoalProgressCard: View {
    let goal: FinancialGoal
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with icon and status
            HStack {
                ZStack {
                    Circle()
                        .fill(goal.category.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: goal.category.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(goal.category.color)
                }
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(themeManager.accentGreen)
                }
            }
            
            // Goal Details
            VStack(alignment: .leading, spacing: 8) {
                Text(goal.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(goal.description)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(
                        goal.category.color,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: goal.progress)
                
                VStack(spacing: 2) {
                    Text("\(Int(goal.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("Complete")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryText)
                }
            }
            
            // Amount Progress
            VStack(spacing: 4) {
                HStack {
                    Text("Current")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryText)
                    
                    Spacer()
                    
                    Text("Target")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryText)
                }
                
                HStack {
                    Text(formatCurrency(goal.currentAmount))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryText)
                    
                    Spacer()
                    
                    Text(formatCurrency(goal.targetAmount))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryText)
                }
            }
            
            // Days Remaining
            if !goal.isCompleted {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                    
                    Text("\(goal.daysRemaining) days remaining")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                    
                    Spacer()
                }
            }
            
            // Action Button
            Button(action: {
                // Navigate to goal details or contribution
            }) {
                Text(goal.isCompleted ? "View Details" : "Contribute")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(goal.category.color)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
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
    let sampleGoal = FinancialGoal(
        name: "Emergency Fund",
        description: "6 months of expenses saved",
        targetAmount: 20000.00,
        targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
        category: .emergency,
        currentAmount: 8500.00
    )
    
    return GoalProgressCard(goal: sampleGoal)
        .environmentObject(ThemeManager())
        .padding()
}
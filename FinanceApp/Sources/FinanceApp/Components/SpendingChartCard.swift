import SwiftUI

struct SpendingChartCard: View {
    let spendingData: [TransactionCategory: Double]
    let timeFrame: String
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var totalSpending: Double {
        spendingData.values.reduce(0, +)
    }
    
    private var topCategories: [(category: TransactionCategory, amount: Double)] {
        spendingData
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (category: $0.key, amount: $0.value) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Spending Breakdown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
                
                Text(timeFrame)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
            }
            
            if totalSpending > 0 {
                HStack(spacing: 20) {
                    // Donut Chart
                    DonutChart(data: spendingData)
                        .frame(width: 120, height: 120)
                    
                    // Category List
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(topCategories, id: \.category) { item in
                            CategoryRow(
                                category: item.category,
                                amount: item.amount,
                                percentage: item.amount / totalSpending
                            )
                        }
                    }
                    
                    Spacer()
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.secondaryText.opacity(0.5))
                    
                    Text("No spending data for this period")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
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
}

struct CategoryRow: View {
    let category: TransactionCategory
    let amount: Double
    let percentage: Double
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(category.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.caption)
                    .foregroundColor(themeManager.primaryText)
                
                Text(formatCurrency(amount))
                    .font(.caption2)
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            Text("\(Int(percentage * 100))%")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(themeManager.secondaryText)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct DonutChart: View {
    let data: [TransactionCategory: Double]
    @EnvironmentObject var themeManager: ThemeManager
    
    private var total: Double {
        data.values.reduce(0, +)
    }
    
    private var angles: [(category: TransactionCategory, startAngle: Angle, endAngle: Angle)] {
        var currentAngle: Double = 0
        var result: [(category: TransactionCategory, startAngle: Angle, endAngle: Angle)] = []
        
        for (category, amount) in data.sorted(by: { $0.value > $1.value }) {
            let percentage = amount / total
            let angle = percentage * 360
            
            result.append((
                category: category,
                startAngle: Angle(degrees: currentAngle),
                endAngle: Angle(degrees: currentAngle + angle)
            ))
            
            currentAngle += angle
        }
        
        return result
    }
    
    var body: some View {
        ZStack {
            ForEach(angles, id: \.category) { item in
                Path { path in
                    let center = CGPoint(x: 60, y: 60)
                    path.addArc(
                        center: center,
                        radius: 50,
                        startAngle: item.startAngle,
                        endAngle: item.endAngle,
                        clockwise: false
                    )
                    path.addArc(
                        center: center,
                        radius: 25,
                        startAngle: item.endAngle,
                        endAngle: item.startAngle,
                        clockwise: true
                    )
                    path.closeSubpath()
                }
                .fill(item.category.color)
            }
            
            // Center circle
            Circle()
                .fill(themeManager.backgroundColor)
                .frame(width: 50, height: 50)
            
            // Total amount
            VStack(spacing: 2) {
                Text("Total")
                    .font(.caption2)
                    .foregroundColor(themeManager.secondaryText)
                
                Text(formatCurrency(total))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primaryText)
            }
        }
        .frame(width: 120, height: 120)
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
    let sampleData: [TransactionCategory: Double] = [
        .food: 450.00,
        .transportation: 230.00,
        .entertainment: 120.00,
        .shopping: 89.00,
        .bills: 800.00
    ]
    
    return SpendingChartCard(
        spendingData: sampleData,
        timeFrame: "This Month"
    )
    .environmentObject(ThemeManager())
    .padding()
}
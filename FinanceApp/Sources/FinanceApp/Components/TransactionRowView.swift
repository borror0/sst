import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(transaction.category.color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: transaction.category.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(transaction.category.color)
            }
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(transaction.category.rawValue)
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryText)
                    
                    if let account = transaction.account {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                        
                        Text(account.name)
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                    }
                }
            }
            
            Spacer()
            
            // Amount and Date
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatAmount(transaction.amount, isIncome: transaction.isIncome))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.isIncome ? themeManager.accentGreen : themeManager.primaryText)
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
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
    
    private func formatAmount(_ amount: Double, isIncome: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
        return isIncome ? "+\(formattedAmount)" : "-\(formattedAmount)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleAccount = Account(
        name: "Chase Checking",
        type: .checking,
        balance: 2500.00
    )
    
    let sampleTransaction = Transaction(
        amount: 45.99,
        description: "Grocery Store",
        category: .food,
        account: sampleAccount
    )
    
    return TransactionRowView(transaction: sampleTransaction)
        .environmentObject(ThemeManager())
        .padding()
}
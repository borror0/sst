import Foundation
import SwiftUI

struct Budget: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var category: TransactionCategory
    var budgetAmount: Double
    var spentAmount: Double
    var period: BudgetPeriod
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var alerts: [BudgetAlert]
    
    init(
        name: String,
        category: TransactionCategory,
        budgetAmount: Double,
        period: BudgetPeriod,
        startDate: Date = Date()
    ) {
        self.name = name
        self.category = category
        self.budgetAmount = budgetAmount
        self.spentAmount = 0
        self.period = period
        self.startDate = startDate
        self.endDate = period.endDate(from: startDate)
        self.isActive = true
        self.alerts = []
    }
    
    var remainingAmount: Double {
        budgetAmount - spentAmount
    }
    
    var spentPercentage: Double {
        guard budgetAmount > 0 else { return 0 }
        return min(spentAmount / budgetAmount, 1.0)
    }
    
    var status: BudgetStatus {
        let percentage = spentPercentage
        if percentage >= 1.0 {
            return .exceeded
        } else if percentage >= 0.8 {
            return .warning
        } else {
            return .onTrack
        }
    }
}

enum BudgetPeriod: String, CaseIterable, Codable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    
    func endDate(from startDate: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: startDate) ?? startDate
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        }
    }
}

enum BudgetStatus {
    case onTrack
    case warning
    case exceeded
    
    var color: Color {
        switch self {
        case .onTrack: return Color("AccentGreen")
        case .warning: return Color("AccentOrange")
        case .exceeded: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .onTrack: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .exceeded: return "xmark.circle.fill"
        }
    }
}

struct BudgetAlert: Identifiable, Codable, Hashable {
    let id = UUID()
    var threshold: Double
    var isEnabled: Bool
    var message: String
    
    init(threshold: Double, message: String) {
        self.threshold = threshold
        self.isEnabled = true
        self.message = message
    }
}
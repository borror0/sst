import Foundation
import SwiftUI

struct FinancialGoal: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var description: String
    var targetAmount: Double
    var currentAmount: Double
    var targetDate: Date
    var category: GoalCategory
    var isCompleted: Bool
    var createdDate: Date
    var milestones: [GoalMilestone]
    var autoSaveAmount: Double?
    var autoSaveFrequency: RecurringFrequency?
    
    init(
        name: String,
        description: String,
        targetAmount: Double,
        targetDate: Date,
        category: GoalCategory,
        currentAmount: Double = 0
    ) {
        self.name = name
        self.description = description
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.category = category
        self.isCompleted = false
        self.createdDate = Date()
        self.milestones = []
        self.autoSaveAmount = nil
        self.autoSaveFrequency = nil
    }
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    var remainingAmount: Double {
        max(targetAmount - currentAmount, 0)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    }
    
    var recommendedMonthlyContribution: Double {
        let monthsRemaining = max(Double(daysRemaining) / 30.0, 1.0)
        return remainingAmount / monthsRemaining
    }
}

enum GoalCategory: String, CaseIterable, Codable {
    case emergency = "Emergency Fund"
    case vacation = "Vacation"
    case home = "Home Purchase"
    case car = "Car Purchase"
    case education = "Education"
    case retirement = "Retirement"
    case debt = "Debt Payment"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .emergency: return "shield.fill"
        case .vacation: return "airplane"
        case .home: return "house.fill"
        case .car: return "car.fill"
        case .education: return "graduationcap.fill"
        case .retirement: return "person.crop.circle.fill"
        case .debt: return "creditcard.fill"
        case .other: return "target"
        }
    }
    
    var color: Color {
        switch self {
        case .emergency: return .red
        case .vacation: return .blue
        case .home: return .green
        case .car: return .orange
        case .education: return .purple
        case .retirement: return .indigo
        case .debt: return .pink
        case .other: return .gray
        }
    }
}

struct GoalMilestone: Identifiable, Codable, Hashable {
    let id = UUID()
    var amount: Double
    var achievedDate: Date?
    var description: String
    
    init(amount: Double, description: String) {
        self.amount = amount
        self.description = description
        self.achievedDate = nil
    }
    
    var isAchieved: Bool {
        achievedDate != nil
    }
}
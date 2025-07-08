import Foundation
import SwiftUI

struct Transaction: Identifiable, Codable, Hashable {
    let id = UUID()
    var amount: Double
    var description: String
    var category: TransactionCategory
    var date: Date
    var account: Account?
    var tags: [String]
    var isRecurring: Bool
    var recurringFrequency: RecurringFrequency?
    var location: String?
    var receiptImage: Data?
    var isIncome: Bool
    var subcategory: String?
    
    init(
        amount: Double,
        description: String,
        category: TransactionCategory,
        date: Date = Date(),
        account: Account? = nil,
        tags: [String] = [],
        isRecurring: Bool = false,
        recurringFrequency: RecurringFrequency? = nil,
        location: String? = nil,
        receiptImage: Data? = nil,
        isIncome: Bool = false,
        subcategory: String? = nil
    ) {
        self.amount = amount
        self.description = description
        self.category = category
        self.date = date
        self.account = account
        self.tags = tags
        self.isRecurring = isRecurring
        self.recurringFrequency = recurringFrequency
        self.location = location
        self.receiptImage = receiptImage
        self.isIncome = isIncome
        self.subcategory = subcategory
    }
}

enum TransactionCategory: String, CaseIterable, Codable {
    case food = "Food & Dining"
    case transportation = "Transportation"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case bills = "Bills & Utilities"
    case healthcare = "Healthcare"
    case education = "Education"
    case travel = "Travel"
    case income = "Income"
    case savings = "Savings"
    case investment = "Investment"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "gamecontroller.fill"
        case .bills: return "doc.text.fill"
        case .healthcare: return "cross.fill"
        case .education: return "book.fill"
        case .travel: return "airplane"
        case .income: return "plus.circle.fill"
        case .savings: return "banknote.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transportation: return .blue
        case .shopping: return .pink
        case .entertainment: return .purple
        case .bills: return .red
        case .healthcare: return .green
        case .education: return .indigo
        case .travel: return .cyan
        case .income: return Color("AccentGreen")
        case .savings: return Color("AccentGreen")
        case .investment: return .yellow
        case .other: return .gray
        }
    }
}

enum RecurringFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
}
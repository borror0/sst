import Foundation
import SwiftUI

struct Account: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var type: AccountType
    var balance: Double
    var institution: String?
    var accountNumber: String?
    var isActive: Bool
    var color: String
    var lastSyncDate: Date?
    
    init(
        name: String,
        type: AccountType,
        balance: Double,
        institution: String? = nil,
        accountNumber: String? = nil,
        isActive: Bool = true,
        color: String = "blue"
    ) {
        self.name = name
        self.type = type
        self.balance = balance
        self.institution = institution
        self.accountNumber = accountNumber
        self.isActive = isActive
        self.color = color
        self.lastSyncDate = Date()
    }
}

enum AccountType: String, CaseIterable, Codable {
    case checking = "Checking"
    case savings = "Savings"
    case credit = "Credit Card"
    case investment = "Investment"
    case loan = "Loan"
    case cash = "Cash"
    
    var icon: String {
        switch self {
        case .checking: return "banknote.fill"
        case .savings: return "dollarsign.circle.fill"
        case .credit: return "creditcard.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .loan: return "house.fill"
        case .cash: return "dollarsign.square.fill"
        }
    }
}
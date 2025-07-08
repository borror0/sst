import Foundation
import Combine
import CoreData

class DataManager: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var accounts: [Account] = []
    @Published var budgets: [Budget] = []
    @Published var financialGoals: [FinancialGoal] = []
    @Published var isLoading = false
    @Published var lastSyncDate: Date?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FinanceApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    init() {
        loadData()
        setupAutoSave()
    }
    
    // MARK: - Data Loading
    func loadData() {
        isLoading = true
        
        // Load from Core Data or create sample data if empty
        if transactions.isEmpty {
            loadSampleData()
        }
        
        isLoading = false
    }
    
    // MARK: - Transaction Management
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        updateBudgetsForTransaction(transaction)
        saveData()
    }
    
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            updateBudgetsForTransaction(transaction)
            saveData()
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        updateBudgetsForTransaction(transaction, isDelete: true)
        saveData()
    }
    
    // MARK: - Account Management
    func addAccount(_ account: Account) {
        accounts.append(account)
        saveData()
    }
    
    func updateAccount(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            saveData()
        }
    }
    
    func deleteAccount(_ account: Account) {
        accounts.removeAll { $0.id == account.id }
        // Also remove transactions associated with this account
        transactions = transactions.filter { $0.account?.id != account.id }
        saveData()
    }
    
    // MARK: - Budget Management
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        updateBudgetSpending(budget)
        saveData()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            updateBudgetSpending(budget)
            saveData()
        }
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveData()
    }
    
    // MARK: - Goal Management
    func addGoal(_ goal: FinancialGoal) {
        financialGoals.append(goal)
        saveData()
    }
    
    func updateGoal(_ goal: FinancialGoal) {
        if let index = financialGoals.firstIndex(where: { $0.id == goal.id }) {
            financialGoals[index] = goal
            saveData()
        }
    }
    
    func deleteGoal(_ goal: FinancialGoal) {
        financialGoals.removeAll { $0.id == goal.id }
        saveData()
    }
    
    func contributeToGoal(_ goalId: UUID, amount: Double) {
        if let index = financialGoals.firstIndex(where: { $0.id == goalId }) {
            financialGoals[index].currentAmount += amount
            
            // Check if goal is completed
            if financialGoals[index].currentAmount >= financialGoals[index].targetAmount {
                financialGoals[index].isCompleted = true
            }
            
            saveData()
        }
    }
    
    // MARK: - Analytics
    func getSpendingByCategory(for period: DateInterval) -> [TransactionCategory: Double] {
        let filteredTransactions = transactions.filter { transaction in
            !transaction.isIncome && period.contains(transaction.date)
        }
        
        var spending: [TransactionCategory: Double] = [:]
        for transaction in filteredTransactions {
            spending[transaction.category, default: 0] += transaction.amount
        }
        
        return spending
    }
    
    func getMonthlySpendingTrend() -> [Date: Double] {
        let calendar = Calendar.current
        var monthlySpending: [Date: Double] = [:]
        
        for transaction in transactions.filter({ !$0.isIncome }) {
            let monthStart = calendar.dateInterval(of: .month, for: transaction.date)?.start ?? transaction.date
            monthlySpending[monthStart, default: 0] += transaction.amount
        }
        
        return monthlySpending
    }
    
    // MARK: - Helper Methods
    private func updateBudgetsForTransaction(_ transaction: Transaction, isDelete: Bool = false) {
        for index in budgets.indices {
            if budgets[index].category == transaction.category && budgets[index].isActive {
                let amount = isDelete ? -transaction.amount : transaction.amount
                budgets[index].spentAmount += amount
            }
        }
    }
    
    private func updateBudgetSpending(_ budget: Budget) {
        let categoryTransactions = transactions.filter { transaction in
            transaction.category == budget.category &&
            transaction.date >= budget.startDate &&
            transaction.date <= budget.endDate &&
            !transaction.isIncome
        }
        
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index].spentAmount = categoryTransactions.reduce(0) { $0 + $1.amount }
        }
    }
    
    private func saveData() {
        do {
            try context.save()
            lastSyncDate = Date()
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    private func setupAutoSave() {
        // Auto-save every 30 seconds
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.saveData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Sample Data
    private func loadSampleData() {
        // Sample Accounts
        let checkingAccount = Account(
            name: "Chase Checking",
            type: .checking,
            balance: 2500.00,
            institution: "Chase Bank"
        )
        
        let savingsAccount = Account(
            name: "High Yield Savings",
            type: .savings,
            balance: 15000.00,
            institution: "Marcus by Goldman Sachs"
        )
        
        accounts = [checkingAccount, savingsAccount]
        
        // Sample Transactions
        let sampleTransactions = [
            Transaction(amount: 45.99, description: "Grocery Store", category: .food, account: checkingAccount),
            Transaction(amount: 15.00, description: "Coffee Shop", category: .food, account: checkingAccount),
            Transaction(amount: 89.99, description: "Gas Station", category: .transportation, account: checkingAccount),
            Transaction(amount: 1200.00, description: "Rent Payment", category: .bills, account: checkingAccount),
            Transaction(amount: 3000.00, description: "Salary", category: .income, account: checkingAccount, isIncome: true)
        ]
        
        transactions = sampleTransactions
        
        // Sample Budgets
        let foodBudget = Budget(
            name: "Food & Dining",
            category: .food,
            budgetAmount: 500.00,
            period: .monthly
        )
        
        let transportBudget = Budget(
            name: "Transportation",
            category: .transportation,
            budgetAmount: 300.00,
            period: .monthly
        )
        
        budgets = [foodBudget, transportBudget]
        
        // Sample Goals
        let emergencyFund = FinancialGoal(
            name: "Emergency Fund",
            description: "6 months of expenses",
            targetAmount: 20000.00,
            targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
            category: .emergency,
            currentAmount: 5000.00
        )
        
        let vacationGoal = FinancialGoal(
            name: "Europe Trip",
            description: "Dream vacation to Europe",
            targetAmount: 5000.00,
            targetDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()) ?? Date(),
            category: .vacation
        )
        
        financialGoals = [emergencyFund, vacationGoal]
        
        // Update budget spending based on transactions
        for budget in budgets {
            updateBudgetSpending(budget)
        }
        
        saveData()
    }
}
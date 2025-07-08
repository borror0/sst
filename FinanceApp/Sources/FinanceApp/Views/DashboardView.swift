import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTimeFrame: TimeFrame = .month
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header
                    headerView
                    
                    // Quick Stats Cards
                    quickStatsSection
                    
                    // Spending Chart
                    spendingChartSection
                    
                    // Recent Transactions
                    recentTransactionsSection
                    
                    // Budget Overview
                    budgetOverviewSection
                    
                    // Goals Progress
                    goalsProgressSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add transaction action
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.primaryBlue)
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Good morning!")
                        .font(.headline)
                        .foregroundColor(themeManager.secondaryText)
                    
                    Text("Here's your financial overview")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryText)
                }
                
                Spacer()
                
                // Time frame picker
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
        }
        .padding(.top, 10)
    }
    
    private var quickStatsSection: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                QuickStatCard(
                    title: "Total Balance",
                    value: formatCurrency(totalBalance),
                    icon: "banknote.fill",
                    color: themeManager.accentGreen
                )
                
                QuickStatCard(
                    title: "This Month",
                    value: formatCurrency(monthlySpending),
                    icon: "arrow.down.circle.fill",
                    color: .red
                )
            }
            
            HStack(spacing: 15) {
                QuickStatCard(
                    title: "Saved",
                    value: formatCurrency(monthlySavings),
                    icon: "arrow.up.circle.fill",
                    color: themeManager.accentGreen
                )
                
                QuickStatCard(
                    title: "Goals Progress",
                    value: "\(Int(goalsProgress * 100))%",
                    icon: "target",
                    color: themeManager.primaryBlue
                )
            }
        }
    }
    
    private var spendingChartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Spending by Category")
                .font(.headline)
                .foregroundColor(themeManager.primaryText)
            
            SpendingChartCard(
                spendingData: getSpendingData(),
                timeFrame: selectedTimeFrame.rawValue
            )
        }
    }
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
                
                NavigationLink("See All") {
                    TransactionsView()
                }
                .font(.subheadline)
                .foregroundColor(themeManager.primaryBlue)
            }
            
            LazyVStack(spacing: 10) {
                ForEach(recentTransactions, id: \.id) { transaction in
                    TransactionRowView(transaction: transaction)
                        .glassEffect()
                }
            }
        }
    }
    
    private var budgetOverviewSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Budget Overview")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
                
                NavigationLink("Manage") {
                    BudgetsView()
                }
                .font(.subheadline)
                .foregroundColor(themeManager.primaryBlue)
            }
            
            LazyVStack(spacing: 10) {
                ForEach(dataManager.budgets.prefix(3), id: \.id) { budget in
                    BudgetProgressCard(budget: budget)
                        .glassEffect()
                }
            }
        }
    }
    
    private var goalsProgressSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Financial Goals")
                    .font(.headline)
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
                
                NavigationLink("View All") {
                    GoalsView()
                }
                .font(.subheadline)
                .foregroundColor(themeManager.primaryBlue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(dataManager.financialGoals.prefix(3), id: \.id) { goal in
                        GoalProgressCard(goal: goal)
                            .frame(width: 200)
                            .glassEffect()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var totalBalance: Double {
        dataManager.accounts.reduce(0) { $0 + $1.balance }
    }
    
    private var monthlySpending: Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let endOfMonth = calendar.dateInterval(of: .month, for: Date())?.end ?? Date()
        
        return dataManager.transactions
            .filter { !$0.isIncome && $0.date >= startOfMonth && $0.date <= endOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var monthlySavings: Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let endOfMonth = calendar.dateInterval(of: .month, for: Date())?.end ?? Date()
        
        return dataManager.transactions
            .filter { $0.isIncome && $0.date >= startOfMonth && $0.date <= endOfMonth }
            .reduce(0) { $0 + $1.amount } - monthlySpending
    }
    
    private var goalsProgress: Double {
        guard !dataManager.financialGoals.isEmpty else { return 0 }
        let totalProgress = dataManager.financialGoals.reduce(0) { $0 + $1.progress }
        return totalProgress / Double(dataManager.financialGoals.count)
    }
    
    private var recentTransactions: [Transaction] {
        Array(dataManager.transactions.sorted { $0.date > $1.date }.prefix(5))
    }
    
    private func getSpendingData() -> [TransactionCategory: Double] {
        let calendar = Calendar.current
        let period: DateInterval
        
        switch selectedTimeFrame {
        case .week:
            period = calendar.dateInterval(of: .weekOfYear, for: Date()) ?? DateInterval()
        case .month:
            period = calendar.dateInterval(of: .month, for: Date()) ?? DateInterval()
        case .year:
            period = calendar.dateInterval(of: .year, for: Date()) ?? DateInterval()
        }
        
        return dataManager.getSpendingByCategory(for: period)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataManager())
        .environmentObject(ThemeManager())
}
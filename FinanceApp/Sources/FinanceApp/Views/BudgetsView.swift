import SwiftUI

struct BudgetsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Budget Overview Header
                    budgetOverviewHeader
                    
                    // Budget Cards
                    if dataManager.budgets.isEmpty {
                        emptyStateView
                    } else {
                        budgetsList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("Budgets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddBudget = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView()
            }
        }
    }
    
    private var budgetOverviewHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Budget Overview")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("Track your spending across categories")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
            }
            
            // Summary Cards
            HStack(spacing: 15) {
                BudgetSummaryCard(
                    title: "Total Budget",
                    value: formatCurrency(totalBudgetAmount),
                    icon: "banknote.fill",
                    color: themeManager.primaryBlue
                )
                
                BudgetSummaryCard(
                    title: "Total Spent",
                    value: formatCurrency(totalSpentAmount),
                    icon: "arrow.down.circle.fill",
                    color: .red
                )
                
                BudgetSummaryCard(
                    title: "Remaining",
                    value: formatCurrency(totalRemainingAmount),
                    icon: "dollarsign.circle.fill",
                    color: themeManager.accentGreen
                )
            }
        }
    }
    
    private var budgetsList: some View {
        VStack(spacing: 15) {
            ForEach(dataManager.budgets, id: \.id) { budget in
                BudgetProgressCard(budget: budget)
                    .contextMenu {
                        Button(action: {
                            // Edit budget
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            dataManager.deleteBudget(budget)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryText.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Budgets Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primaryText)
                
                Text("Create budgets to track your spending and stay on top of your finances.")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showingAddBudget = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Budget")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(themeManager.primaryBlue)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    // MARK: - Computed Properties
    private var totalBudgetAmount: Double {
        dataManager.budgets.reduce(0) { $0 + $1.budgetAmount }
    }
    
    private var totalSpentAmount: Double {
        dataManager.budgets.reduce(0) { $0 + $1.spentAmount }
    }
    
    private var totalRemainingAmount: Double {
        totalBudgetAmount - totalSpentAmount
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct BudgetSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryText)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct AddBudgetView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var budgetAmount = ""
    @State private var selectedCategory: TransactionCategory = .other
    @State private var selectedPeriod: BudgetPeriod = .monthly
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Budget Details")) {
                    TextField("Budget Name", text: $name)
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $budgetAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TransactionCategory.allCases.filter { $0 != .income }, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                }
                
                Section(footer: Text("Your budget will track spending in the selected category for the chosen time period.")) {
                    EmptyView()
                }
            }
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBudget()
                    }
                    .disabled(name.isEmpty || budgetAmount.isEmpty)
                }
            }
        }
    }
    
    private func saveBudget() {
        guard let amount = Double(budgetAmount) else { return }
        
        let budget = Budget(
            name: name,
            category: selectedCategory,
            budgetAmount: amount,
            period: selectedPeriod
        )
        
        dataManager.addBudget(budget)
        dismiss()
    }
}

#Preview {
    BudgetsView()
        .environmentObject(DataManager())
        .environmentObject(ThemeManager())
}
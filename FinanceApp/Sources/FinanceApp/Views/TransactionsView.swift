import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var searchText = ""
    @State private var selectedCategory: TransactionCategory? = nil
    @State private var showingAddTransaction = false
    @State private var sortOption: SortOption = .dateNewest
    
    enum SortOption: String, CaseIterable {
        case dateNewest = "Date (Newest)"
        case dateOldest = "Date (Oldest)"
        case amountHighest = "Amount (Highest)"
        case amountLowest = "Amount (Lowest)"
        case category = "Category"
    }
    
    private var filteredTransactions: [Transaction] {
        var transactions = dataManager.transactions
        
        // Filter by search text
        if !searchText.isEmpty {
            transactions = transactions.filter { transaction in
                transaction.description.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if let selectedCategory = selectedCategory {
            transactions = transactions.filter { $0.category == selectedCategory }
        }
        
        // Sort transactions
        switch sortOption {
        case .dateNewest:
            transactions.sort { $0.date > $1.date }
        case .dateOldest:
            transactions.sort { $0.date < $1.date }
        case .amountHighest:
            transactions.sort { $0.amount > $1.amount }
        case .amountLowest:
            transactions.sort { $0.amount < $1.amount }
        case .category:
            transactions.sort { $0.category.rawValue < $1.category.rawValue }
        }
        
        return transactions
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                searchAndFilterBar
                
                // Transactions List
                if filteredTransactions.isEmpty {
                    emptyStateView
                } else {
                    transactionsList
                }
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
        }
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.secondaryText)
                
                TextField("Search transactions...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeManager.secondaryText)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.cardBackground)
            )
            
            // Filter and Sort Controls
            HStack {
                // Category Filter
                Menu {
                    Button("All Categories") {
                        selectedCategory = nil
                    }
                    
                    Divider()
                    
                    ForEach(TransactionCategory.allCases, id: \.self) { category in
                        Button(category.rawValue) {
                            selectedCategory = category
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(selectedCategory?.rawValue ?? "All Categories")
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.primaryBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.primaryBlue.opacity(0.1))
                    )
                }
                
                Spacer()
                
                // Sort Options
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            sortOption = option
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortOption.rawValue)
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.primaryBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.primaryBlue.opacity(0.1))
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    private var transactionsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredTransactions, id: \.id) { transaction in
                    TransactionRowView(transaction: transaction)
                        .padding(.horizontal, 20)
                        .contextMenu {
                            Button(action: {
                                // Edit transaction
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: {
                                dataManager.deleteTransaction(transaction)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryText.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Transactions Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primaryText)
                
                Text(searchText.isEmpty ? "Start tracking your finances by adding your first transaction." : "Try adjusting your search or filters.")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showingAddTransaction = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Transaction")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(themeManager.primaryBlue)
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct AddTransactionView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var description = ""
    @State private var selectedCategory: TransactionCategory = .other
    @State private var selectedAccount: Account?
    @State private var date = Date()
    @State private var isIncome = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Details")) {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("Description", text: $description)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TransactionCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    if !dataManager.accounts.isEmpty {
                        Picker("Account", selection: $selectedAccount) {
                            Text("Select Account").tag(nil as Account?)
                            ForEach(dataManager.accounts, id: \.id) { account in
                                Text(account.name).tag(account as Account?)
                            }
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    Toggle("Income", isOn: $isIncome)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        let transaction = Transaction(
            amount: amountValue,
            description: description,
            category: selectedCategory,
            date: date,
            account: selectedAccount,
            isIncome: isIncome
        )
        
        dataManager.addTransaction(transaction)
        dismiss()
    }
}

#Preview {
    TransactionsView()
        .environmentObject(DataManager())
        .environmentObject(ThemeManager())
}
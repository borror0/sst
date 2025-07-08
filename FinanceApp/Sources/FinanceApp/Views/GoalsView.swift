import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddGoal = false
    @State private var selectedGoal: FinancialGoal?
    @State private var showingContribution = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Goals Overview Header
                    goalsOverviewHeader
                    
                    // Goals List
                    if dataManager.financialGoals.isEmpty {
                        emptyStateView
                    } else {
                        goalsList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGoal = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
            .sheet(isPresented: $showingContribution) {
                if let goal = selectedGoal {
                    ContributeToGoalView(goal: goal)
                }
            }
        }
    }
    
    private var goalsOverviewHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Financial Goals")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("Track progress towards your financial milestones")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
            }
            
            // Summary Cards
            HStack(spacing: 15) {
                GoalSummaryCard(
                    title: "Active Goals",
                    value: "\(activeGoalsCount)",
                    icon: "target",
                    color: themeManager.primaryBlue
                )
                
                GoalSummaryCard(
                    title: "Total Saved",
                    value: formatCurrency(totalSavedAmount),
                    icon: "banknote.fill",
                    color: themeManager.accentGreen
                )
                
                GoalSummaryCard(
                    title: "Avg Progress",
                    value: "\(Int(averageProgress * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: themeManager.accentOrange
                )
            }
        }
    }
    
    private var goalsList: some View {
        VStack(spacing: 15) {
            ForEach(dataManager.financialGoals, id: \.id) { goal in
                GoalCard(goal: goal) {
                    selectedGoal = goal
                    showingContribution = true
                }
                .contextMenu {
                    Button(action: {
                        selectedGoal = goal
                        showingContribution = true
                    }) {
                        Label("Contribute", systemImage: "plus.circle")
                    }
                    
                    Button(action: {
                        // Edit goal
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        dataManager.deleteGoal(goal)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryText.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Goals Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primaryText)
                
                Text("Set financial goals to stay motivated and track your progress towards important milestones.")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showingAddGoal = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Goal")
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
    private var activeGoalsCount: Int {
        dataManager.financialGoals.filter { !$0.isCompleted }.count
    }
    
    private var totalSavedAmount: Double {
        dataManager.financialGoals.reduce(0) { $0 + $1.currentAmount }
    }
    
    private var averageProgress: Double {
        guard !dataManager.financialGoals.isEmpty else { return 0 }
        let totalProgress = dataManager.financialGoals.reduce(0) { $0 + $1.progress }
        return totalProgress / Double(dataManager.financialGoals.count)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct GoalCard: View {
    let goal: FinancialGoal
    let onContribute: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryText)
                    
                    Text(goal.description)
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(goal.category.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: goal.category.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(goal.category.color)
                }
            }
            
            // Progress Section
            VStack(spacing: 12) {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 16)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(goal.category.color)
                            .frame(
                                width: geometry.size.width * goal.progress,
                                height: 16
                            )
                            .animation(.easeInOut(duration: 0.3), value: goal.progress)
                    }
                }
                .frame(height: 16)
                
                // Progress Details
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                        
                        Text(formatCurrency(goal.currentAmount))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.primaryText)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("\(Int(goal.progress * 100))%")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(goal.category.color)
                        
                        Text("Complete")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Target")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                        
                        Text(formatCurrency(goal.targetAmount))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.primaryText)
                    }
                }
            }
            
            // Footer with days remaining and action
            HStack {
                if !goal.isCompleted {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(goal.daysRemaining) days remaining")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryText)
                        
                        Text("Suggested: \(formatCurrency(goal.recommendedMonthlyContribution))/month")
                            .font(.caption2)
                            .foregroundColor(themeManager.secondaryText)
                    }
                }
                
                Spacer()
                
                Button(action: onContribute) {
                    Text(goal.isCompleted ? "Completed!" : "Contribute")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(goal.isCompleted ? themeManager.accentGreen : goal.category.color)
                        .cornerRadius(8)
                }
                .disabled(goal.isCompleted)
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
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct GoalSummaryCard: View {
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

struct AddGoalView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var targetAmount = ""
    @State private var targetDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var selectedCategory: GoalCategory = .other
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Name", text: $name)
                    TextField("Description", text: $description)
                    
                    HStack {
                        Text("Target Amount")
                        Spacer()
                        TextField("0.00", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Target Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(GoalCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(name.isEmpty || targetAmount.isEmpty)
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let amount = Double(targetAmount) else { return }
        
        let goal = FinancialGoal(
            name: name,
            description: description,
            targetAmount: amount,
            targetDate: targetDate,
            category: selectedCategory
        )
        
        dataManager.addGoal(goal)
        dismiss()
    }
}

struct ContributeToGoalView: View {
    let goal: FinancialGoal
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var contributionAmount = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Goal Info
                VStack(spacing: 12) {
                    Text(goal.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Current: \(formatCurrency(goal.currentAmount)) of \(formatCurrency(goal.targetAmount))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Contribution Input
                VStack(spacing: 12) {
                    Text("Contribution Amount")
                        .font(.headline)
                    
                    TextField("0.00", text: $contributionAmount)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Button
                Button(action: {
                    contributeToGoal()
                }) {
                    Text("Contribute")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(goal.category.color)
                        .cornerRadius(12)
                }
                .disabled(contributionAmount.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Contribute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func contributeToGoal() {
        guard let amount = Double(contributionAmount) else { return }
        dataManager.contributeToGoal(goal.id, amount: amount)
        dismiss()
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

#Preview {
    GoalsView()
        .environmentObject(DataManager())
        .environmentObject(ThemeManager())
}
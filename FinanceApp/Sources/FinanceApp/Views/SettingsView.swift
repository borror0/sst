import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(themeManager.primaryBlueGradient)
                                .frame(width: 60, height: 60)
                            
                            Text("JD")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("John Doe")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryText)
                            
                            Text("Premium Member")
                                .font(.subheadline)
                                .foregroundColor(themeManager.accentGreen)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Edit")
                                .font(.subheadline)
                                .foregroundColor(themeManager.primaryBlue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Security Section
                Section("Security") {
                    HStack {
                        Image(systemName: authManager.biometricType.icon)
                            .foregroundColor(themeManager.primaryBlue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(authManager.biometricType.displayName)
                                .font(.subheadline)
                            Text("Secure app access")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryText)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { authManager.isAuthenticationRequired },
                            set: { authManager.enableAuthentication($0) }
                        ))
                    }
                    
                    NavigationLink(destination: SecuritySettingsView()) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(themeManager.primaryBlue)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Privacy & Security")
                                    .font(.subheadline)
                                Text("Manage data protection")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryText)
                            }
                        }
                    }
                }
                
                // Appearance Section
                Section("Appearance") {
                    HStack {
                        Image(systemName: "paintbrush")
                            .foregroundColor(themeManager.primaryBlue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Theme")
                                .font(.subheadline)
                            Text(themeManager.useSystemTheme ? "System" : (themeManager.isDarkMode ? "Dark" : "Light"))
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryText)
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button("System") {
                                themeManager.enableSystemTheme()
                            }
                            Button("Light") {
                                themeManager.useSystemTheme = false
                                themeManager.isDarkMode = false
                                themeManager.saveSettings()
                            }
                            Button("Dark") {
                                themeManager.useSystemTheme = false
                                themeManager.isDarkMode = true
                                themeManager.saveSettings()
                            }
                        } label: {
                            Text("Change")
                                .font(.subheadline)
                                .foregroundColor(themeManager.primaryBlue)
                        }
                    }
                }
                
                // Data Section
                Section("Data Management") {
                    NavigationLink(destination: DataManagementView()) {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(themeManager.primaryBlue)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sync & Backup")
                                    .font(.subheadline)
                                Text("Last sync: \(formatDate(dataManager.lastSyncDate))")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryText)
                            }
                        }
                    }
                    
                    NavigationLink(destination: ExportDataView()) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(themeManager.primaryBlue)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Export Data")
                                    .font(.subheadline)
                                Text("Download your financial data")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryText)
                            }
                        }
                    }
                }
                
                // Premium Section
                Section("Premium Features") {
                    NavigationLink(destination: PremiumView()) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Upgrade to Premium")
                                    .font(.subheadline)
                                Text("Unlock advanced features")
                                    .font(.caption)
                                    .foregroundColor(themeManager.secondaryText)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryText)
                        }
                    }
                }
                
                // Support Section
                Section("Support") {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(themeManager.primaryBlue)
                                .frame(width: 24, height: 24)
                            
                            Text("Help & Support")
                                .font(.subheadline)
                                .foregroundColor(themeManager.primaryText)
                            
                            Spacer()
                        }
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(themeManager.primaryBlue)
                                .frame(width: 24, height: 24)
                            
                            Text("Contact Us")
                                .font(.subheadline)
                                .foregroundColor(themeManager.primaryText)
                            
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(themeManager.primaryBlue)
                                .frame(width: 24, height: 24)
                            
                            Text("About")
                                .font(.subheadline)
                        }
                    }
                }
                
                // Sign Out Section
                Section {
                    Button(action: {
                        authManager.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 24, height: 24)
                            
                            Text("Sign Out")
                                .font(.subheadline)
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Security Settings View
struct SecuritySettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        List {
            Section("Authentication") {
                Toggle("Require Authentication", isOn: Binding(
                    get: { authManager.isAuthenticationRequired },
                    set: { authManager.enableAuthentication($0) }
                ))
                
                if authManager.biometricType != .none {
                    HStack {
                        Text(authManager.biometricType.displayName)
                        Spacer()
                        Text("Available")
                            .font(.caption)
                            .foregroundColor(themeManager.accentGreen)
                    }
                }
            }
            
            Section("Data Protection") {
                HStack {
                    Text("Encryption")
                    Spacer()
                    Text("Enabled")
                        .font(.caption)
                        .foregroundColor(themeManager.accentGreen)
                }
                
                HStack {
                    Text("Cloud Backup")
                    Spacer()
                    Text("Encrypted")
                        .font(.caption)
                        .foregroundColor(themeManager.accentGreen)
                }
            }
        }
        .navigationTitle("Security")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Placeholder Views
struct DataManagementView: View {
    var body: some View {
        Text("Data Management")
            .navigationTitle("Sync & Backup")
    }
}

struct ExportDataView: View {
    var body: some View {
        Text("Export Data")
            .navigationTitle("Export")
    }
}

struct PremiumView: View {
    var body: some View {
        Text("Premium Features")
            .navigationTitle("Premium")
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("FinanceApp")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("© 2024 FinanceApp Inc.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ThemeManager Extension
extension ThemeManager {
    func saveSettings() {
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        UserDefaults.standard.set(useSystemTheme, forKey: "useSystemTheme")
        UserDefaults.standard.set(glassEffectIntensity, forKey: "glassEffectIntensity")
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(AuthenticationManager())
        .environmentObject(DataManager())
}
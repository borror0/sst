import SwiftUI
import Combine

@main
struct FinanceApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authenticationManager = AuthenticationManager()
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(authenticationManager)
                .environmentObject(dataManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
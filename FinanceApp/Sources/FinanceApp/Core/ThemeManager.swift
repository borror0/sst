import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var useSystemTheme: Bool = true
    @Published var glassEffectIntensity: Double = 0.7
    
    var colorScheme: ColorScheme? {
        if useSystemTheme {
            return nil
        }
        return isDarkMode ? .dark : .light
    }
    
    // Primary Colors
    var primaryBlue: Color {
        Color("PrimaryBlue")
    }
    
    var primaryBlueGradient: LinearGradient {
        LinearGradient(
            colors: [Color("DeepBlue"), Color("MediumBlue")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var accentGreen: Color {
        Color("AccentGreen")
    }
    
    var accentOrange: Color {
        Color("AccentOrange")
    }
    
    // Background Colors
    var backgroundColor: Color {
        isDarkMode ? Color("DarkBackground") : Color("LightBackground")
    }
    
    var cardBackground: Color {
        isDarkMode ? Color("DarkCardBackground") : Color("LightCardBackground")
    }
    
    var glassBackground: Color {
        Color.white.opacity(isDarkMode ? 0.1 : 0.2)
    }
    
    // Text Colors
    var primaryText: Color {
        Color("PrimaryText")
    }
    
    var secondaryText: Color {
        Color("SecondaryText")
    }
    
    init() {
        loadSettings()
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        useSystemTheme = false
        saveSettings()
    }
    
    func enableSystemTheme() {
        useSystemTheme = true
        saveSettings()
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        UserDefaults.standard.set(useSystemTheme, forKey: "useSystemTheme")
        UserDefaults.standard.set(glassEffectIntensity, forKey: "glassEffectIntensity")
    }
    
    private func loadSettings() {
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        useSystemTheme = UserDefaults.standard.object(forKey: "useSystemTheme") as? Bool ?? true
        glassEffectIntensity = UserDefaults.standard.object(forKey: "glassEffectIntensity") as? Double ?? 0.7
    }
}

// MARK: - Glass Effect Modifier
struct GlassEffect: ViewModifier {
    let intensity: Double
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(intensity)
            )
    }
}

extension View {
    func glassEffect(intensity: Double = 0.7, cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassEffect(intensity: intensity, cornerRadius: cornerRadius))
    }
}

// MARK: - Neomorphism Effect
struct NeomorphismStyle: ViewModifier {
    let isDarkMode: Bool
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isDarkMode ? Color(.systemGray6) : Color.white)
                    .shadow(
                        color: isDarkMode ? Color.black.opacity(0.3) : Color.gray.opacity(0.3),
                        radius: 8,
                        x: 8,
                        y: 8
                    )
                    .shadow(
                        color: isDarkMode ? Color.white.opacity(0.1) : Color.white,
                        radius: 8,
                        x: -8,
                        y: -8
                    )
            )
    }
}

extension View {
    func neomorphismStyle(isDarkMode: Bool = false, cornerRadius: CGFloat = 16) -> some View {
        modifier(NeomorphismStyle(isDarkMode: isDarkMode, cornerRadius: cornerRadius))
    }
}
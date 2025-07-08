import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            // Background gradient
            themeManager.primaryBlueGradient
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("FinanceApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Secure. Smart. Simple.")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Authentication Section
                VStack(spacing: 30) {
                    // Biometric Authentication Button
                    if authManager.biometricType != .none {
                        Button(action: {
                            Task {
                                await authManager.authenticateWithBiometrics()
                            }
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: authManager.biometricType.icon)
                                    .font(.title2)
                                Text("Unlock with \(authManager.biometricType.displayName)")
                                    .font(.headline)
                            }
                            .foregroundColor(themeManager.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(.white)
                            .cornerRadius(16)
                        }
                        .glassEffect()
                    }
                    
                    // Passcode Authentication Button
                    Button(action: {
                        Task {
                            await authManager.authenticateWithPasscode()
                        }
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "lock.fill")
                                .font(.title2)
                            Text("Use Passcode")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white.opacity(0.2))
                        .cornerRadius(16)
                    }
                    .glassEffect()
                    
                    // Skip Authentication (for demo purposes)
                    Button("Skip Authentication") {
                        authManager.isAuthenticated = true
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .font(.footnote)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Security Notice
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.white.opacity(0.7))
                        Text("Your data is protected with end-to-end encryption")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(authManager.authenticationError ?? "Unknown error occurred")
        }
        .onChange(of: authManager.authenticationError) { error in
            showingError = error != nil
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationManager())
        .environmentObject(ThemeManager())
}
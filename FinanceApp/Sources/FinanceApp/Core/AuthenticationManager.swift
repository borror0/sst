import Foundation
import LocalAuthentication
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var biometricType: BiometricType = .none
    @Published var isAuthenticationRequired = true
    @Published var authenticationError: String?
    
    private let context = LAContext()
    
    enum BiometricType {
        case none
        case faceID
        case touchID
        
        var displayName: String {
            switch self {
            case .none: return "None"
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            }
        }
        
        var icon: String {
            switch self {
            case .none: return "lock.fill"
            case .faceID: return "faceid"
            case .touchID: return "touchid"
            }
        }
    }
    
    init() {
        checkBiometricSupport()
        loadAuthenticationSettings()
    }
    
    func checkBiometricSupport() {
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            biometricType = .none
            return
        }
        
        switch context.biometryType {
        case .faceID:
            biometricType = .faceID
        case .touchID:
            biometricType = .touchID
        default:
            biometricType = .none
        }
    }
    
    func authenticateWithBiometrics() async {
        guard biometricType != .none else {
            await MainActor.run {
                authenticationError = "Biometric authentication not available"
            }
            return
        }
        
        let reason = "Authenticate to access your financial data"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            await MainActor.run {
                if success {
                    isAuthenticated = true
                    authenticationError = nil
                } else {
                    authenticationError = "Authentication failed"
                }
            }
        } catch {
            await MainActor.run {
                authenticationError = error.localizedDescription
            }
        }
    }
    
    func authenticateWithPasscode() async {
        let reason = "Authenticate to access your financial data"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            
            await MainActor.run {
                if success {
                    isAuthenticated = true
                    authenticationError = nil
                } else {
                    authenticationError = "Authentication failed"
                }
            }
        } catch {
            await MainActor.run {
                authenticationError = error.localizedDescription
            }
        }
    }
    
    func logout() {
        isAuthenticated = false
        // Clear sensitive data from memory
        clearSensitiveData()
    }
    
    func enableAuthentication(_ enabled: Bool) {
        isAuthenticationRequired = enabled
        saveAuthenticationSettings()
    }
    
    private func saveAuthenticationSettings() {
        UserDefaults.standard.set(isAuthenticationRequired, forKey: "isAuthenticationRequired")
    }
    
    private func loadAuthenticationSettings() {
        isAuthenticationRequired = UserDefaults.standard.object(forKey: "isAuthenticationRequired") as? Bool ?? true
    }
    
    private func clearSensitiveData() {
        // Implement clearing of sensitive data when user logs out
        // This would include clearing cached financial data, tokens, etc.
    }
}
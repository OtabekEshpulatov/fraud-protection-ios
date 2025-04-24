import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var error: String?
    @Published var isLoading = false
    
    private let authService = AuthService.shared
    private let userPreferences = UserPreferencesManager.shared
    
    @Published var username = ""
    @Published var password = ""
    
    func login() async {
        guard !username.isEmpty && !password.isEmpty else {
            error = "please_fill_fields".localized
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let response = try await authService.login(username: username, password: password)
            if let token = response.token {
                // Save authentication data
                userPreferences.saveAuthData(
                    token: token,
                    userId: UUID().uuidString, // This should come from the server in a real app
                    username: username
                )
                isAuthenticated = true
            } else {
                // Use friendly response if available, otherwise fall back to message or default error
                error = response.friendlyResponse ?? response.message ?? "auth_failed".localized
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func register() async {
        guard !username.isEmpty && !password.isEmpty else {
            error = "please_fill_fields".localized
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let response = try await authService.register(
                username: username,
                password: password,
                locale: userPreferences.selectedLanguage?.rawValue
            )
            if let token = response.token {
                // Save authentication data
                userPreferences.saveAuthData(
                    token: token,
                    userId: UUID().uuidString, // This should come from the server in a real app
                    username: username
                )
                isAuthenticated = true
            } else {
                // Use friendly response if available, otherwise fall back to message or default error
                error = response.friendlyResponse ?? response.message ?? "registration_failed".localized
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        userPreferences.clearAuthData()
        isAuthenticated = false
    }
} 
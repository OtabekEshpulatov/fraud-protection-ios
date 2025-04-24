import Foundation

@MainActor
class TokenManager: ObservableObject {
    static let shared = TokenManager()
    
    private let oauth2Service = OAuth2Service()
    private let userPreferences = UserPreferencesManager.shared
    
    @Published var isRefreshing = false
    
    private init() {}
    
    func getValidToken() async throws -> String {
        // Check if we have a token and it's not expired
        if let token = userPreferences.authToken, !isTokenExpired() {
            return token
        }
        
        // Token is expired or doesn't exist, request a new one
        return try await refreshToken()
    }
    
    func refreshToken() async throws -> String {
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            let response = try await oauth2Service.requestToken()
            
            // Save the token and expiration time
            userPreferences.authToken = response.accessToken
            userPreferences.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(response.expiresIn))
            
            return response.accessToken
        } catch {
            // Clear token data on error
            userPreferences.clearAuthData()
            throw error
        }
    }
    
    private func isTokenExpired() -> Bool {
        guard let expirationDate = userPreferences.tokenExpirationDate else {
            return true
        }
        
        // Consider token expired if less than 60 seconds remaining
        return Date() >= expirationDate.addingTimeInterval(-60)
    }
} 
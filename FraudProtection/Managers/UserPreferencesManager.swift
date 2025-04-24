import Foundation

class UserPreferencesManager: ObservableObject {
    static let shared = UserPreferencesManager()
    
    private let defaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private let selectedLanguageKey = "selectedLanguage"
    private let authTokenKey = "authToken"
    private let tokenExpirationDateKey = "tokenExpirationDate"
    private let userIdKey = "userId"
    private let usernameKey = "username"
    private let isLoggedInKey = "isLoggedIn"
    
    // Published properties for UI updates
    @Published var hasCompletedOnboarding: Bool = false
    @Published var selectedLanguage: Language?
    @Published var authToken: String?
    @Published var tokenExpirationDate: Date?
    @Published var userId: String?
    @Published var username: String?
    @Published var isLoggedIn: Bool = false
    
    private init() {
        // Initialize properties from UserDefaults
        self.hasCompletedOnboarding = defaults.bool(forKey: hasCompletedOnboardingKey)
        
        if let languageCode = defaults.string(forKey: selectedLanguageKey) {
            self.selectedLanguage = Language(rawValue: languageCode)
        }
        
        self.authToken = defaults.string(forKey: authTokenKey)
        self.tokenExpirationDate = defaults.object(forKey: tokenExpirationDateKey) as? Date
        self.userId = defaults.string(forKey: userIdKey)
        self.username = defaults.string(forKey: usernameKey)
        self.isLoggedIn = defaults.bool(forKey: isLoggedInKey)
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(hasCompletedOnboarding, forKey: hasCompletedOnboardingKey)
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        defaults.set(hasCompletedOnboarding, forKey: hasCompletedOnboardingKey)
    }
    
    func saveAuthData(token: String, userId: String, username: String) {
        self.authToken = token
        self.userId = userId
        self.username = username
        self.isLoggedIn = true
        
        defaults.set(token, forKey: authTokenKey)
        defaults.set(userId, forKey: userIdKey)
        defaults.set(username, forKey: usernameKey)
        defaults.set(true, forKey: isLoggedInKey)
    }
    
    func clearAuthData() {
        self.authToken = nil
        self.tokenExpirationDate = nil
        self.userId = nil
        self.username = nil
        self.isLoggedIn = false
        
        defaults.removeObject(forKey: authTokenKey)
        defaults.removeObject(forKey: tokenExpirationDateKey)
        defaults.removeObject(forKey: userIdKey)
        defaults.removeObject(forKey: usernameKey)
        defaults.set(false, forKey: isLoggedInKey)
    }
    
    func resetAllData() {
        clearAuthData()
        resetOnboarding()
        selectedLanguage = nil
        defaults.removeObject(forKey: selectedLanguageKey)
    }
} 
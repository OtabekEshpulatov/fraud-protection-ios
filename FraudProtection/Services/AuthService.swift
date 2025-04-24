import Foundation

enum AuthError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
}

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    private let baseURL = "http://localhost:8080/api/v1"
    private let tokenManager = TokenManager.shared
    private let userPreferences = UserPreferencesManager.shared
    
    @Published private(set) var isAuthenticated = false
    @Published private(set) var currentUser: User?
    
    private init() {
        // Load saved auth state if any
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            self.isAuthenticated = true
            // TODO: Load user data if needed
        }
    }
    
    // Helper method to create a URLRequest with common headers
    private func createRequest(url: URL, method: String, requiresAuth: Bool = false) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add locale header if available
        if let language = userPreferences.selectedLanguage {
            request.setValue(language.rawValue, forHTTPHeaderField: "Accept-Language")
        }
        
        // Add authorization header if required
        if requiresAuth {
            let token = try await tokenManager.getValidToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    func register(username: String, password: String, locale: String? = nil, profilePhotoLink: String? = nil) async throws -> AuthResponse {
        let endpoint = "\(baseURL)/registration"
        guard let url = URL(string: endpoint) else {
            throw AuthError.invalidURL
        }
        
        let request = RegisterRequest(username: username, password: password, locale: locale, profilePhotoLink: profilePhotoLink)
        
        var urlRequest = try await createRequest(url: url, method: "POST")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let response = try JSONDecoder().decode(AuthResponse.self, from: data)
            return response
        } catch let error as DecodingError {
            throw AuthError.decodingError(error)
        } catch {
            throw AuthError.networkError(error)
        }
    }
    
    func login(username: String, password: String) async throws -> AuthResponse {
        let endpoint = "\(baseURL)/login"
        guard let url = URL(string: endpoint) else {
            throw AuthError.invalidURL
        }
        
        let request = LoginRequest(username: username, password: password)
        
        var urlRequest = try await createRequest(url: url, method: "POST")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let response = try JSONDecoder().decode(AuthResponse.self, from: data)
            return response
        } catch let error as DecodingError {
            throw AuthError.decodingError(error)
        } catch {
            throw AuthError.networkError(error)
        }
    }
    
    func getUsers() async throws -> [User] {
        let endpoint = "\(baseURL)/users"
        guard let url = URL(string: endpoint) else {
            throw AuthError.invalidURL
        }
        
        let request = try await createRequest(url: url, method: "GET", requiresAuth: true)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let users = try JSONDecoder().decode([User].self, from: data)
            return users
        } catch let error as DecodingError {
            throw AuthError.decodingError(error)
        } catch {
            throw AuthError.networkError(error)
        }
    }
    
    func signIn(username: String, password: String) async throws {
        // TODO: Implement actual sign in
        self.isAuthenticated = true
        UserDefaults.standard.set("dummy-token", forKey: "authToken")
    }
    
    func signOut() async {
        self.isAuthenticated = false
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
}

// User model for the /users endpoint
struct User: Codable, Identifiable {
    let id: UUID
    let username: String
    let verified: Bool
    let profilePhotoUrl: String?
} 
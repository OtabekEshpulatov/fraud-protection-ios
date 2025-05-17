//
//  AuthViewModel.swift
//  FraudProtection
//
//  Created by kebato OS on 05/05/25.
//


// ... existing code ...
// FraudProtection/ViewModels/AuthViewModel.swift

import Foundation

class AuthViewModel: ObservableObject {
    
    public static var shared:AuthViewModel = .init()
    
    @Published var authToken: AuthToken? {
        didSet { saveToken() }
    }
    @Published var isAuthenticated: Bool = false

    private let tokenKey = "authToken"

    init() {
        loadToken()
    }

    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        let parameters = "grant_type=password&username=\(username)&password=\(password)"
        guard let postData = parameters.data(using: .utf8) else {
            completion(false)
            return
        }

        // Load secrets from .env
        let clientId = EnvManager.shared.require("CLIENT_ID")
        let clientSecret = EnvManager.shared.require("CLIENT_SECRET")
        let apiUrl = EnvManager.shared.require("API_URL") + "/oauth2/token"
        
        let credentials = "\(clientId):\(clientSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            completion(false)
            return
        }
        let authHeader = "Basic \(credentialsData.base64EncodedString())"
        
        // Create the request
        var request = URLRequest(url: URL(string: apiUrl)!, timeoutInterval: Double.infinity)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(authHeader, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = postData

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("🔴 Request error:", error.localizedDescription)
                DispatchQueue.main.async { completion(false) }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Code: \(httpResponse.statusCode)")
                print("📄 Headers: \(httpResponse.allHeaderFields)")
            }

            guard let data = data else {
                print("⚠️ No data received")
                DispatchQueue.main.async { completion(false) }
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body:\n\(responseString)")
            }

            do {
                var token = try JSONDecoder().decode(AuthToken.self, from: data)
                token = AuthToken(
                    access_token: token.access_token,
                    refresh_token: token.refresh_token,
                    token_type: token.token_type,
                    expires_in: token.expires_in,
                    created_at: Date()
                )

                DispatchQueue.main.async {
                    self?.authToken = token
                    self?.isAuthenticated = true
                    completion(true)
                }
            } catch {
                print("❌ Decoding error:", error)
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()

    }
    
    @MainActor func register(username: String, password: String, regionId: String, completion: @escaping (Bool, String?) -> Void) {
        // Get the device token from NotificationManager
        let deviceToken = NotificationManager.shared.deviceToken ?? UserDefaults.standard.string(forKey: "appleDeviceToken") ?? ""
        
        print("📱 Device Token being sent:", deviceToken)
        
        let body: [String: Any] = [
            "username": username,
            "password": password,
            "locale": LanguageManager.shared.currentLanguage.rawValue,
            "regionId": regionId,
            "appleDeviceToken": deviceToken
        ]
        
        print("📦 Registration request body:", body)

        guard let postData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            completion(false, "error_serialization_failed".localized)
            return
        }
        
        // Load secrets from .env
        let clientId = EnvManager.shared.require("CLIENT_ID")
        let clientSecret = EnvManager.shared.require("CLIENT_SECRET")
        
        let credentials = "\(clientId):\(clientSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            completion(false, "error_credentials_encoding".localized)
            return
        }
        let authHeader = "Basic \(credentialsData.base64EncodedString())"

        var request = URLRequest(url: URL(string: EnvManager.shared.require("API_URL") + APIConstants.registration)!, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.addValue(authHeader, forHTTPHeaderField: "Authorization")
        request.httpBody = postData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Registration error: \(error)")
                DispatchQueue.main.async { completion(false, error.localizedDescription) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(false, "error_invalid_response".localized) }
                return
            }

            switch httpResponse.statusCode {
            case 200:
                // Registration successful, no need to parse response data
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            case 400:
                do {
                    let apiError = try JSONDecoder().decode(APIError.self, from: data!)
                    DispatchQueue.main.async {
                        completion(false, apiError.friendlyMessage ?? apiError.message ?? "error_registration_failed".localized)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, "error_decoding_error".localized)
                    }
                }
            default:
                DispatchQueue.main.async {
                    completion(false, "error_unexpected_status".localized)
                }
            }
        }.resume()
    }



    /// Checks if the user is authenticated and the access token is not expired.
    /// If expired, attempts to refresh the token using the refresh token.
    /// Calls the completion handler with `true` if authentication is valid (refreshed or not expired), `false` otherwise.
    public func isAuthenticationNonExpired() -> Bool {
        guard let token = authToken else {
            return false
        }
        if !token.isExpired {
            return true
        }
        // Token is expired, try to refresh
        guard !token.refresh_token.isEmpty else {
            return false
        }
        let parameters = "grant_type=refresh_token&refresh_token=\(token.refresh_token)"
        guard let postData = parameters.data(using: .utf8) else {
            return false
        }
        
        // Load secrets from .env
        let clientId = EnvManager.shared.require("CLIENT_ID")
        let clientSecret = EnvManager.shared.require("CLIENT_SECRET")
        
        let credentials = "\(clientId):\(clientSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            return false
        }
        let authHeader = "Basic \(credentialsData.base64EncodedString())"
        
        var request = URLRequest(url: URL(string: EnvManager.shared.require("API_URL") + "/oauth2/token")!, timeoutInterval: Double.infinity)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(authHeader, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else {
                self?.isAuthenticated = false
                self?.authToken = nil
                return
            }
            print("Token refresh response:", String(data: data, encoding: .utf8) ?? "nil")
            do {
                var newToken = try JSONDecoder().decode(AuthToken.self, from: data)
                newToken = AuthToken(
                    access_token: newToken.access_token,
                    refresh_token: newToken.refresh_token,
                    token_type: newToken.token_type,
                    expires_in: newToken.expires_in,
                    created_at: Date()
                )
                DispatchQueue.main.async {
                    self?.authToken = newToken
                    self?.isAuthenticated = true
                }
            } catch {
                print("Token refresh decode error:", error)
                self?.isAuthenticated = false
                self?.authToken = nil
            }
        }
        task.resume()
    
        return self.isAuthenticated  
    }



    func logout() {
        authToken = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    


    private func saveToken() {
        if let token = authToken, let data = try? JSONEncoder().encode(token) {
            UserDefaults.standard.set(data, forKey: tokenKey)
        }
    }

    private func loadToken() {
        if let data = UserDefaults.standard.data(forKey: tokenKey),
           let token = try? JSONDecoder().decode(AuthToken.self, from: data) {
            self.authToken = token
            self.isAuthenticated = !token.isExpired
        }
    }

    func saveAppleDeviceToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "appleDeviceToken")
    }
}

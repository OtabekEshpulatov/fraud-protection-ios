// ... existing code ...
// FraudProtection/ViewModels/AuthViewModel.swift

import Foundation

class AuthViewModel: ObservableObject {
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
        guard let postData = parameters.data(using: .utf8) else { return }

        var request = URLRequest(url: URL(string: "https://otabekjan.com/oauth2/token")!, timeoutInterval: Double.infinity)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("••••••", forHTTPHeaderField: "Authorization")
        request.addValue("JSESSIONID=0259D195DEAFF04BB0C6B6AA585C51AD", forHTTPHeaderField: "Cookie")
        request.httpMethod = "POST"
        request.httpBody = postData

        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { completion(false) }
                return
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
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
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
}
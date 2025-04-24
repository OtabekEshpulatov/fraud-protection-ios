import Foundation

struct OAuth2TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

enum OAuth2Error: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
}

class OAuth2Service {
    private let baseURL = "http://localhost:8080"
    private let clientId = "my-client"
    private let clientSecret = "my-secret"
    
    func requestToken() async throws -> OAuth2TokenResponse {
        let endpoint = "\(baseURL)/oauth2/token"
        guard let url = URL(string: endpoint) else {
            throw OAuth2Error.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Create basic auth header
        let authString = "\(clientId):\(clientSecret)"
        let authData = authString.data(using: .utf8)!
        let base64Auth = authData.base64EncodedString()
        request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        
        // Set form data
        let formData = "grant_type=client_credentials"
        request.httpBody = formData.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(OAuth2TokenResponse.self, from: data)
            return response
        } catch let error as DecodingError {
            throw OAuth2Error.decodingError(error)
        } catch {
            throw OAuth2Error.networkError(error)
        }
    }
} 
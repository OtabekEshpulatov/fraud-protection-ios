import Foundation

struct APIError: Codable, LocalizedError {
    let message: String?
    let friendlyMessage: String?
    let code: String?
    
    var errorDescription: String? {
        return friendlyMessage ?? message ?? "unknown_error".localized
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case decodingError(Error)
    case serverError(APIError)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "invalid_url".localized
        case .decodingError(let error):
            return "decoding_error".localized + ": \(error.localizedDescription)"
        case .serverError(let apiError):
            return apiError.errorDescription
        case .networkError(let error):
            return "network_error".localized + ": \(error.localizedDescription)"
        }
    }
} 

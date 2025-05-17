import Foundation

struct RegisterRequest: Codable {
    let username: String
    let password: String
    let locale: String?
    let profilePhotoId: String?
    let regionId: String?
    let appleDeviceToken: String?
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String?
    let message: String?
    let friendlyResponse: String?
} 
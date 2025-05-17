//
//  AuthToken.swift
//  FraudProtection
//
//  Created by kebato OS on 05/05/25.
//


// ... existing code ...
// FraudProtection/Models/AuthToken.swift

import Foundation

struct AuthToken: Codable {
    let access_token: String
    let refresh_token: String
    let token_type: String
    let expires_in: Int
    let created_at: Date?

    var isExpired: Bool {
        Date().timeIntervalSince(created_at!) > Double(expires_in)
    }
}

import Foundation

struct Notification: Identifiable, Codable {
    let id: UUID
    let title: String
    let body: String
    let payload: String
} 

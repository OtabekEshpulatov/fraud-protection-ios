import Foundation

struct PushNotification: Codable {
    let type: String
    let payload: String
    
    enum NotificationType: String {
        case post = "post"
    }
} 
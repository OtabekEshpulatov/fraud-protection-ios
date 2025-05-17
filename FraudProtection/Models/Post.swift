import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let title: String
    let body: String
    let mediaUrls: [String]
    let user: PostUser
    let region: String?
    let createdDate: TimeInterval
    let views: Int?
    let comments: Int?
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case mediaUrls = "mediaUrls"
        case user
        case region
        case createdDate = "createdDate"
        case views
        case comments
        case tags
    }
    
    var date: Date {
        Date(timeIntervalSince1970: createdDate)
    }
    
    var formattedDate: String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfMonth, .month, .year], from: date, to: now)
        
        if let minutes = components.minute, minutes < 60 {
            return String(format: "time_minutes_ago".localized, minutes)
        } else if let hours = components.hour, hours < 24 {
            return String(format: "time_hours_ago".localized, hours)
        } else if let days = components.day, days < 7 {
            return String(format: "time_days_ago".localized, days)
        } else if let weeks = components.weekOfMonth, weeks < 4 {
            return String(format: "time_weeks_ago".localized, weeks)
        } else if let months = components.month, months < 12 {
            return String(format: "time_months_ago".localized, months)
        } else if let years = components.year {
            return String(format: "time_years_ago".localized, years)
        }
        
        return "time_just_now".localized
    }
}

struct PostUser: Codable {
    let id: UUID
    let username: String
    let verified: Bool?
    let profilePhotoUrl: String?
} 
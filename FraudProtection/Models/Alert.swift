//
//  Alert.swift
//  FraudProtection
//
//  Created by kebato OS on 06/05/25.
//


// ... existing code ...

import Foundation

struct Alert: Identifiable, Codable {
    struct Media: Codable, Identifiable {
        let id: String
        let url: String
    }

    let id: String
    let title: String
    let body: String
    let mediaIds: [Media]
    let createdAt: TimeInterval

    var date: Date {
        Date(timeIntervalSince1970: createdAt)
    }

    var formattedDate: String {
        let now = Date()
        let components = Calendar.current.dateComponents(
            [.year, .month, .weekOfMonth, .day, .hour, .minute],
            from: date,
            to: now
        )

        if let years = components.year, years > 0 {
            return String(format: "time_years_ago".localized, years)
        } else if let months = components.month, months > 0 {
            return String(format: "time_months_ago".localized, months)
        } else if let weeks = components.weekOfMonth, weeks > 0 {
            return String(format: "time_weeks_ago".localized, weeks)
        } else if let days = components.day, days > 0 {
            return String(format: "time_days_ago".localized, days)
        } else if let hours = components.hour, hours > 0 {
            return String(format: "time_hours_ago".localized, hours)
        } else if let minutes = components.minute, minutes > 0 {
            return String(format: "time_minutes_ago".localized, minutes)
        } else {
            return "time_just_now".localized
        }
    }
}

// ... existing code ...
//
//  AlertsViewModel.swift
//  FraudProtection
//
//  Created by kebato OS on 06/05/25.
//


// ... existing code ...

import Foundation

@MainActor
class AlertsViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var error: String? = nil
    
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel = AuthViewModel.shared) {
        self.authViewModel = authViewModel
        Task {
            await fetchNotifications()
            await fetchUnreadCount()
        }
    }
    
    func fetchNotifications() async {
        guard let token = authViewModel.authToken else {
            notifications = []
            return
        }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let url = URL(string: "\(EnvManager.shared.require("API_URL"))/api/v1/notifications")!
            var request = URLRequest(url: url)
            request.setValue("\(token.token_type) \(token.access_token)", forHTTPHeaderField: "Authorization")
            
            print("urlurl", url)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            print("data", data)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    notifications = []
                    return
                }
            }
            
            let fetchedNotifications = try JSONDecoder().decode([Notification].self, from: data)
            notifications = fetchedNotifications
        } catch {
            print("Error fetching notifications:", error)
            self.error = error.localizedDescription
            notifications = []
        }
    }
    
    func fetchUnreadCount() async {
        guard let token = authViewModel.authToken else {
            unreadCount = 0
            return
        }
        
        do {
            let url = URL(string: "\(EnvManager.shared.require("API_URL"))/api/v1/notifications/count")!
            var request = URLRequest(url: url)
            request.setValue("\(token.token_type) \(token.access_token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    unreadCount = 0
                    return
                }
            }
            
            let count = try JSONDecoder().decode(Int.self, from: data)
            unreadCount = count
        } catch {
            print("Error fetching unread count:", error)
            unreadCount = 0
        }
    }
    
    func markAsRead(id: UUID) async {
        guard let token = authViewModel.authToken else { return }
        
        do {
            var components = URLComponents(string: "\(EnvManager.shared.require("API_URL"))/api/v1/notifications/read")!
            components.queryItems = [URLQueryItem(name: "id", value: id.uuidString)]
            
            guard let url = components.url else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("\(token.token_type) \(token.access_token)", forHTTPHeaderField: "Authorization")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                // Remove the notification from the list
                notifications.removeAll { $0.id == id }
                // Fetch the updated unread count
                unreadCount = max(0,unreadCount - 1)
            }
        } catch {
            print("Error marking notification as read:", error)
        }
    }
}

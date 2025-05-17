import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var deviceToken: String?
    
    private override init() {
        super.init()
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }
    }
    
    func handleDeviceToken(_ token: Data) {
        let tokenParts = token.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("📱 Device Token received:", token)
        
        DispatchQueue.main.async {
            self.deviceToken = token
            // Save token to UserDefaults
            UserDefaults.standard.set(token, forKey: "appleDeviceToken")
            UserDefaults.standard.synchronize() // Force immediate save
            
            // Verify the token was saved
            if let savedToken = UserDefaults.standard.string(forKey: "appleDeviceToken") {
                print("📱 Device Token saved:", savedToken)
            } else {
                print("❌ Failed to save device token")
            }
        }
    }
    
    func handleRegistrationError(_ error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
} 
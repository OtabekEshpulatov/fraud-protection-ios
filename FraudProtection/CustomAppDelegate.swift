//
//  CustomAppDelegate.swift
//  FraudProtection
//
//  Created by kebato OS on 15/05/25.
//


//  CustomAppDelegate.swift
import SwiftUI
import UserNotifications

class CustomAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    // This gives us access to the methods from our main app code inside the app delegate
    var app: FraudProtectionApp?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // This is where we register this device to recieve push notifications from Apple
        // All this function does is register the device with APNs, it doesn't set up push notifications by itself
        application.registerForRemoteNotifications()
        
        // Setting the notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication,
                       didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Once the device is registered for push notifications Apple will send the token to our app and it will be available here.
        // This is also where we will forward the token to our push server
        // If you want to see a string version of your token, you can use the following code to print it out
        let stringifiedToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("stringifiedToken:", stringifiedToken)
        NotificationManager.shared.handleDeviceToken(deviceToken)
    }
}

extension CustomAppDelegate: UNUserNotificationCenterDelegate {
    // This function lets us do something when the user interacts with a notification
    // like log that they clicked it, or navigate to a specific screen
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        print("🔔 Got notification userInfo:", userInfo)
        
        // Parse the notification payload
        if let type = userInfo["type"] as? String,
           let payload = userInfo["payload"] as? String {
            
            let notification = PushNotification(type: type, payload: payload)
            
            switch notification.type.lowercased() {
            case PushNotification.NotificationType.post.rawValue:
                // Fetch post details from API
                do {
                    let url = URL(string: "\(EnvManager.shared.require("API_URL"))\(APIConstants.singlePost)/\(payload)")!
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let post = try JSONDecoder().decode(Post.self, from: data)
                    
                    // Create a dictionary with the post data
                    let postDict: [String: Any] = [
                        "id": post.id,
                        "title": post.title,
                        "body": post.body,
                        "mediaUrls": post.mediaUrls,
                        "user": [
                            "id": post.user.id,
                            "username": post.user.username,
                            "verified": post.user.verified as Any,
                            "profilePhotoUrl": post.user.profilePhotoUrl as Any
                        ],
                        "region": post.region as Any,
                        "createdDate": post.createdDate,
                        "views": post.views as Any,
                        "comments": post.comments as Any,
                        "tags": post.tags
                    ]
                    
                    // Post notification to navigate to post detail
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("NavigateToPost"),
                            object: nil,
                            userInfo: ["postDict": postDict]
                        )
                    }
                } catch {
                    print("Error fetching post details:", error)
                }
            default:
                break
            }
        }
    }
    
    // Called when notification is received in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Check user preference for foreground notifications
//        let showForegroundNotifications = UserDefaults.standard.bool(forKey: "showForegroundNotifications")
        completionHandler([.banner, .sound, .badge])
//        if showForegroundNotifications {
//            // Show the notification as a banner, sound, and badge
//            completionHandler([.banner, .sound, .badge])
//        } else {
//            // Don't show the notification in foreground
//            completionHandler([])
//        }
    }
}

# Fraud Protection iOS App

## Push Notification Handling

### Overview
The app implements push notification handling to manage user interactions with notifications and maintain badge counts for unread alerts. The implementation includes both foreground and background notification handling, with support for badge count updates and post detail navigation.

### Features

#### 1. Push Notification Registration
- Automatic registration during app launch via `CustomAppDelegate`
- Device token management through `NotificationManager`
- Support for both foreground and background notification states
- Badge count updates for unread alerts

#### 2. Notification Handling
When a user interacts with a notification, the app:
1. Parses the notification payload to determine the type and content
2. For post notifications:
   - Fetches post details from the API
   - Creates a post object with user and media information
   - Navigates to the post detail view
3. Updates the badge count through the `AlertsViewModel`

### Implementation Details

#### CustomAppDelegate
The `CustomAppDelegate` class handles:
- Push notification registration with APNs
- Device token management
- Notification permission requests
- Post detail fetching and navigation
- Foreground notification presentation

#### NotificationManager
The `NotificationManager` singleton manages:
- Device token storage and retrieval
- Notification authorization requests
- Token persistence in UserDefaults
- Error handling for registration failures

#### AlertsViewModel
The `AlertsViewModel` handles:
- Fetching notifications from the API
- Managing unread count
- Marking notifications as read
- Updating the UI badge count
- Error handling and loading states

### API Integration

#### Endpoints
1. **Post Details**
   - Endpoint: `{API_URL}/api/v1/posts/{id}`
   - Method: GET
   - Used to fetch post details when a notification is tapped

2. **Notifications**
   - Endpoint: `{API_URL}/api/v1/notifications`
   - Method: GET
   - Used to fetch user notifications

3. **Unread Count**
   - Endpoint: `{API_URL}/api/v1/notifications/count`
   - Method: GET
   - Used to fetch and update badge count

4. **Mark as Read**
   - Endpoint: `{API_URL}/api/v1/notifications/read`
   - Method: POST
   - Used to mark notifications as read

### Usage

#### Handling Notifications
```swift
// Example of handling a notification in CustomAppDelegate
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    let userInfo = response.notification.request.content.userInfo
    
    if let type = userInfo["type"] as? String,
       let payload = userInfo["payload"] as? String {
        // Handle notification based on type
        // Fetch post details and navigate
    }
}
```

#### Updating Badge Count
```swift
// Example of updating badge count in AlertsViewModel
func fetchUnreadCount() async {
    guard let token = authViewModel.authToken else {
        unreadCount = 0
        return
    }
    
    do {
        let url = URL(string: "\(EnvManager.shared.require("API_URL"))/api/v1/notifications/count")!
        var request = URLRequest(url: url)
        request.setValue("\(token.token_type) \(token.access_token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let count = try JSONDecoder().decode(Int.self, from: data)
        unreadCount = count
    } catch {
        print("Error fetching unread count:", error)
        unreadCount = 0
    }
}
```

### Requirements
- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

### Configuration
1. Enable Push Notifications capability in your Xcode project
2. Configure your Apple Developer account for push notifications
3. Set up your push notification certificate
4. Configure the API URL in your environment variables

### Best Practices
1. Always handle both foreground and background notification states
2. Implement proper error handling for API calls
3. Maintain badge count accuracy
4. Handle notification permissions appropriately
5. Test notifications in different app states
6. Cache device token for persistence
7. Handle authentication token expiration

### Troubleshooting
Common issues and solutions:
1. **Empty Post Detail View**
   - Ensure post data is properly fetched before navigation
   - Verify API response handling
   - Check data passing between views
   - Verify authentication token is valid

2. **Badge Count Issues**
   - Verify API response
   - Check badge count update implementation
   - Ensure proper permission handling
   - Verify authentication token is valid

3. **Notification Registration Issues**
   - Check device token storage
   - Verify APNs certificate
   - Check notification permissions
   - Verify network connectivity

### Contributing
Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

### License
This project is licensed under the MIT License - see the LICENSE.md file for details 
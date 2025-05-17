// ... existing code ...
// FraudProtectionApp.swift

import SwiftUI
import UserNotifications

@main
struct FraudProtectionApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @UIApplicationDelegateAdaptor private var appDelegate: CustomAppDelegate

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onAppear(perform: {
                                    // this makes sure that we are setting the app to the app delegate as soon as the main view appears
                                    appDelegate.app = self
                                })
        }
    }
}

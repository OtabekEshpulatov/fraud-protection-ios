//
//  ContentView.swift
//  FraudProtection
//
//  Created by Mavlon Ergashev on 20/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userPreferences = UserPreferencesManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @State private var shouldRestart = false
    
    var body: some View {
        Group {
            if userPreferences.hasCompletedOnboarding {
                MainTabView()
            } else {
                GettingStartedView()
            }
        }
        .onAppear {
            // Set the language from preferences if available
            if let savedLanguage = userPreferences.selectedLanguage {
                languageManager.currentLanguage = savedLanguage
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            shouldRestart = true
        }
        .onChange(of: languageManager.currentLanguage) { _ in
            // Force view refresh when language changes
            shouldRestart = true
        }
        .id(shouldRestart ? "restart" : "normal") // Force view recreation when shouldRestart is true
    }
}

#Preview {
    ContentView()
}

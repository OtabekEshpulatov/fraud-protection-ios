import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PostsView()
                .tabItem {
                    Label("latest_posts".localized, systemImage: "list.bullet")
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Label("settings".localized, systemImage: "gear")
                }
                .tag(1)
        }
        .id(languageManager.currentLanguage) // Force view refresh when language changes
    }
}

#Preview {
    MainTabView()
} 
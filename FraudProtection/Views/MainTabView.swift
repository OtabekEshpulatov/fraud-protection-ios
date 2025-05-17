// ... existing code ...
import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab = 0
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var alertsViewModel: AlertsViewModel
    @State private var postToNavigate: Post? = nil
    @State private var showPostDetail = false
    
    init() {
        _alertsViewModel = StateObject(wrappedValue: AlertsViewModel(authViewModel: AuthViewModel.shared))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                PostsView()
                    .navigationDestination(isPresented: $showPostDetail) {
                        if let post = postToNavigate {
                            PostDetailView(post: post, skipInitialFetch: true)
                        }
                    }
            }
            .tabItem {
                Label("latest_posts".localized, systemImage: "list.bullet")
            }
            .tag(0)

            AlertsView()
                .environmentObject(alertsViewModel)
                .tabItem {
                    Label("alerts".localized, systemImage: "bell.fill")
                }
                .badge(alertsViewModel.unreadCount)
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("settings".localized, systemImage: "gear")
                }
                .tag(2)
        }
        .id(languageManager.currentLanguage)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToPost"))) { notification in
            if let postDict = notification.userInfo?["postDict"] as? [String: Any],
               let userDict = postDict["user"] as? [String: Any],
               let userId = userDict["id"] as? UUID,
               let username = userDict["username"] as? String {
                
                let post = Post(
                    id: postDict["id"] as? String ?? "",
                    title: postDict["title"] as? String ?? "",
                    body: postDict["body"] as? String ?? "",
                    mediaUrls: postDict["mediaUrls"] as? [String] ?? [],
                    user: PostUser(
                        id: userId,
                        username: username,
                        verified: userDict["verified"] as? Bool,
                        profilePhotoUrl: userDict["profilePhotoUrl"] as? String
                    ),
                    region: postDict["region"] as? String,
                    createdDate: postDict["createdDate"] as? TimeInterval ?? Date().timeIntervalSince1970,
                    views: postDict["views"] as? Int,
                    comments: postDict["comments"] as? Int,
                    tags: postDict["tags"] as? [String] ?? []
                )
                
                postToNavigate = post
                selectedTab = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showPostDetail = true
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel.shared)
}

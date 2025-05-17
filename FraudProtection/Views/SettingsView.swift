import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLoginSheet = false
    

    @StateObject private var languageManager = LanguageManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("showForegroundNotifications") private var showForegroundNotifications = true
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(authViewModel.isAuthenticated ? "Logout" : "Login") {
                                    if authViewModel.isAuthenticated {
                                        authViewModel.logout()
                                    } else {
                                        showLoginSheet = true
                                    }
                                }
                                .sheet(isPresented: $showLoginSheet) {
                                    LoginView()
                                        .environmentObject(authViewModel)
                                }
                } header: {
                    Text("account".localized)
                }
                
                Section {
                    Picker("language".localized, selection: $languageManager.currentLanguage) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.displayName)
                                .tag(language)
                        }
                    }
                } header: {
                    Text("language".localized)
                }
                
                Section {
                    Toggle("dark_mode".localized, isOn: $isDarkMode)
                } header: {
                    Text("appearance".localized)
                }
                
                Section {
                    Toggle("show_foreground_notifications".localized, isOn: $showForegroundNotifications)
                } header: {
                    Text("notifications".localized)
                } footer: {
                    Text("show_foreground_notifications_description".localized)
                }
                
                Section {
                    Link(destination: URL(string: "https://fraud-shield.com")!) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text("Website")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Link(destination: URL(string: "https://t.me/fraud_shield")!) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.blue)
                            Text("Telegram")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Text("social_media".localized)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("clear_cache".localized, systemImage: "trash")
                    }
                } header: {
                    Text("storage".localized)
                } footer: {
                    Text("clear_cache_description".localized)
                }
            }
            .navigationTitle("settings".localized)
            .alert("clear_cache_confirmation".localized, isPresented: $showingDeleteConfirmation) {
                Button("cancel".localized, role: .cancel) { }
                Button("clear".localized, role: .destructive) {
                    Task {
                        await clearCache()
                    }
                }
            } message: {
                Text("clear_cache_warning".localized)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    private func clearCache() async {
        // Clear UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Clear URLCache
        URLCache.shared.removeAllCachedResponses()
        
        // Clear any stored files in the app's cache directory
        if let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
                for file in contents {
                    try FileManager.default.removeItem(at: file)
                }
            } catch {
                print("Error clearing cache: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
} 

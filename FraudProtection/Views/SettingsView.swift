import SwiftUI

struct SettingsView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var languageManager = LanguageManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if authService.isAuthenticated {
                        Button(role: .destructive) {
                            Task {
                                await authService.signOut()
                            }
                        } label: {
                            Label("sign_out".localized, systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } else {
                        NavigationLink {
                            SignInView()
                        } label: {
                            Label("sign_in".localized, systemImage: "person.fill")
                        }
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
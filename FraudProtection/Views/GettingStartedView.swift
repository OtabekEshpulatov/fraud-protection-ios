import SwiftUI

struct GettingStartedView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedLanguage: Language = .english
    @State private var showMainApp = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "globe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("welcome_to_app".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("select_language".localized)
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                ForEach(Language.allCases, id: \.self) { language in
                    Button(action: {
                        selectedLanguage = language
                        // Update language immediately when selected
                        languageManager.currentLanguage = language
                    }) {
                        HStack {
                            Text(language.displayName)
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedLanguage == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedLanguage == language ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                // Save language preference
                UserPreferencesManager.shared.selectedLanguage = selectedLanguage
                
                // Complete onboarding and show main app
                UserPreferencesManager.shared.completeOnboarding()
                showMainApp = true
                
                // Post notification to restart app
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: NSNotification.Name("RestartApp"), object: nil)
                }
            }) {
                Text("get_started".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .id(languageManager.currentLanguage) // Force view refresh when language changes
        .fullScreenCover(isPresented: $showMainApp) {
            MainTabView()
        }
    }
}

#Preview {
    GettingStartedView()
} 
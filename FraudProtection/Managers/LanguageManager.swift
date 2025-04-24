import Foundation
import SwiftUI

enum Language: String, CaseIterable {
    case uzbek = "uz"
    case english = "en"
    case russian = "ru"
    
    var displayName: String {
        switch self {
        case .uzbek: return "O'zbek"
        case .english: return "English"
        case .russian: return "Русский"
        }
    }
}

@MainActor
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
            updateLocale()
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        }
    }
    
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language"),
           let language = Language(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Default to system language if available, otherwise English
            let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
            self.currentLanguage = Language(rawValue: preferredLanguage) ?? .english
        }
        updateLocale()
    }
    
    private func updateLocale() {
        // Update the app's locale
        UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Post notification for language change
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
} 
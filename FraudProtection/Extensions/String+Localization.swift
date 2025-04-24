import Foundation

extension String {
    var localized: String {
        let language = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
} 
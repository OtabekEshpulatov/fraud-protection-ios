import XCTest
@testable import FraudProtection

final class LanguageManagerTests: XCTestCase {
    var sut: LanguageManager!
    
    override func setUp() {
        super.setUp()
        sut = LanguageManager.shared
        // Reset to default language
        sut.currentLanguage = .english
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(sut.currentLanguage, .english)
    }
    
    func testChangeLanguage() {
        // Given
        let newLanguage = Language.uzbek
        
        // When
        sut.currentLanguage = newLanguage
        
        // Then
        XCTAssertEqual(sut.currentLanguage, newLanguage)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "app_language"), newLanguage.rawValue)
    }
    
    func testLanguagePersistence() {
        // Given
        let language = Language.russian
        sut.currentLanguage = language
        
        // When
        let newInstance = LanguageManager.shared
        
        // Then
        XCTAssertEqual(newInstance.currentLanguage, language)
    }
    
    func testAllLanguagesAvailable() {
        // Given
        let expectedLanguages: [Language] = [.uzbek, .english, .russian]
        
        // When
        let availableLanguages = Language.allCases
        
        // Then
        XCTAssertEqual(availableLanguages.count, expectedLanguages.count)
        for language in expectedLanguages {
            XCTAssertTrue(availableLanguages.contains(language))
        }
    }
    
    func testLanguageDisplayNames() {
        // Given
        let expectedNames = [
            Language.uzbek: "O'zbek",
            Language.english: "English",
            Language.russian: "Русский"
        ]
        
        // Then
        for (language, expectedName) in expectedNames {
            XCTAssertEqual(language.displayName, expectedName)
        }
    }
} 
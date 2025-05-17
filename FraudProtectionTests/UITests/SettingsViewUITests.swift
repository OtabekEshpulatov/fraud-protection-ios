import XCTest

final class SettingsViewUITests: BaseUITestCase {
    
    func testSettingsViewInitialState() {
        // Navigate to Settings tab
        app.tabBars.buttons["settings".localized].tap()
        
        // Verify sections exist
        XCTAssertTrue(app.staticTexts["account".localized].exists)
        XCTAssertTrue(app.staticTexts["language".localized].exists)
        XCTAssertTrue(app.staticTexts["appearance".localized].exists)
        XCTAssertTrue(app.staticTexts["notifications".localized].exists)
        XCTAssertTrue(app.staticTexts["social_media".localized].exists)
        XCTAssertTrue(app.staticTexts["storage".localized].exists)
    }
    
    func testLanguageSelection() {
        // Navigate to Settings tab
        app.tabBars.buttons["settings".localized].tap()
        
        // Open language picker
        app.buttons["language".localized].tap()
        
        // Select a different language
        app.buttons["O'zbek"].tap()
        
        // Verify language changed
        XCTAssertEqual(LanguageManager.shared.currentLanguage, .uzbek)
    }
    
    func testDarkModeToggle() {
        // Navigate to Settings tab
        app.tabBars.buttons["settings".localized].tap()
        
        // Get initial state
        let darkModeToggle = app.switches["dark_mode".localized]
        let initialState = darkModeToggle.value as? String == "1"
        
        // Toggle dark mode
        darkModeToggle.tap()
        
        // Verify state changed
        let newState = darkModeToggle.value as? String == "1"
        XCTAssertNotEqual(initialState, newState)
    }
    
    func testForegroundNotificationsToggle() {
        // Navigate to Settings tab
        app.tabBars.buttons["settings".localized].tap()
        
        // Get initial state
        let notificationsToggle = app.switches["show_foreground_notifications".localized]
        let initialState = notificationsToggle.value as? String == "1"
        
        // Toggle notifications
        notificationsToggle.tap()
        
        // Verify state changed
        let newState = notificationsToggle.value as? String == "1"
        XCTAssertNotEqual(initialState, newState)
    }
    
    func testClearCache() {
        // Navigate to Settings tab
        app.tabBars.buttons["settings".localized].tap()
        
        // Tap clear cache button
        app.buttons["clear_cache".localized].tap()
        
        // Verify confirmation alert appears
        XCTAssertTrue(app.alerts["clear_cache_confirmation".localized].exists)
        
        // Confirm clear cache
        app.alerts["clear_cache_confirmation".localized].buttons["clear".localized].tap()
        
        // Verify cache is cleared
        // Note: In a real test, we would verify the cache was actually cleared
        // This might require additional setup and verification
    }
    
    func testSocialMediaLinks() {
        // Navigate to Settings tab
        app.tabBars.buttons["settings".localized].tap()
        
        // Verify social media links exist
        XCTAssertTrue(app.buttons["Website"].exists)
        XCTAssertTrue(app.buttons["Telegram"].exists)
    }
}

// MARK: - Helper Extension
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
} 
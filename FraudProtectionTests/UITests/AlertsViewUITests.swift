import XCTest

final class AlertsViewUITests: BaseUITestCase {
    
    func testAlertsViewInitialState() {
        // Navigate to Alerts tab
        app.tabBars.buttons["alerts".localized].tap()
        
        // Verify navigation title
        XCTAssertTrue(app.navigationBars["Notifications"].exists)
    }
    
    func testEmptyState() {
        // Navigate to Alerts tab
        app.tabBars.buttons["alerts".localized].tap()
        
        // Verify empty state message
        XCTAssertTrue(app.staticTexts["No notifications available."].exists)
    }
    
    func testNotificationList() {
        // Navigate to Alerts tab
        app.tabBars.buttons["alerts".localized].tap()
        
        // Wait for notifications to load
        let expectation = XCTestExpectation(description: "Wait for notifications to load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        
        // Verify notification list exists
        XCTAssertTrue(app.tables.firstMatch.exists)
    }
    
    func testPullToRefresh() {
        // Navigate to Alerts tab
        app.tabBars.buttons["alerts".localized].tap()
        
        // Pull to refresh
        let table = app.tables.firstMatch
        let start = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let end = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.1, thenDragTo: end)
        
        // Verify refresh indicator appears
        XCTAssertTrue(app.activityIndicators.firstMatch.exists)
    }
    
    func testNotificationDetail() {
        // Navigate to Alerts tab
        app.tabBars.buttons["alerts".localized].tap()
        
        // Wait for notifications to load
        let expectation = XCTestExpectation(description: "Wait for notifications to load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        
        // Tap first notification if exists
        if let firstNotification = app.tables.firstMatch.cells.firstMatch {
            firstNotification.tap()
            
            // Verify detail view appears
            XCTAssertTrue(app.navigationBars["Notification Details"].exists)
            
            // Verify notification content
            XCTAssertTrue(app.staticTexts.firstMatch.exists)
        }
    }
    
    func testMarkAsRead() {
        // Navigate to Alerts tab
        app.tabBars.buttons["alerts".localized].tap()
        
        // Wait for notifications to load
        let expectation = XCTestExpectation(description: "Wait for notifications to load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        
        // Get initial unread count
        let initialBadge = app.tabBars.buttons["alerts".localized].value as? String
        
        // Tap first notification if exists
        if let firstNotification = app.tables.firstMatch.cells.firstMatch {
            firstNotification.tap()
            
            // Wait for mark as read
            let readExpectation = XCTestExpectation(description: "Wait for mark as read")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                readExpectation.fulfill()
            }
            wait(for: [readExpectation], timeout: 2)
            
            // Go back to list
            app.navigationBars.buttons.element(boundBy: 0).tap()
            
            // Verify unread count decreased
            let newBadge = app.tabBars.buttons["alerts".localized].value as? String
            if let initial = initialBadge, let new = newBadge,
               let initialCount = Int(initial), let newCount = Int(new) {
                XCTAssertLessThan(newCount, initialCount)
            }
        }
    }
}

// MARK: - Helper Extension
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
} 
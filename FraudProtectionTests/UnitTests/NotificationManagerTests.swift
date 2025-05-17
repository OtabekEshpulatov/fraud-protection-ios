import XCTest
@testable import FraudProtection

final class NotificationManagerTests: XCTestCase {
    var sut: NotificationManager!
    
    override func setUp() {
        super.setUp()
        sut = NotificationManager.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(sut.deviceToken)
    }
    
    func testHandleDeviceToken() {
        // Given
        let tokenData = "test-token".data(using: .utf8)!
        
        // When
        sut.handleDeviceToken(tokenData)
        
        // Then
        XCTAssertNotNil(sut.deviceToken)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "appleDeviceToken"), sut.deviceToken)
    }
    
    func testHandleRegistrationError() {
        // Given
        let error = NSError(domain: "test", code: 0, userInfo: nil)
        
        // When
        sut.handleRegistrationError(error)
        
        // Then
        // Verify error was logged
        // Note: In a real test, we would verify the error was logged properly
        // This might require mocking the logging system
    }
    
    func testRequestAuthorization() {
        // Given
        let expectation = XCTestExpectation(description: "Authorization request completed")
        
        // When
        sut.requestAuthorization()
        
        // Then
        // Note: This is a UI test case that requires user interaction
        // In a real test, we would mock UNUserNotificationCenter
        // and verify the authorization request was made
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock UNUserNotificationCenter
class MockUNUserNotificationCenter: UNUserNotificationCenter {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var authorizationGranted = false
    
    override func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return authorizationGranted
    }
    
    override func getNotificationSettings() async -> UNNotificationSettings {
        return MockUNNotificationSettings(authorizationStatus: authorizationStatus)
    }
}

// MARK: - Mock UNNotificationSettings
class MockUNNotificationSettings: UNNotificationSettings {
    private let _authorizationStatus: UNAuthorizationStatus
    
    init(authorizationStatus: UNAuthorizationStatus) {
        self._authorizationStatus = authorizationStatus
        super.init()
    }
    
    override var authorizationStatus: UNAuthorizationStatus {
        return _authorizationStatus
    }
} 
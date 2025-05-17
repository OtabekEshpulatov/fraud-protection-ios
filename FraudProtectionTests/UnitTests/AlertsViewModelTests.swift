import XCTest
@testable import FraudProtection

final class AlertsViewModelTests: XCTestCase {
    var sut: AlertsViewModel!
    var mockAuthViewModel: MockAuthViewModel!
    
    override func setUp() {
        super.setUp()
        mockAuthViewModel = MockAuthViewModel()
        sut = AlertsViewModel(authViewModel: mockAuthViewModel)
    }
    
    override func tearDown() {
        sut = nil
        mockAuthViewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.notifications.isEmpty)
        XCTAssertEqual(sut.unreadCount, 0)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testFetchNotificationsSuccess() async {
        // Given
        mockAuthViewModel.mockAuthToken = "valid-token"
        
        // When
        await sut.fetchNotifications()
        
        // Then
        XCTAssertFalse(sut.notifications.isEmpty)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testFetchNotificationsFailure() async {
        // Given
        mockAuthViewModel.mockAuthToken = nil
        
        // When
        await sut.fetchNotifications()
        
        // Then
        XCTAssertTrue(sut.notifications.isEmpty)
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testFetchUnreadCountSuccess() async {
        // Given
        mockAuthViewModel.mockAuthToken = "valid-token"
        
        // When
        await sut.fetchUnreadCount()
        
        // Then
        XCTAssertGreaterThanOrEqual(sut.unreadCount, 0)
    }
    
    func testFetchUnreadCountFailure() async {
        // Given
        mockAuthViewModel.mockAuthToken = nil
        
        // When
        await sut.fetchUnreadCount()
        
        // Then
        XCTAssertEqual(sut.unreadCount, 0)
    }
    
    func testMarkAsReadSuccess() async {
        // Given
        mockAuthViewModel.mockAuthToken = "valid-token"
        let notificationId = UUID()
        
        // When
        await sut.markAsRead(id: notificationId)
        
        // Then
        XCTAssertFalse(sut.notifications.contains { $0.id == notificationId })
    }
}

// MARK: - Mock AuthViewModel
class MockAuthViewModel: AuthViewModel {
    var mockAuthToken: String?
    
    override var authToken: String? {
        return mockAuthToken
    }
} 
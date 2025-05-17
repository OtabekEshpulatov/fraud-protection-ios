import XCTest
@testable import FraudProtection

final class AuthViewModelTests: XCTestCase {
    var sut: AuthViewModel!
    
    override func setUp() {
        super.setUp()
        sut = AuthViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.authToken)
        XCTAssertNil(sut.error)
    }
    
    func testLoginSuccess() async {
        // Given
        let username = "testuser"
        let password = "testpass"
        
        // When
        await sut.login(username: username, password: password)
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.authToken)
        XCTAssertNil(sut.error)
    }
    
    func testLoginFailure() async {
        // Given
        let username = "invalid"
        let password = "invalid"
        
        // When
        await sut.login(username: username, password: password)
        
        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.authToken)
        XCTAssertNotNil(sut.error)
    }
    
    func testLogout() {
        // Given
        sut.isAuthenticated = true
        sut.authToken = "test-token"
        
        // When
        sut.logout()
        
        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.authToken)
    }
    
    func testRegisterSuccess() async {
        // Given
        let username = "newuser"
        let password = "newpass"
        let regionId = "test-region"
        
        // When
        var success = false
        var error: String?
        
        await sut.register(username: username, password: password, regionId: regionId) { result, err in
            success = result
            error = err
        }
        
        // Then
        XCTAssertTrue(success)
        XCTAssertNil(error)
    }
    
    func testRegisterFailure() async {
        // Given
        let username = "existinguser"
        let password = "pass"
        let regionId = "test-region"
        
        // When
        var success = false
        var error: String?
        
        await sut.register(username: username, password: password, regionId: regionId) { result, err in
            success = result
            error = err
        }
        
        // Then
        XCTAssertFalse(success)
        XCTAssertNotNil(error)
    }
} 
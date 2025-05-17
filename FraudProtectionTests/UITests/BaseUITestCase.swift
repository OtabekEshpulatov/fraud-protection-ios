import XCTest

class BaseUITestCase: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    func tapButton(_ identifier: String) {
        let button = app.buttons[identifier]
        XCTAssertTrue(waitForElement(button))
        button.tap()
    }
    
    func enterText(_ text: String, in identifier: String) {
        let textField = app.textFields[identifier]
        XCTAssertTrue(waitForElement(textField))
        textField.tap()
        textField.typeText(text)
    }
    
    func enterSecureText(_ text: String, in identifier: String) {
        let secureTextField = app.secureTextFields[identifier]
        XCTAssertTrue(waitForElement(secureTextField))
        secureTextField.tap()
        secureTextField.typeText(text)
    }
    
    func assertLabelExists(_ identifier: String, withText text: String? = nil) {
        let label = app.staticTexts[identifier]
        XCTAssertTrue(waitForElement(label))
        if let text = text {
            XCTAssertEqual(label.label, text)
        }
    }
    
    func assertButtonExists(_ identifier: String, withTitle title: String? = nil) {
        let button = app.buttons[identifier]
        XCTAssertTrue(waitForElement(button))
        if let title = title {
            XCTAssertEqual(button.label, title)
        }
    }
} 
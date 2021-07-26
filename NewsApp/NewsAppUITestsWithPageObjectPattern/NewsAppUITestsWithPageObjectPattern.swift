//
//  NewsAppUITestsWithPageObjectPattern.swift
//  NewsAppUITestsWithPageObjectPattern
//
//  Created by Petr Blinov on 23.07.2021.
//

import XCTest

extension XCUIApplication {
   
    func searchButton() -> XCUIElement {
        return self.tabBars.buttons["Search"]
    }
    func personalizeButton() -> XCUIElement {
        return self.buttons["Personalize"]
    }
    func userNameInput() -> XCUIElement {
        personalizeButton().tap()
        let personalizeAlert = self.alerts.firstMatch
        let textField = personalizeAlert.textFields.element
        return textField
    }
    func doneButton() -> XCUIElement {
        return self.alerts.element.buttons["Done"]
    }
}


protocol Page {
    var app: XCUIApplication { get }
    init(app: XCUIApplication)
}

class SearchPage: Page {
    var app: XCUIApplication
    required init(app: XCUIApplication) {
        self.app = app
    }
    func enterUserName(userName: String) {
        let userNameField = XCUIApplication().userNameInput()
        userNameField.tap()
        userNameField.typeText(userName)
    }
    func tapDoneButton() {
        XCUIApplication().doneButton().tap()
    }
}


class NewsAppUITestsWithPageObjectPattern: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testThatUserNameEnteredViaPerpersonalizeButtonGoesToSearchBarPlaceholder() throws {
        
        // Arrange
        app.searchButton().tap()
        let searchPage = SearchPage(app: app)
        
        // Act
        searchPage.enterUserName(userName: "John")
        searchPage.tapDoneButton()
        
        // Assert
        let searchFieldPlaceholderText = app.searchFields.firstMatch.placeholderValue
        XCTAssertTrue(searchFieldPlaceholderText == "John, enter a keyword to search for")
    }
}

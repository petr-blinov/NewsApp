//
//  NewsAppUITests.swift
//  NewsAppUITests
//
//  Created by Petr Blinov on 10.07.2021.
//

import XCTest

class NewsAppUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    override func tearDownWithError() throws {
    }
    
    func testThatNewsAndSearchAndSavedButtonsExistOnTabBar() throws {
        // Arrange
        let newsButton = app.tabBars.buttons["News"]
        let searchButton = app.tabBars.buttons["Search"]
        let savedButton = app.tabBars.buttons["Saved"]
        // Act
        // Assert
        XCTAssertTrue(newsButton.exists)
        XCTAssertTrue(searchButton.exists)
        XCTAssertTrue(savedButton.exists)
    }
    
    func testThatPersonalizeButtonExistsWhenWeTapSearchButtonAndMoveToSearchViewController() throws {
        // Arrange
        let searchButton = app.tabBars.buttons["Search"]
        let personalizeButton = app.buttons["Personalize"]
        // Act
        searchButton.tap()
        // Assert
        XCTAssertTrue(personalizeButton.exists)
    }
    
    func testThatPersonalizeButtonExistsWhenWeTapSavedButtonAndMoveToSavedNewsViewController() throws {
        // Arrange
        let savedButton = app.tabBars.buttons["Saved"]
        let personalizeButton = app.buttons["Remove all"]
        // Act
        savedButton.tap()
        // Assert
        XCTAssertTrue(personalizeButton.exists)
    }
    
}

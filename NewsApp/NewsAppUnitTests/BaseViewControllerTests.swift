//
//  BaseViewControllerTests.swift
//  NewsAppUnitTests
//
//  Created by Petr Blinov on 10.07.2021.
//

import XCTest
@testable import NewsApp

class BaseViewControllerTests: XCTestCase {
    
    let sut = BaseViewController()
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testThatSpinnerIsNotShowingWhenIsLoadingIsFalse() throws {
        // Arrange
        sut.isLoading = true
        sut.isLoading = false
        // Act
        let result = sut.showSpinner(isShown: sut.isLoading)
        // Assert
        XCTAssertFalse(result)
    }
    
    func testThatSpinnerIsShowingWhenIsLoadingIsTrue() throws {
        // Arrange
        sut.isLoading = false
        sut.isLoading = true
        // Act
        let result = sut.showSpinner(isShown: sut.isLoading)
        // Assert
        XCTAssertTrue(result)
    }
}

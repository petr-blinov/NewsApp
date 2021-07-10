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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

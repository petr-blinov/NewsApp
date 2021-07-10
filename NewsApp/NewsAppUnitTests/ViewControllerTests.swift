//
//  ViewControllerTests.swift
//  NewsAppUnitTests
//
//  Created by Petr Blinov on 10.07.2021.
//

import XCTest
@testable import NewsApp

class ViewControllerTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testThatViewDidLoadChangesPageConstantToOne() throws {
        // Arrange
        let networkServiceDummy = NetworkServiceDummy()
        let sut = ViewController(networkService: networkServiceDummy)
        
        // Act
        Constants.page = 2
        sut.viewDidLoad()
        
        // Assert
        XCTAssertEqual(Constants.page, 1)
    }
}

class NetworkServiceDummy: NetworkServiceProtocol  {
    func loadImage(with model: Get2ArticleDataResponse, completion: @escaping (Data?) -> Void) {
        // do nothing
    }
    func getArticles(searchRequest: String, completion: @escaping (GetAPIResponse) -> Void) {
        // do nothing
    }
}

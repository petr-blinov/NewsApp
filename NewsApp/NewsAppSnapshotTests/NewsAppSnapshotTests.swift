//
//  NewsAppSnapshotTests.swift
//  NewsAppSnapshotTests
//
//  Created by Petr Blinov on 10.07.2021.
//

import XCTest
import SnapshotTesting
@testable import NewsApp

class NewsAppSnapshotTests: XCTestCase {
    var sut: SearchViewController!

    override func setUpWithError() throws {
        let networkServiceDummy = NetworkServiceDummy()
        sut = SearchViewController(networkService: networkServiceDummy)
    }

    override func tearDownWithError() throws {
    }

    func testThatSearchViewControllerScreenSpapshotMatchesSavedPrototype() throws {
        // Arrange
        // Act
        // Assert
        assertSnapshot(matching: sut, as: .image)
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

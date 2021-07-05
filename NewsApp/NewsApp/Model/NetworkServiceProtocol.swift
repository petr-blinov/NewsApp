//
//  NetworkServiceProtocol.swift
//  NewsApp
//
//  Created by Петр Блинов on 03.06.2021.
//

import Foundation


typealias GetAPIResponse = Result<Get1Response, NetworkServiceError>

protocol NetworkServiceProtocol {
    func getArticles(searchRequest: String, completion: @escaping (GetAPIResponse) -> Void)
    func loadImage(with model: Get2ArticleDataResponse, completion: @escaping(Data?) -> Void)
}



//let source: [Source]
//let author: String?
//let title: String
//let description: String
//let url: String
//let urlToImage: String
//let publishedAt: String
//let content: String

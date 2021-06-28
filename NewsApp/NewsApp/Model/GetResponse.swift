//
//  GetResponse.swift
//  Lesson17HomeworkNewsApp
//
//  Created by Петр Блинов on 03.06.2021.
//


struct Get1Response: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Get2ArticleDataResponse]
}

struct Get2ArticleDataResponse: Decodable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct Source: Decodable {
    let id: String?
    let name: String
}


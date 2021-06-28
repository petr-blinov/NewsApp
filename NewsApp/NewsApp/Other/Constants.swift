//
//  Constants.swift
//  Lesson17HomeworkNewsApp
//
//  Created by Петр Блинов on 03.06.2021.
//

enum Constants {
    
    enum Authorization {
        static let apiKey = "29183b721367490ba8a23ff3a6b84fd9"
    }
    
    enum APIMethods {
        static let getTopHeadlines = "https://newsapi.org/v2/top-headlines"
    }
    
    static var page: Int = 1
    static var searchRequest: String = ""
}

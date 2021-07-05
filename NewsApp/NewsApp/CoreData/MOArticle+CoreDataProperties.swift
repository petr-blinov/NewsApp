//
//  MOArticle+CoreDataProperties.swift
//  NewsApp
//
//  Created by Petr Blinov on 04.07.2021.
//
//

import Foundation
import CoreData


extension MOArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOArticle> {
        return NSFetchRequest<MOArticle>(entityName: "MOArticle")
    }

    @NSManaged public var articleTitle: String?
    @NSManaged public var articlePublishedAt: String?
    @NSManaged public var articleContent: String?
    @NSManaged public var sourceLink: String?
    @NSManaged public var linkForWebView: String?

}

extension MOArticle : Identifiable {

}

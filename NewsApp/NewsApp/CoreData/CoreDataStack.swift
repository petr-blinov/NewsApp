//
//  CoreDataStack.swift
//  NewsApp
//
//  Created by Petr Blinov on 03.07.2021.
//

import Foundation
import CoreData

final class CoreDataStack {

    static let shared = CoreDataStack()

    let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsApp")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        return container
    }()

    private init() {}
}

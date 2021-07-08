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
    
    private init() {}
    
    let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsApp")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext { container.viewContext }
    lazy var backgroundContext: NSManagedObjectContext = container.newBackgroundContext()
    var coordinator: NSPersistentStoreCoordinator { container.persistentStoreCoordinator }
    
    func deleteAll() {
        let fetchRequest = NSFetchRequest<MOArticle>(entityName: "MOArticle")
        backgroundContext.performAndWait {
            let articles = try? fetchRequest.execute()
            articles?.forEach {
                backgroundContext.delete($0)
            }
            try? backgroundContext.save()
        }
    }
    func deleteByIndexPath(indexPath: IndexPath) {
        let fetchRequest = NSFetchRequest<MOArticle>(entityName: "MOArticle")
        backgroundContext.performAndWait {
            guard let articles = try? fetchRequest.execute() else { return }
            backgroundContext.delete(articles[indexPath.row])
            try? backgroundContext.save()
        }
    }
}

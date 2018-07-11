//
//  CoreDataStack.swift
//  NewsFeed
//
//  Created by MArko Satlan on 23/06/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

// MARK: - Properties
    private let modelName: String
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error - \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
       return self.storeContainer.viewContext
    }()
    
// MARK: - Methods
    //Init
    init(modelName: String) {
        self.modelName = modelName
    }
    
    //CoreData related methods
    func saveContext() {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
}

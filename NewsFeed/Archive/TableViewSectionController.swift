//
//  TableViewSectionController.swift
//  NewsFeed
//
//  Created by MArko Satlan on 07/07/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TableViewSectionController {

// MARK: - Properties
    let tableView: UITableView
    let managedContext: NSManagedObjectContext
    var allSectionsArray: [TableViewSection] = []
    var sectionCount: Int {
        get {
            return allSectionsArray.count
        }
    }

// MARK: - Methods
    // Init
    required init(tableView: UITableView, managedContext: NSManagedObjectContext) {
        self.tableView = tableView
        self.managedContext = managedContext
        
        // Core Data - perform fetch of all articles
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        var allArticles: [Article] = []
        
        do {
            allArticles = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        let allArticlesSortedArray = allArticles.sorted(by: { $0.category! < $1.category! })
        
        createSections(from: allArticlesSortedArray)
    }
  
    // 
    func createSections(from articles: [Article]) {
        var currentCategory = ""
        var currentSection: TableViewSection? = nil
        var allSectionsArray: [TableViewSection] = []
        
        for article in articles {
            if article.category != currentCategory {
                currentCategory = article.category!
                currentSection = TableViewSection(withSectionName: article.category!)
                allSectionsArray.append(currentSection!)
            }
            
            if let section = currentSection {
                section.addArticles(article: article)
            }
        }
        
        self.allSectionsArray = allSectionsArray
    }
    
    func deleteArticle(at indexPath: IndexPath) {
        
        let articleToRemove = allSectionsArray[indexPath.section].articleArray[indexPath.row]
        
        // check if section needs to be deleted (number of items in section)
            // 1. don't delete section -> delete article only
        if allSectionsArray[indexPath.section].articleArray.count > 1 {
            // remove from Core Data
            managedContext.delete(articleToRemove)
            
            do {
                try managedContext.save()
                // if save is successfull
                    // 1. remove article form data array
                    allSectionsArray[indexPath.section].articleArray.remove(at: indexPath.row)
                    // 2. remove cells from table view
                    tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error as NSError {
                print("Error saving to Core Data: \(error), \(error.userInfo)")
            }
        } else {
            // 2. delete the section and remaining article
            managedContext.delete(articleToRemove)
            
            do {
                // save is successfull
                try managedContext.save()
                // remove from sections data array
                allSectionsArray.remove(at: indexPath.section)
                // remove section from table view
                tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section), with: .fade)
            } catch let error as NSError {
                print("Error saving to Core Data: \(error), \(error.userInfo)")
            }
        }
    }
    
    func titleForHeader(inSection section: Int) -> String {
       return allSectionsArray[section].name.uppercased()
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return allSectionsArray[section].articleArray.count
    }
    
    func article(atIndexPath indexPath: IndexPath) -> Article {
        return allSectionsArray[indexPath.section].articleArray[indexPath.row]
    }
}

//
//  Article+CoreDataProperties.swift
//  NewsFeed
//
//  Created by MArko Satlan on 24/06/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var title: String?
    @NSManaged public var date: String?
    @NSManaged public var category: String?
    @NSManaged public var articleDescription: String?
    @NSManaged public var sourceName: String?
    @NSManaged public var author: String?
    @NSManaged public var url: String?
    @NSManaged public var photoData: NSData?
}

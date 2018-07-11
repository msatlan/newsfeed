//
//  UITableViewSection.swift
//  NewsFeed
//
//  Created by MArko Satlan on 02/07/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

class TableViewSection {
    
// MARK: - Properties
    var name: String
    var articleArray: [Article] = []

// MARK: - Methods
    // Init
    init(withSectionName name: String) {
        self.name = name
    }
    
    func addArticles(article: Article) {
        articleArray.append(article)
    }
    
}

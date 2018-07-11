//
//  ArchiveTableViewController.swift
//  NewsFeed
//
//  Created by MArko Satlan on 28/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit
import CoreData

class ArchiveTableViewController: UITableViewController {

// MARK: - Properties
    var managedContext: NSManagedObjectContext!
    
    // Private
    private var tableViewSectionController: TableViewSectionController!
    private var indexPathOfSentArticle: IndexPath!
    
// MARK: - Methods
    // View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "News Feed", style: .plain, target: self, action: #selector(popToMainMenuViewController))
        
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.3)
        tableView.sectionHeaderHeight = 40
        
        // init table view section controller
        tableViewSectionController = TableViewSectionController(tableView: self.tableView, managedContext: managedContext)
    }
  
    // Prepare-for-segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowArchievedArticle" {
            let controller = segue.destination as! NewsDetailsViewController
            controller.receivedArchivedArticle = sender as? Article
            controller.managedContext = managedContext
            controller.delegate = self
        } else if segue.identifier == "ShowMainMenu" {
            let navigationController = segue.destination as? UINavigationController
            let controller = navigationController?.topViewController as! MainMenuViewController
            controller.managedContext = managedContext
        }
    }
    
    // Perform segue to main menu view controller
    @objc private func popToMainMenuViewController() {
        performSegue(withIdentifier: "ShowMainMenu", sender: nil)
    }
    
// MARK: - Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSectionController.sectionCount
    }
  
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewSectionController.titleForHeader(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewSectionController.numberOfRows(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveCell", for: indexPath)
        
        let article = tableViewSectionController.article(atIndexPath: indexPath)
        
        cell.textLabel?.backgroundColor = UIColor.black
        cell.textLabel?.font = UIFont.georgia(ofSize: 17)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = article.title
        
        cell.detailTextLabel?.backgroundColor = UIColor.black
        cell.detailTextLabel?.font = UIFont.georgia(ofSize: 14)
        cell.detailTextLabel?.text = "Published on \(article.date!)"
        cell.detailTextLabel?.textColor = UIColor(white: 1.0, alpha: 0.65)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableViewSectionController.deleteArticle(at: indexPath)
        }
    }
 
// MARK: - Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = tableViewSectionController.article(atIndexPath: indexPath)
        indexPathOfSentArticle = indexPath
        performSegue(withIdentifier: "ShowArchievedArticle", sender: article)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveCell", for: indexPath)
        cell.backgroundColor = UIColor.black
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveCell", for: indexPath!)
        cell.backgroundColor = UIColor.black
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15,
                               y: 10,
                               width: 300,
                               height: tableView.sectionHeaderHeight - 20)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.georgia(ofSize: 20)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 0.4)
        label.backgroundColor = UIColor.clear
        
        let separatorRect = CGRect(x: 15,
                                   y: tableView.sectionHeaderHeight - 0.5,
                                   width: tableView.bounds.size.width - 15,
                                   height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        
        let viewRect = CGRect(x: 0,
                              y: 0,
                              width: tableView.bounds.size.width,
                              height: tableView.bounds.size.height)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor.black
        view.addSubview(label)
        view.addSubview(separator)
        
        return view
    }
}

extension ArchiveTableViewController: NewsDetailsViewControllerDelegate {
    func newsDetailsViewController(deleteArchivedArticleButtonTapped controller: NewsDetailsViewController) {
        tableViewSectionController.deleteArticle(at: indexPathOfSentArticle)
    }
}





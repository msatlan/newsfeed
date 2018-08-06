//
//  ViewController.swift
//  NewsFeed
//
//  Created by MArko Satlan on 13/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit
import CoreData

class MainMenuViewController: UIViewController {

// MARK: - Properties
    var managedContext: NSManagedObjectContext!
    let serverRequest = ServerRequest()
    var selectedLanguage = ServerRequest.Language.american.rawValue
    var newsCategory = ""
    
// MARK: - Constants
    let segmentedControlIndexKey = "SegmentedControlIndex"
    let languageKey = "Language"
    
// MARK: - @IBOutlets
    //@IBOutlet weak var segmentedControl: ScrollableSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: CustomButton!
    @IBOutlet weak var segmentedControl: ScrollableSegmentedControl!

// MARK: - @IBAction
    
    @IBAction func valueChanged(_ sender: ScrollableSegmentedControl) {
        serverRequest.isLoading = true
        
        performHTTPSRequest()
        
        // save selected index to UserDefaults for later use(segue from ArchiveTableView to MainMenu)
        UserDefaults.standard.set(segmentedControl.selectedSegmentIndex, forKey: segmentedControlIndexKey)
        
        tableView.reloadData()
    }

// MARK: - Methods
    //View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        segmentedControl.setItems(ServerRequest.Category.all)
        segmentedControl.buttonMargin = 30
        segmentedControl.buttonSpacing = 40
        segmentedControl.font = UIFont(name: "Georgia", size: 15)
        segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: segmentedControlIndexKey)
        
        performHTTPSRequest()
        
        configureButtonTitle()
    }
    
    // Networking
    func performHTTPSRequest() {
        // 1. perform request with saved language if it exists
        if let language = UserDefaults.standard.object(forKey: languageKey) {
            
            if let category = ServerRequest.Category(rawValue: segmentedControl.selectedSegmentIndex),
                let language = ServerRequest.Language(rawValue: language as! String) {
                
                selectedLanguage = language.rawValue
                newsCategory = category.string
                
                serverRequest.performRequest(with: language , and: category, completion: {
                    success in
                    
                    if !success {
                        self.showNetworkError()
                    }
                    self.tableView.reloadData()
                })
            }
        } else {
        // 2. perform request with selected language
            if let category = ServerRequest.Category(rawValue: segmentedControl.selectedSegmentIndex),
                let language = ServerRequest.Language(rawValue: selectedLanguage) {
            
                newsCategory = category.string
         
                serverRequest.performRequest(with: language , and: category, completion: {
                    success in
                
                    if !success {
                        self.showNetworkError()
                    }
                    self.tableView.reloadData()
                })
            }
        }
    }
 
    private func showNetworkError() {
        let alert = UIAlertController(title: "Network error", message: "There was an error retreiving data from the host", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Private
    private func configureTableView() {
        tableView.rowHeight = 140
        
        var cellNib = UINib(nibName: "NewsCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "NewsCell")
        cellNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "LoadingCell")
    }
    
    private func configureButtonTitle() {
        if let language = ServerRequest.Language(rawValue: selectedLanguage) {
            let title = language.titleForButton
            button.setTitle(title, for: .normal)
        }
    }
    
    //Prepare-for-segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectCountry" {
            let controller = segue.destination as! CountryViewController
            controller.delegate = self
        } else if segue.identifier == "SelectNews" {
            let controller = segue.destination as! NewsDetailsViewController
            controller.news = sender as? News
            controller.managedContext = self.managedContext
            controller.newsCategory = newsCategory
        } else if segue.identifier == "AccessArchive" {
            let navigationController = segue.destination as? UINavigationController
            let controller = navigationController?.topViewController as! ArchiveTableViewController
            controller.managedContext = managedContext
        }
    }
}

extension MainMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if serverRequest.isLoading {
            return 1
        } else {
            return serverRequest.newsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if serverRequest.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            let newsArticle = serverRequest.newsArray[indexPath.row]
            cell.configure(for: newsArticle)
            
            return cell
        }
    }
}

extension MainMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = serverRequest.newsArray[indexPath.row]
        performSegue(withIdentifier: "SelectNews", sender: news)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MainMenuViewController: CountryViewControllerDelegate {
    
    func countryViewController(_ controller: CountryViewController, didSelectLanguage language: String) {
        selectedLanguage = language
        
        // Save selected language to UserDefaults for later use(segue from ArchiveTableView to Main Menu)
        UserDefaults.standard.set(selectedLanguage, forKey: languageKey)
        
        segmentedControl.selectedSegmentIndex = 0
        
        // Save selected index to UserDefaults for later use(segue from ArchiveTableView to Main Menu)
        UserDefaults.standard.set(segmentedControl.selectedSegmentIndex, forKey: segmentedControlIndexKey)
        
        performHTTPSRequest()
        
        configureButtonTitle()
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}


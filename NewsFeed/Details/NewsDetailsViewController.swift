//
//  NewsDetailsViewController.swift
//  NewsFeed
//
//  Created by MArko Satlan on 23/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit
import CoreData

protocol NewsDetailsViewControllerDelegate: class {
    func newsDetailsViewController(deleteArchivedArticleButtonTapped controller: NewsDetailsViewController)
}

class NewsDetailsViewController: UIViewController {
    
// MARK: - Properties
    var news: News!
    var receivedArchivedArticle: Article?
    var managedContext: NSManagedObjectContext!
    var newsCategory = ""
    
    // Delegate
    weak var delegate: NewsDetailsViewControllerDelegate?
    
    // Private
    private var stringFromDate = ""
    private var downloadTask: URLSessionDownloadTask?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    private var hudView: HudView!
    private var imageData: Data?
    
// MARK: - @IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var webSiteButton: UIButton!
    @IBOutlet weak var archiveButton: UIButton!
    
// MARK: - @IBAction
    @IBAction func visitWebsite(_ sender: Any) {
        if let receivedArticle = receivedArchivedArticle,
            let url = URL(string: receivedArticle.url!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            if let url = URL(string: news.URL!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func archiveButtonTapped(_ sender: Any) {
        // 1. in archive table view - delete article
        if receivedArchivedArticle != nil {
            showDeletionAlert()
        } else {
        // 2. in news details table view - archive article
            var resultsArray: [Article] = []
            
            // fetch all articles to check if article exists
            let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
            do {
                let results = try managedContext.fetch(fetchRequest)
                resultsArray = results
            } catch let error as NSError {
                print("Fetch error: \(error), \(error.userInfo)")
            }
            
            // check must be made before attributes are assigned to entity, else article is made and title always exsists
            var articleExists = false
            
            for fetchedArticle in resultsArray {
                if news.title == fetchedArticle.title {
                    articleExists = true
                    showArchiveAlert()
                    break
                } else {
                    articleExists = false
                }
            }
            
            if articleExists == false {
                assignValueToAttributesAndSave()
                showHUDView()
                removeHUDView()
            }
        }
    }
    
// MARK: - Methods
    
    // View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(webSiteButton, imageNormal: "readOnWebSiteNormal", imageHighlighted: "readOnWebSiteHighlighted")
        configure(archiveButton, imageNormal: "archiveNormal", imageHighlighted: "archiveHighlighted")
    
        updateUI()
    }
    
    // Private
    private func configure(_ button: UIButton, imageNormal: String , imageHighlighted: String) {
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setBackgroundImage(UIImage(named: imageNormal), for: .normal)
        button.setBackgroundImage(UIImage(named: imageHighlighted), for: .highlighted)
        button.titleLabel?.font = UIFont.georgia(ofSize: 15)
    }
    
    private func updateUI() {
        if let receivedArticle = receivedArchivedArticle {
            titleLabel.text = receivedArticle.title
            sourceLabel.text = receivedArticle.sourceName
            authorLabel.text = receivedArticle.author
            descriptionLabel.text = receivedArticle.articleDescription
            dateLabel.text = receivedArticle.date
            
            if let imageData = receivedArticle.photoData as Data? {
                imageView.image = UIImage(data: imageData)
            } else {
                imageView.image = UIImage(named: "NoPreviewLarge")
            }
            
            archiveButton.setTitle("Delete From Archive", for: .normal)
        } else {
            titleLabel.text = news.title
            sourceLabel.text = news.sourceName
            authorLabel.text = news.author
            descriptionLabel.text = news.description
            if let date = dateFormatter.date(from: news.dateOfPublication) {
                dateFormatter.dateFormat = "dd.MM.yyyy.', 'HH:mm:ss"
                stringFromDate = dateFormatter.string(from: date)
                dateLabel.text = stringFromDate
            }
         
            if let image = URL(string: news.imageURL) {
                loadImage(url: image)
            } else {
                imageView.image = UIImage(named: "NoPreviewLarge")
            }
        }
    }
    
    private func showDeletionAlert() {
        let alertController = UIAlertController(title: "Warning:",
                                                message: "Deleting will remove the article form the archive.",
                                                preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete article",
                                          style: .default,
                                          handler: {
                                            _ in
                                            self.delegate?.newsDetailsViewController(deleteArchivedArticleButtonTapped: self)
                                            self.performSegue(withIdentifier: "ReturnToArchive", sender: self.archiveButton)
        })
        alertController.addAction(deleteAction)
        
        let dontDeleteAction = UIAlertAction(title: "Back to article",
                                              style: .default,
                                              handler: nil)
        alertController.addAction(dontDeleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showArchiveAlert() {
        let alertController = UIAlertController(title: "Article already archived",
                                                message: "Archiving will result in another copy of existing article. \n\nArchive anyway?",
                                                preferredStyle: .alert)
        let archiveAction = UIAlertAction(title: "Archive",
                                          style: .default,
                                          handler: {
                                            _ in self.assignValueToAttributesAndSave()
                                            self.showHUDView()
                                            self.removeHUDView()
        })
        alertController.addAction(archiveAction)
        
        let dontArchiveAction = UIAlertAction(title: "Don't archive",
                                              style: .default,
                                              handler: nil)
        alertController.addAction(dontArchiveAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func showHUDView() {
        hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Archived!"
    }
    
    private func removeHUDView() {
        afterDelay(0.7, closure: {
            self.hudView.removeFromSuperview()
            self.navigationController!.view.isUserInteractionEnabled = true
        })
    }
    
    private func assignValueToAttributesAndSave() {
        // assign value to attributes of Core Data entity - Article
        let article = Article(context: managedContext)
        article.title = news.title
        article.date = stringFromDate
        article.category = newsCategory
        article.articleDescription = news.description
        article.sourceName = news.sourceName
        article.author = news.author
        article.url = news.URL
        
        if let data = imageData {
            article.photoData = data as NSData
        }
        
        // save to Core Data
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Save error: \(error, error.userInfo)")
        }
    }
    
    private func loadImage(url: URL) {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url, completionHandler: {
            url, response, error in
            if error == nil,
                let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                self.imageData = data
    
                DispatchQueue.main.async {
                   self.imageView.image = image
                }
            }
        })
        downloadTask.resume()
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReturnToArchive" {
            let navigationController = segue.destination as? UINavigationController
            let viewController = navigationController?.topViewController as! ArchiveTableViewController
            viewController.managedContext = managedContext
            
        }
    }
}
















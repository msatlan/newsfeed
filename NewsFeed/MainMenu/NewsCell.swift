//
//  NewsCell.swift
//  NewsFeed
//
//  Created by MArko Satlan on 13/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

// MARK: - Properties
    var downloadTask: URLSessionDownloadTask?
    
// MARK: - @IBOutlets
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        newsImageView.layer.cornerRadius = 6
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
    }
    
// MARK: - methods
    func configure(for newsArticle: News) {
        titleLabel.text = "\(newsArticle.title)"
        titleLabel.font = UIFont.georgia(ofSize: 12)
        sourceLabel.text = "Source: \(newsArticle.sourceName)"
        sourceLabel.font = UIFont.georgia(ofSize: 12)
        if let image = URL(string: newsArticle.imageURL) {
            downloadTask = newsImageView.loadImage(url: image)
            
            
        } else {
            newsImageView.image = UIImage(named: "noPreview")
        }
    }
}

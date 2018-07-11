//
//  HTTPSRequest.swift
//  NewsFeed
//
//  Created by MArko Satlan on 27/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import Foundation

typealias ResponseSuccessfull = (Bool) -> ()

class ServerRequest {
    
// MARK: - Properties
    var newsArray: [News] = []
    var isLoading = false
    
    enum Category: Int {
        case topArticles            = 0
        case businessArticles       = 1
        case entertainmentArticles  = 2
        case scienceArticles        = 3
        case sportsArticles         = 4
        
        var searchParameter: String {
            switch self {
            case .topArticles:              return ""
            case .businessArticles:         return "&category=business"
            case .entertainmentArticles:    return "&category=entertainment"
            case .scienceArticles:          return "&category=science"
            case .sportsArticles:           return "&category=sports"
            }
        }
        
        var string: String {
            switch self {
            case .topArticles:              return "Top Articles"
            case .businessArticles:         return "Business Articles"
            case .entertainmentArticles:    return "Entertainment Articles"
            case .scienceArticles:          return "Science Articles"
            case .sportsArticles:           return "Sports Articles"
            }
        }
    }
    
    enum Language: String {
        case serbian =      "rs"
        case slovenian =    "si"
        case german =       "de"
        case french =       "fr"
        case english =      "gb"
        case american =     "us"
        
        var titleForButton: String {
            switch self {
            case .serbian:      return "Serbian News"
            case .slovenian:    return "Slovenian News"
            case .german:       return "German News"
            case .french:       return "French News"
            case .english:      return "English News"
            case .american:     return "US News"
            }
        }
    }

    // Private
    private var dataTask: URLSessionDataTask?
    
// MARK: - Methods
    func performRequest(with language: Language, and category: Category, completion: @escaping ResponseSuccessfull) {
        isLoading = true
        newsArray = []
        
        let url = URL(string: String(format: "https://newsapi.org/v2/top-headlines?country=%@%@&apiKey=39790fa530af49b2959970d6868f359c",language.rawValue, category.searchParameter))
        let session = URLSession.shared
        dataTask = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            
            var success = false
            
            if let error = error as NSError?, error.code == -999 {
                return // request cancelled
            }
            
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let jsonData = data,
                let jsonDictionary = self.parse(json: jsonData) {
                
                self.newsArray = self.parse(dictionary: jsonDictionary)
                
                self.isLoading = false
                success = true
                }
                
                if !success {
                    self.isLoading = false
                }
                
                DispatchQueue.main.async {
                    completion(success)
                }
        })
        dataTask?.resume()
    }
    
    private func parse(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON error: \(error)")
            return nil
        }
    }
    
    private func parse(dictionary: [String: Any]) -> [News] {
        guard let array = dictionary["articles"] as? [Any] else { return [] }
        
        var newNewsArray: [News] = []
        
        for resultDict in array {
            if let resultDict = resultDict as? [String: Any] {
                let news = News()
                
                if let sourceDictionary = resultDict["source"] as? [String: Any] {
                    news.sourceName = sourceDictionary["name"] as! String
                }
                
                if let title = resultDict["title"] as? String {
                    news.title = title
                }
                
                if let author = resultDict["author"] as? String {
                    news.author = author
                } else {
                    news.author = "Unknown author"
                }
                
                if let imageURL = resultDict["urlToImage"] as? String {
                    news.imageURL = imageURL
                }
                
                if let date = resultDict["publishedAt"] as? String {
                    news.dateOfPublication = date
                }
                
                if let description = resultDict["description"] as? String {
                    news.description = description
                } else {
                    news.description = "- Description not available"
                }
                
                if let url = resultDict["url"] as? String {
                    news.URL = url
                }
                
                newNewsArray.append(news)
            }
        }
        return newNewsArray
    }
}

//
//  Book.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 4/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import Foundation

class Book: Comparable, Hashable {
    
    //MARK: - Stored properties
    let title: String
    let authors: [String]
    let tags: TagsSet
    let pdfUrl: URL?
    let coverImage: AsyncImage
    
    //MARK: - Initialization
    init(title: String, authors: [String], tags: TagsSet, pdfUrl: URL?, coverUrl: URL?){
        self.title = title
        self.authors = authors
        self.tags = tags
        self.pdfUrl = pdfUrl
        self.coverImage = AsyncImage(bookTitle: self.title, remoteUrlImage: coverUrl, placeholderName: "noImage.png")
    }
    
    //MARK: - Proxies
    var proxyForComparison: String {
        get {
            return "\(title.uppercased())"
        }
    }
    
    var proxyForSorting: String {
        get {
            return proxyForComparison
        }
    }
    
    //MARK: - Hashable
    var hashValue: Int {
        get{
            return title.hashValue
        }
    }
    
    //MARK: - Computed properties
    var favorite: Bool {
        set {
            let userDefaults = UserDefaults.standard
            var favoritesDict = userDefaults.object(forKey: favorites) as? [String: Bool] ?? [String: Bool]()
            if newValue {
                favoritesDict.updateValue(newValue, forKey: "\(self.hashValue)")
            } else {
                favoritesDict.removeValue(forKey: "\(self.hashValue)")
            }
            if favoritesDict.count == 0 {
                userDefaults.removeObject(forKey: favorites)
            } else {
                userDefaults.set(favoritesDict, forKey: favorites)
            }
            userDefaults.synchronize()
            
            // Notificar a todo dios diciendo que tengo nuevo status de favorito
            let nc = NotificationCenter.default
            let notif = Notification(name: Notification.Name(rawValue: FavoriteDidChangeNotification), object: self, userInfo: [BookKey: self])
            nc.post(notif)
        }
        get {
            let userDefaults = UserDefaults.standard
            guard let favoritesDict = userDefaults.dictionary(forKey: favorites) else {
                return false
            }
            var bFlag = false
            if let val = favoritesDict["\(self.hashValue)"] {
                bFlag = val as! Bool
            }
            return bFlag
        }
    }
}

//MARK: - Equatable & Comparable
func ==(lhs: Book, rhs: Book) -> Bool{
    guard (lhs !== rhs) else {
        return true
    }
    
    return lhs.proxyForComparison == rhs.proxyForComparison
}

func <(lhs: Book, rhs: Book) -> Bool {
    return lhs.proxyForSorting < rhs.proxyForSorting
}

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
    let pdfUrl: NSURL?
    let coverImage: AsyncImage
    
    //MARK: - Initialization
    init(title: String, authors: [String], tags: TagsSet, pdfUrl: NSURL?, coverUrl: NSURL?){
        self.title = title
        self.authors = authors
        self.tags = tags
        self.pdfUrl = pdfUrl
        self.coverImage = AsyncImage(bookTitle: self.title, remoteUrlImage: coverUrl, placeholderName: "noImage.png")
    }
    
    //MARK: - Proxies
    var proxyForComparison: String {
        get {
            return "\(title.uppercaseString)"
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
            let userDefaults = NSUserDefaults.standardUserDefaults()
            var favoritesDict = userDefaults.objectForKey(favorites) as? [String: Bool] ?? [String: Bool]()
            if newValue {
                favoritesDict.updateValue(newValue, forKey: "\(self.hashValue)")
            } else {
                favoritesDict.removeValueForKey("\(self.hashValue)")
            }
            if favoritesDict.count == 0 {
                userDefaults.removeObjectForKey(favorites)
            } else {
                userDefaults.setObject(favoritesDict, forKey: favorites)
            }
            userDefaults.synchronize()
            
            // Notificar a todo dios diciendo que tengo nuevo status de favorito
            let nc = NSNotificationCenter.defaultCenter()
            let notif = NSNotification(name: FavoriteDidChangeNotification, object: self, userInfo: [BookKey: self])
            nc.postNotification(notif)
        }
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            guard let favoritesDict = userDefaults.dictionaryForKey(favorites) else {
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
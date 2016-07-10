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
    let tags: Set<Tag>
    let pdfUrl: NSURL?
    let coverImage: AsyncImage
    var isFavorite: Bool
    
    //MARK: - Computed properties
    
    //MARK: - Initialization
    init(title: String, authors: [String], tags: Set<Tag>, pdfUrl: NSURL?, coverUrl: NSURL?, favorite: Bool){
        self.title = title
        self.authors = authors
        self.tags = tags
        self.pdfUrl = pdfUrl
        self.coverImage = AsyncImage(bookTitle: self.title, remoteUrlImage: coverUrl, placeholderName: "noImage.png")
        self.isFavorite = favorite
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
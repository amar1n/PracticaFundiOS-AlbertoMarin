//
//  Tag.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 5/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import Foundation

class Tag: Comparable, Hashable {
    
    //MARK: - Stored properties
    let name: String
    
    //MARK: - Initialization
    init(name: String) {
        self.name = name
    }
    
    //MARK: - Proxies
    var proxyForComparison: String {
        get {
            return "\(name.uppercaseString)"
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
            return name.hashValue
        }
    }
}

//MARK: - Equatable & Comparable
func ==(lhs: Tag, rhs: Tag) -> Bool {
    guard (lhs !== rhs) else {
        return true
    }
    
    return lhs.proxyForComparison == rhs.proxyForComparison
}

func <(lhs: Tag, rhs: Tag) -> Bool {
    if lhs.name == favoritesTag {
        return true
    }
    return lhs.proxyForSorting < rhs.proxyForSorting
}
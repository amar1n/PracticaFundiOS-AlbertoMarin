//
//  Library.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 4/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import Foundation

class Library {
    
    //MARK: - Utility Types
    typealias BooksSet = Set<Book>
    typealias BooksDictionary = [Tag: BooksSet]
    
    //MARK: - Properties
    var books: BooksSet
    var tags: Set<Tag>
    var library: BooksDictionary = BooksDictionary()
    
    //MARK: - Initialization
    init(books: BooksSet){
        self.books = books
        tags = Set()
        for book in books {
            for tag in book.tags {
                tags.insert(tag)
                if ((library[tag] == nil)) {
                    library[tag] = BooksSet()
                }
                library[tag]?.insert(book)
            }
        }
    }
    
    //MARK: - Methods
    var booksCount: Int {
        get {
            return books.count
        }
    }
    
    var tagsCount: Int {
        get {
            return tags.count
        }
    }
    
    func tagBy(name: String) -> Tag? {
        let aux = Tag(name: name)
        if tags.contains(aux) {
            return aux
        } else {
            return nil
        }
    }
    
    func bookCountForTag(tag: Tag?) -> Int {
        guard let t = tag,
            count = library[t]?.count else {
                return 0
        }
        return count
    }
    
    func bookCountForTag(tagName: String) -> Int {
        let tag = tagBy(tagName)
        return bookCountForTag(tag)
    }

    func booksForTag(tag: Tag?) -> [Book]? {
        guard let t = tag,
            books = library[t] else {
                return nil
        }
        return arrayOfBooksSortedAlphabetically(books)
    }

    func booksForTag(tagName: String) -> [Book]? {
        let tag = tagBy(tagName)
        return booksForTag(tag)
    }

    func book(atIndex index:Int, forTag tag: Tag) -> Book? {
        guard let books = booksForTag(tag) else {
            return nil
        }
        return books[index]
    }

    func book(atIndex index:Int) -> Book? {
        let arrayOfBooks = arrayOfBooksSortedAlphabetically(books)

        if !arrayOfBooks.indices.contains(index) {
            return nil
        }

        return arrayOfBooks[index]
    }

    func arrayOfBooksSortedAlphabetically(booksSet: BooksSet) -> [Book] {
        let bookArray = Array(booksSet)
        let bookArraySorted = bookArray.sort()
        return bookArraySorted
    }
}
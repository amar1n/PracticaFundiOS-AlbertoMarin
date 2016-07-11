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
    init() {
        self.books = Set()
        self.tags = Set()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            do {
                try self.createTheLibrary()
            } catch {
                print("Library initialization failed!!! \(error)")
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
    
    //MARK: - Loading the model
    func createTheLibrary() throws {
        do {
            // Obtenemos los libros del JSON, bien sea local o remoto
            let json: JSONArray = try loadFrom(remoteURL: remoteLibraryUrl)
            var books = Set<Book>()
            for dict in json {
                do {
                    let book = try decode(book: dict)
                    books.insert(book)
                }
            }
            
            // Creamos el modelo a partir del JSON procesado
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
            
            // Notificar a todo dios diciendo que tengo nueva librería
            let nc = NSNotificationCenter.defaultCenter()
            let notif = NSNotification(name: LibraryAvailableNotification, object: self, userInfo: [LibraryKey: self])
            nc.postNotification(notif)
        } catch {
            print("Error while creating the Library \(error)")
        }
    }
}
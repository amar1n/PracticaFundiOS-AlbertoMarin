//
//  Constants.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 10/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import Foundation

//MARK: - Aliases
typealias JSONObject = AnyObject
typealias JSONDictionary = [String : JSONObject]
typealias JSONArray = [JSONDictionary]
typealias BooksSet = Set<Book>
typealias BooksDictionary = [Tag: BooksSet]
typealias TagsSet = Set<Tag>

//MARK: - LibraryTableViewController & LibraryViewController
let BookDidChangeNotification = "BookDidChangeNotification"
let BookKey = "BookKey"
let AppName = "HackerBooks"
let BookCellId = "BookCellId"
let BookCellHeight = 60
let TagCellId = "TagCellId"
let TagCellHeight = 44
let TagCellHeader2 = "Books available..."

//MARK: - PDFViewController
let PDFViewControllerPDFAvailableNotification = "PDFViewControllerPDFAvailableNotification"
let pdfPrefix = "pdf-"

//MARK: - JSONProcessing
let authors = "authors"
let image_url = "image_url"
let pdf_url = "pdf_url"
let tags = "tags"
let title = "title"
let libraryjson = "library.json"

//MARK: - Library
let LibraryAvailableNotification = "LibraryAvailableNotification"
let remoteLibraryUrl = "https://t.co/K9ziV0z3SJ"
let LibraryKey = "LibraryKey"
let favoritesTag = "⭐️F A V O R I T E S⭐️"

//MARK: - AsyncImage
let AsyncImageDidChangeNotification = "AsyncImageDidChangeNotification"
let coverPrefix = "cover-"

//MARK: - Book
let favorites = "favorites"
let favoritePrefix = "favorite-"
let FavoriteDidChangeNotification = "FavoriteDidChangeNotification"
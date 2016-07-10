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


//MARK: - LibraryTableViewController
let BookDidChangeNotification = "BookDidChangeNotification"
let BookKey = "BookKey"
let AppName = "HackerBooks"
let BookCellId = "BookCell"

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

//MARK: - AsyncImage
let AsyncImageDidChangeNotification = "AsyncImageDidChangeNotification"
let coverPrefix = "cover-"

//MARK: - AppDelegate
let remoteLibraryUrl = "https://t.co/K9ziV0z3SJ"
//
//  JSONProcessing.swift
//  AMG-StarWars
//
//  Created by Alberto Marín García on 27/6/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Decodification
func decode (book json: JSONDictionary) throws -> Book {
    var autores: [String]
    if let authorsString = json[authors] as? String {
        autores = authorsString.componentsSeparatedByString(",")
    } else {
        throw LibraryErrors.wrongJSONFormat
    }
    
    guard let imageUrl = json[image_url] as? String,
        coverUrl = NSURL(string: imageUrl)
        else {
            throw LibraryErrors.wrongURLFormatForJSONResource
    }
    
    guard let pdfUrlString = json[pdf_url] as? String,
        pdfUrl = NSURL(string: pdfUrlString)
        else {
            throw LibraryErrors.wrongURLFormatForJSONResource
    }
    
    var etiquetas = Set<Tag>()
    if let tagsString = json[tags] as? String {
        let tagsArray = tagsString.componentsSeparatedByString(",")
        let trimmedTagsArray = tagsArray.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
        for t in trimmedTagsArray {
            let tag: Tag = Tag(name: t)
            etiquetas.insert(tag)
        }
    } else {
        throw LibraryErrors.wrongJSONFormat
    }
    
    guard let title = json[title] as? String
        else {
            throw LibraryErrors.wrongJSONFormat
    }
    
    return Book(title: title, authors: autores, tags: etiquetas, pdfUrl: pdfUrl, coverUrl: coverUrl, favorite: false)
}

func decode (book json: JSONDictionary?) throws -> Book {
    if case .Some(let jsonDict) = json {
        return try decode(book: jsonDict)
    } else {
        throw LibraryErrors.nilJSONObject
    }
}

//MARK: - Loading
func loadFrom(localFileName name: String, bundle: NSBundle = NSBundle.mainBundle()) throws -> JSONArray {
    if let url = bundle.URLForResource(name),
        data = NSData(contentsOfURL: url),
        maybeArray = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? JSONArray,
        array = maybeArray {
        return array
    } else {
        throw LibraryErrors.jsonParsingError
    }
}

/*
 Is there a difference between “is” and isKindOfClass()?
 
 Yes there is a difference: "is" works with any class in Swift, whereas isKindOfClass() works only with those classes that are subclasses
 of NSObject or otherwise implement NSObjectProtocol.
 
 */
func loadFrom(remoteURL url: String, bundle: NSBundle = NSBundle.mainBundle()) throws -> JSONArray {
    var libraryData: NSData? = getLibraryFromDocuments()
    
    if libraryData == nil {
        // No está cacheado... hay que ir a buscarlo!!!
        libraryData = try getLibraryFromRemote(url)
    }
    
    guard let data = libraryData else {
        throw LibraryErrors.jsonParsingError
    }
    
    let obj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
    
    if obj is JSONArray {
        guard let maybeArray = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? JSONArray,
            array = maybeArray else {
                throw LibraryErrors.jsonParsingError
        }
        saveInDocuments(theLibrary: array)
        return array
    } else if obj is JSONDictionary {
        guard let maybeDictionary = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? JSONDictionary,
            dictionary = maybeDictionary else {
                throw LibraryErrors.jsonParsingError
        }
        let array: JSONArray = [dictionary]
        saveInDocuments(theLibrary: array)
        return array
    } else {
        throw LibraryErrors.jsonParsingError
    }
}

func getLibraryFromDocuments() -> NSData? {
    let fm = NSFileManager.defaultManager()
    let urls = fm.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
    let documents = urls.last!
    let jsonDocumentsPath = documents.URLByAppendingPathComponent(libraryjson)
    
    let jsonData: NSData? = NSData(contentsOfURL: jsonDocumentsPath)
    return jsonData
}

func getLibraryFromRemote(remoteURL: String) throws -> NSData? {
    guard let url = NSURL(string: remoteURL) else {
        throw LibraryErrors.jsonParsingError
    }
    return NSData(contentsOfURL: url)
//    var libraryData: NSData? = nil
//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//        if let url = NSURL(string: remoteURL) {
//            libraryData = NSData(contentsOfURL: url)
//        }
//    }
//    return libraryData
}

func saveInDocuments(theLibrary array: JSONArray) {
    var jsonData: NSData!
    do {
        jsonData = try NSJSONSerialization.dataWithJSONObject(array, options: NSJSONWritingOptions())
    } catch let error as NSError {
        print("Array to JSON conversion failed: \(error.localizedDescription)")
    }
    
    let fm = NSFileManager.defaultManager()
    let urls = fm.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
    let urlDir = urls.last!
    let jsonFilePath = urlDir.URLByAppendingPathComponent("library.json")
    
    let bFlag = jsonData.writeToURL(jsonFilePath, atomically: true)
    if (!bFlag) {
        print("JSON caching failed")
    }
}
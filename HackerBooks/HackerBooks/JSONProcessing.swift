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
        autores = authorsString.components(separatedBy: ",")
    } else {
        throw LibraryErrors.wrongJSONFormat
    }
    
    guard let imageUrl = json[image_url] as? String,
        let coverUrl = URL(string: imageUrl)
        else {
            throw LibraryErrors.wrongURLFormatForJSONResource
    }
    
    guard let pdfUrlString = json[pdf_url] as? String,
        let pdfUrl = URL(string: pdfUrlString)
        else {
            throw LibraryErrors.wrongURLFormatForJSONResource
    }
    
    var etiquetas = TagsSet()
    if let tagsString = json[tags] as? String {
        let tagsArray = tagsString.components(separatedBy: ",")
        let trimmedTagsArray = tagsArray.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
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
    
    return Book(title: title, authors: autores, tags: etiquetas, pdfUrl: pdfUrl, coverUrl: coverUrl)
}

func decode (book json: JSONDictionary?) throws -> Book {
    if case .some(let jsonDict) = json {
        return try decode(book: jsonDict)
    } else {
        throw LibraryErrors.nilJSONObject
    }
}

//MARK: - Loading
func loadFrom(localFileName name: String, bundle: Bundle = Bundle.main) throws -> JSONArray {
    if let url = bundle.URLForResource(name),
        let data = try? Data(contentsOf: url),
        let maybeArray = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? JSONArray,
        let array = maybeArray {
        return array
    } else {
        throw LibraryErrors.jsonParsingError
    }
}

func loadFrom(remoteURL url: String, bundle: Bundle = Bundle.main) throws -> JSONArray {
    var libraryData: Data? = getLibraryFromDocuments()
    
    if libraryData == nil {
        // No está cacheado... hay que ir a buscarlo!!!
        libraryData = try getLibraryFromRemote(url)
    }
    
    guard let data = libraryData else {
        throw LibraryErrors.jsonParsingError
    }
    
    let obj = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
    
    if obj is JSONArray {
        guard let maybeArray = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? JSONArray,
            let array = maybeArray else {
                throw LibraryErrors.jsonParsingError
        }
        saveInDocuments(theLibrary: array)
        return array
    } else if obj is JSONDictionary {
        guard let maybeDictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? JSONDictionary,
            let dictionary = maybeDictionary else {
                throw LibraryErrors.jsonParsingError
        }
        let array: JSONArray = [dictionary]
        saveInDocuments(theLibrary: array)
        return array
    } else {
        throw LibraryErrors.jsonParsingError
    }
}

func getLibraryFromDocuments() -> Data? {
    let fm = FileManager.default
    let urls = fm.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    let documents = urls.last!
    let jsonDocumentsPath = documents.appendingPathComponent(libraryjson)
    
    let jsonData: Data? = try? Data(contentsOf: jsonDocumentsPath)
    return jsonData
}

func getLibraryFromRemote(_ remoteURL: String) throws -> Data? {
    guard let url = URL(string: remoteURL) else {
        throw LibraryErrors.jsonParsingError
    }
    return (try? Data(contentsOf: url))
}

func saveInDocuments(theLibrary array: JSONArray) {
    var jsonData: Data!
    do {
        jsonData = try JSONSerialization.data(withJSONObject: array, options: JSONSerialization.WritingOptions())
    } catch let error as NSError {
        print("Array to JSON conversion failed: \(error.localizedDescription)")
    }
    
    let fm = FileManager.default
    let urls = fm.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    let urlDir = urls.last!
    let jsonFilePath = urlDir.appendingPathComponent("library.json")

    do {
        try jsonData.write(to: jsonFilePath, options: .atomic)
    } catch {
        print(error)
    }
}

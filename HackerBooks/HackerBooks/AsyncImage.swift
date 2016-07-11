//
//  AsyncImage.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 8/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import Foundation
import UIKit

class AsyncImage: Hashable {
    
    //MARK: - Stored properties
    let bookTitle: String
    let remoteUrlImage: NSURL?
    let placeholderName: String
    
    //MARK: - Initialization
    init(bookTitle: String, remoteUrlImage: NSURL?, placeholderName: String) {
        self.bookTitle = bookTitle
        self.remoteUrlImage = remoteUrlImage
        self.placeholderName = placeholderName
    }
    
    //MARK: - Computed properties
    var image: UIImage {
        get{
            guard let imgData = getImageCached() else {
                getRemoteImage()
                return UIImage(named: self.placeholderName)!
            }
            return UIImage(data: imgData)!
        }
    }
    
    //MARK: - Utilities
    func getImageCached() -> NSData? {
        return getImageFromTmp()
    }

    func getRemoteImage() {
        print("......................................AsyncImage.getRemoteImage")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let url = self.remoteUrlImage,
                imageData = NSData(contentsOfURL: url) {
                
                let bFlag = self.cacheImage(imageData)
                if (bFlag) {
                    // Notificar a todo dios diciendo que tengo nueva imagen
                    let nc = NSNotificationCenter.defaultCenter()
                    let notif = NSNotification(name: AsyncImageDidChangeNotification, object: self)
                    nc.postNotification(notif)
                }
            }
        }
    }

    func cacheImage(imageData: NSData) -> Bool {
        return saveImageInTmp(imageData)
    }

    func getImageFromTmp() -> NSData? {
        print("......................................AsyncImage.getImageFromTmp")
        let path = "\(NSTemporaryDirectory())\(coverPrefix)\(self.hashValue)"
        let imgData: NSData? = NSData(contentsOfFile: path)
        return imgData
    }
    
    func saveImageInTmp(imageData: NSData) -> Bool {
        let imageFilePath = "\(NSTemporaryDirectory())\(coverPrefix)\(self.hashValue)"
        let bFlag = imageData.writeToFile(imageFilePath, atomically: true)
        if (!bFlag) {
            print("Image caching failed")
        }
        return bFlag
    }

//    func getImageFromCaches() -> NSData? {
//        let fileMgr = NSFileManager.defaultManager()
//        let urls = fileMgr.URLsForDirectory(NSSearchPathDirectory.CachesDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
//        let cachesDir = urls.last!
//        let imageFilePath = cachesDir.URLByAppendingPathComponent("\(self.hashValue)")
//        
//        let imgData: NSData? = NSData(contentsOfURL: imageFilePath)
//        return imgData
//    }
//    
//    func saveImageInCaches(imageData: NSData) -> Bool {
//        let fm = NSFileManager.defaultManager()
//        let urls = fm.URLsForDirectory(NSSearchPathDirectory.CachesDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
//        let cachesDir = urls.last!
//        let imageFilePath = cachesDir.URLByAppendingPathComponent("\(self.hashValue)")
//        
//        let bFlag = imageData.writeToURL(imageFilePath, atomically: true)
//        if (!bFlag) {
//            print("Image caching failed")
//        }
//        return bFlag
//    }

    //MARK: - Proxies
    var proxyForComparison: String {
        get {
            return "\(bookTitle.uppercaseString)"
        }
    }
    
    //MARK: - Hashable
    var hashValue: Int {
        get{
            return bookTitle.hashValue
        }
    }
}

//MARK: - Equatable
func ==(lhs: AsyncImage, rhs: AsyncImage) -> Bool{
    guard (lhs !== rhs) else {
        return true
    }
    
    return lhs.proxyForComparison == rhs.proxyForComparison
}

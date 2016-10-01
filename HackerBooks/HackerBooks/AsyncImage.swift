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
    let remoteUrlImage: URL?
    let placeholderName: String
    
    //MARK: - Initialization
    init(bookTitle: String, remoteUrlImage: URL?, placeholderName: String) {
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
    func getImageCached() -> Data? {
        return getImageFromTmp()
    }

    func getRemoteImage() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            if let url = self.remoteUrlImage,
                let imageData = try? Data(contentsOf: url) {
                
                let bFlag = self.cacheImage(imageData)
                if (bFlag) {
                    // Notificar a todo dios diciendo que tengo nueva imagen
                    let nc = NotificationCenter.default
                    let notif = Notification(name: Notification.Name(rawValue: AsyncImageDidChangeNotification), object: self)
                    nc.post(notif)
                }
            }
        }
    }

    func cacheImage(_ imageData: Data) -> Bool {
        return saveImageInTmp(imageData)
    }

    func getImageFromTmp() -> Data? {
        let path = "\(NSTemporaryDirectory())\(coverPrefix)\(self.hashValue)"
        let imgData: Data? = try? Data(contentsOf: URL(fileURLWithPath: path))
        return imgData
    }
    
    func saveImageInTmp(_ imageData: Data) -> Bool {
        let imageFilePath = "\(NSTemporaryDirectory())\(coverPrefix)\(self.hashValue)"
        let bFlag = (try? imageData.write(to: URL(fileURLWithPath: imageFilePath), options: [.atomic])) != nil
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
            return "\(bookTitle.uppercased())"
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

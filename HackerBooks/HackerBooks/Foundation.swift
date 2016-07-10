//
//  Foundation.swift
//  AMG-StarWars
//
//  Created by Alberto Marín García on 27/6/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import Foundation

extension NSBundle {
    
    func URLForResource(name: String?) -> NSURL? {
        let components = name?.componentsSeparatedByString(".")
        let fileTitle = components?.first
        let fileExtension = components?.last
        
        return URLForResource(fileTitle, withExtension: fileExtension)
    }
}

extension NSUserDefaults {
    
    func indexPathForKey(key: String) -> NSIndexPath? {
        guard let indexArray = arrayForKey(key) as? [Int] else {
            return nil
        }
        return NSIndexPath(forRow: indexArray[0], inSection: indexArray[1])
    }
    
    func setIndexPath(indexPath: NSIndexPath, forKey key: String) {
        setObject([indexPath.row, indexPath.section], forKey:key)
    }
}
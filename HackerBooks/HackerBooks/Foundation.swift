//
//  Foundation.swift
//  AMG-StarWars
//
//  Created by Alberto Marín García on 27/6/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import Foundation

extension Bundle {
    
    func URLForResource(_ name: String?) -> URL? {
        let components = name?.components(separatedBy: ".")
        let fileTitle = components?.first
        let fileExtension = components?.last
        
        return url(forResource: fileTitle, withExtension: fileExtension)
    }
}

extension UserDefaults {
    
    func indexPathForKey(_ key: String) -> IndexPath? {
        guard let indexArray = array(forKey: key) as? [Int] else {
            return nil
        }
        return IndexPath(row: indexArray[0], section: indexArray[1])
    }
    
    func setIndexPath(_ indexPath: IndexPath, forKey key: String) {
        set([(indexPath as NSIndexPath).row, (indexPath as NSIndexPath).section], forKey:key)
    }
}

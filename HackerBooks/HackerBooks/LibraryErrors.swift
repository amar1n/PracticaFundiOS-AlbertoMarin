//
//  Errors.swift
//  AMG-StarWars
//
//  Created by Alberto Marín García on 27/6/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import Foundation

enum LibraryErrors : Error {
    case wrongURLFormatForJSONResource
    case resourcePointedByURLNotReachable
    case jsonParsingError
    case wrongJSONFormat
    case nilJSONObject
    case deviceNotSupported
}

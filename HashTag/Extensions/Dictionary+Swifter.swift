//
//  Dictionary+Swifter.swift
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//

import Foundation
extension Dictionary {
    
    func join(other: Dictionary) -> Dictionary {
        var joinedDictionary = Dictionary()
        
        for (key, value) in self {
            joinedDictionary.updateValue(value, forKey: key)
        }
        
        for (key, value) in other {
            joinedDictionary.updateValue(value, forKey: key)
        }
        
        return joinedDictionary
    }
    
    func filter(predicate: (key: KeyType, value: ValueType) -> Bool) -> Dictionary {
        var filteredDictionary = Dictionary()
        
        for (key, value) in self {
            if predicate(key: key, value: value) {
                filteredDictionary.updateValue(value, forKey: key)
            }
        }
        
        return filteredDictionary
    }
    
    func urlEncodedQueryStringWithEncoding(encoding: NSStringEncoding) -> String {
        var parts = String[]()
        
        for (key, value) in self {
            let keyString = "\(key)".urlEncodedStringWithEncoding(encoding)
            let valueString = "\(value)".urlEncodedStringWithEncoding(encoding)
            let query = "\(keyString)=\(valueString)" as String
            parts.append(query)
        }
        
        return parts.bridgeToObjectiveC().componentsJoinedByString("&") as String
    }
    
}
